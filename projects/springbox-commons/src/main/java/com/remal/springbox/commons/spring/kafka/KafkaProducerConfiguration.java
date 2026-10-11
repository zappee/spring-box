/*
 * Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 * Since:  July 2025
 * Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 * Description:
 *    Kafka producer abstract configuration.
 */
package com.remal.springbox.commons.spring.kafka;

import com.remal.springbox.commons.model.Event;
import jakarta.annotation.Nonnull;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.kafka.core.ProducerPostProcessor;
import org.springframework.kafka.support.serializer.JsonSerializer;
import org.springframework.lang.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Slf4j
public abstract class KafkaProducerConfiguration {

    protected abstract String getFqdn();

    protected abstract String getBootstrapServers();

    protected abstract String getAcks();

    protected abstract String getDeliveryTimeoutMs();

    protected abstract String getEnableIdempotence();

    protected abstract String getLingerMs();

    protected abstract boolean isPerThread();

    protected abstract String getRequestTimeoutMs();

    protected abstract String getRetries();

    protected abstract String getRetryBackoffMaxMs();

    protected abstract String getRetryBackoffMs();

    /**
     * Create a producer which will be transactional if the factory is so configured.
     *
     * @return the ProducerFactory bean
     */
    protected ProducerFactory<String, Event> producerFactory() {
        var transactionIdPrefix = "tx-" + getFqdn() + "-";

        log.debug("initializing ProducerFactory: {"
                + "acks: \"{}\", bootstrap.servers: \"{}\", delivery.timeout.ms: {}, "
                + "enable.idempotence: {}, linger.ms: {}, producer.per.thread: {}, "
                + "request.timeout.ms: {}, retries: {}, retry.backoff.max.ms: {}, "
                + "retry.backoff.ms: {}, transaction.id.prefix: \"{}\"}...",
                getAcks(),
                getBootstrapServers(),
                getDeliveryTimeoutMs(),
                getEnableIdempotence(),
                getLingerMs(),
                isPerThread(),
                getRequestTimeoutMs(),
                getRetries(),
                getRetryBackoffMaxMs(),
                getRetryBackoffMs(),
                transactionIdPrefix);

        DefaultKafkaProducerFactory<String, Event> factory = new DefaultKafkaProducerFactory<>(producerConfiguration());

        // Set to true to create a producer per thread instead of singleton that is shared by all clients.
        // Clients must call closeThreadBoundProducer() to physically close the producer when it is no longer
        // needed. These producers will not be closed by destroy() or reset().
        factory.setProducerPerThread(isPerThread());

        // Use it with the @Transactional annotation on the 'send' method.
        //factory.setTransactionIdPrefix(transactionIdPrefix);


        // It is relevant if setProducerPerThread(true) is used.
        factory.addListener(new ProducerFactory.Listener<>() {
            @Override
            public void producerAdded(@NonNull String id, @NonNull Producer<String, Event> producer) {
                log.info("ProducerFactory > listener > producerAdded: {id: \"{}\"}", id);
            }

            @Override
            public void producerRemoved(@NonNull String id, @NonNull Producer<String, Event> producer) {
                log.info("ProducerFactory > listener > producerRemoved: {id: \"{}\"}", id);
            }
        });

        factory.addPostProcessor(new ProducerPostProcessor<>() {
            @Override
            public Producer<String, Event> apply(Producer<String, Event> eventProducer) {
                log.info("ProducerFactory > PostProcessor > apply");
                return eventProducer;
            }

            @Override
            @Nonnull
            public <V> Function<V, Producer<String, Event>> compose(@NonNull Function<? super V, ? extends Producer<String, Event>> before) {
                log.info("ProducerFactory > PostProcessor > compose");
                return ProducerPostProcessor.super.compose(before);
            }

            @Override
            @Nonnull
            public <V> Function<Producer<String, Event>, V> andThen(@NonNull Function<? super Producer<String, Event>, ? extends V> after) {
                log.info("ProducerFactory > PostProcessor > andThen");
                return ProducerPostProcessor.super.andThen(after);
            }
        });

        return factory;
    }

    /**
     * Create a template for executing high-level operations.
     * The built-in micrometer timers are disabled as we use custom meters.
     *
     * @return template for executing high-level operations
     */
    protected KafkaTemplate<String, Event> kafkaTemplate() {
        log.debug("initializing a KafkaTemplate...");

        var template = new KafkaTemplate<>(producerFactory());
        template.setMicrometerEnabled(false);
        return template;
    }

    private Map<String, Object> producerConfiguration() {
        Map<String, Object> configs = new HashMap<>();

        // Default:	all
        // Valid values: [all, -1, 0, 1]
        //
        // The number of acknowledgments the producer requires the leader to have received before considering a
        // request complete. This controls the durability of records that are sent. The following settings are allowed:
        //
        // 0:   If set to zero then the producer will not wait for any acknowledgment from the server at all. The
        //      record will be immediately added to the socket buffer and considered sent. No guarantee can be made
        //      that the server has received the record in this case, and the retry configuration will not take
        //      effect (as the client won’t generally know of any failures). The offset given back for each record
        //      will always be set to -1.
        //
        // 1:   This will mean the leader will write the record to its local log but will respond without awaiting
        //      full acknowledgment from all followers. In this case should the leader fail immediately after
        //      acknowledging the record, but before the followers have replicated it, then the record will be lost.
        //
        // all: This means the leader will wait for the full set of in-sync replicas to acknowledge the record. This
        //      guarantees that the record will not be lost as long as at least one in-sync replica remains alive.
        //      This is the strongest available guarantee. This is equivalent to the acks=-1 setting.
        //
        // Note that enabling idempotence requires this config value to be "all". If conflicting configurations are
        // set and idempotence is not explicitly enabled, idempotence is disabled.
        configs.put(ProducerConfig.ACKS_CONFIG, getAcks());

        // Default: null
        configs.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, getBootstrapServers());

        // Default: 120 000 (2 min)
        //
        // Producer doesn’t retry the record forever if retries= Integer.MAX_VALUE, it is bounded by timeout.
        // A record will be failed if it cannot be delivered within this configured time.
        configs.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, getDeliveryTimeoutMs());

        // Default:	true
        //
        // Idempotent producer ensures that duplicates are not introduced due to unexpected producer retries.
        //
        // When set to true, the producer will ensure that exactly one copy of each message is written in the
        // stream. If false, producer retries due to broker failures, etc., may write duplicates of the
        // retried message in the stream. Note that enabling idempotence requires
        // max.in.flight.requests.per.connection to be less than or equal to 5 (with message ordering preserved
        // for any allowable value), retries to be greater than 0 and acks must be "all".
        //
        // Idempotence is enabled by default if no conflicting configurations are set. If conflicting
        // configurations are set and idempotence is not explicitly enabled, idempotence is disabled. If
        // idempotence is explicitly enabled and conflicting configurations are set, a ConfigException is
        // thrown.
        configs.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, getEnableIdempotence());

        // Default: null
        configs.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);

        // Default: 0
        //
        // How long to wait until we send a batch to kafka. This can introduce small delay in message processing
        // but decrease network calls between kafka producer and kafka cluster (as we are sending messages in
        // batches) which increase throughput and producer efficiency.
        configs.put(ProducerConfig.LINGER_MS_CONFIG, getLingerMs());

        // Default:	30 000 (30 seconds)
        //
        // Controls the maximum amount of time the client will wait for the response of a request. If the
        // response is not received before the timeout expires, the client will resend the request if necessary
        // or fail the request if retries are exhausted. This should be larger than replica.lag.time.max.ms
        // (a broker configuration, default: 30000 (30 seconds) to reduce the possibility of message duplication
        // due to unnecessary producer retries.
        configs.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, getRequestTimeoutMs());

        // Default: Integer.MAX_VALUE (2147483647)
        //
        // Producer attempts to send a message for this configured number of retries before marking it as failed.
        configs.put(ProducerConfig.RETRIES_CONFIG, getRetries());

        // Default:	1 000 (1 second)
        //
        // The maximum amount of time in milliseconds to wait when retrying a request to the broker that has
        // repeatedly failed. If provided, the backoff per client will increase exponentially for each failed
        // request, up to this maximum. To prevent all clients from being synchronized upon retry,
        // a randomized jitter with a factor of 0.2 will be applied to the backoff, resulting in the backoff
        // falling within a range between 20% below and 20% above the computed value. If retry.backoff.ms is set
        // to be higher than retry.backoff.max.ms, then retry.backoff.max.ms will be used as a constant backoff
        // from the beginning without any exponential increase.
        configs.put(ProducerConfig.RETRY_BACKOFF_MAX_MS_CONFIG, getRetryBackoffMaxMs());

        // Default: 100 (0.1 second)
        //
        // The amount of time to wait before attempting to retry a failed request to a given topic partition.
        // This avoids repeatedly sending requests in a tight loop under some failure scenarios. This value is
        // the initial backoff value and will increase exponentially for each failed request, up to the
        // retry.backoff.max.ms value.
        configs.put(ProducerConfig.RETRY_BACKOFF_MS_CONFIG, getRetryBackoffMs());

        // Default: null
        configs.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);

        return configs;
    }
}
