/*
 * Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 * Since:  July 2025
 * Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 * Description:
 *    Kafka consumer configuration.
 */
package com.remal.springbox.commons.spring.kafka;

import com.remal.springbox.commons.converter.InstantConverter;
import com.remal.springbox.commons.exception.KafkaConsumerException;
import com.remal.springbox.commons.model.Event;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.listener.ContainerProperties;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.kafka.support.serializer.JsonDeserializer;
import org.springframework.util.backoff.BackOff;
import org.springframework.util.backoff.FixedBackOff;

import java.util.HashMap;
import java.util.Map;

@Slf4j
public abstract class KafkaConsumerConfiguration {

    protected abstract String getBootstrapServers();

    protected abstract String getAutoOffsetReset();

    protected abstract boolean isBatchListener();

    protected abstract Long getBackoffInterval();

    protected abstract Long getBackoffMaxAttempts();

    protected abstract int getConcurrency();

    protected abstract boolean isEnableAutoCommit();

    protected abstract String getIsolationLevel();

    protected abstract boolean isLogContainerConfig();

    protected abstract boolean isMissingTopicsFatal();

    protected abstract Long getPollTimeout();

    /**
     * <PRE>
     * The DefaultKafkaConsumerFactory constructor with three parameters has to
     * be used here because a custom JsonDeserialiser with type info is used.
     *
     * If using the default JsonDeserializer is okay for you, then the Map
     * configuration is safe to use:
     *
     *    configs.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
     *    configs.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);
     * </PRE>
     *
     * @return the ConsumerFactory bean
     */
    protected ConsumerFactory<String, Event> consumerFactory() {
        log.debug("initializing ConsumerFactory: {"
                        + "auto.offset.reset: \"{}\", batch.listener: {}, bootstrap.servers: \"{}\", "
                        + "concurrency: {}, enable.auto.commit: {}, log.container.config: {}, "
                        + "missing.topics.fatal: {}, poll.timeout: {}, isolation.level: \"{}\", "
                        + "backoff.interval: {}, backoff.max.attempts: {}}...",
                getAutoOffsetReset(),
                isBatchListener(),
                getBootstrapServers(),
                getConcurrency(),
                isEnableAutoCommit(),
                isLogContainerConfig(),
                isMissingTopicsFatal(),
                getPollTimeout(),
                getIsolationLevel(),
                getBackoffInterval(),
                getBackoffMaxAttempts());

        return new DefaultKafkaConsumerFactory<>(
                consumerConfiguration(),
                new StringDeserializer(),
                new JsonDeserializer<>(Event.class));
    }

    /**
     * <PRE>
     * Why handle messages in batches?
     * To run in the batch mode, we must configure the right batch size by
     * considering the volume of the data published on the topics and the
     * application’s capacity. Moreover, the consumer applications should be
     * designed to handle the messages in bulk to meet the SLAs.
     *
     * Additionally, without batch processing, consumers have to poll regularly
     * on the kafka topics to get the messages individually. This approach puts
     * pressure on the compute resources. Therefore, batch processing is much
     * more efficient than single message processing per poll.
     *
     * However, batch processing may not be suitable in certain cases where:
     *    - The volume of messages is small
     *    - Immediate processing is critical in time-sensitive application
     *    - There’s a constraint on the compute and memory resources
     *    - Strict message ordering is critical
     * </PRE>
     *
     * @return the kafka listener container factory
     */
    protected ConcurrentKafkaListenerContainerFactory<String, Event> containerFactory() {
        log.debug("initializing a ConcurrentKafkaListenerContainerFactory...");
        ConcurrentKafkaListenerContainerFactory<String, Event> factory = new ConcurrentKafkaListenerContainerFactory<>();

        // Set to true if this endpoint should create a batch listener.
        factory.setBatchListener(isBatchListener());

        // The maximum number of concurrent KafkaMessageListenerContainers running.
        // Use cases:
        //    - You have a topic with three partitions and setConcurrency(1) is used: Spring creates
        //      only one consumer thread, all the partitions are read by the same consumer thread.
        //
        //    - You have a topic with three partitions and setConcurrency(3) is used: Spring creates
        //      three Java consumer threads, and each unique thread connects to a specific partition.
        //
        //    - You have a topic with three partitions and setConcurrency(4) is used: Spring creates
        //      three Java consumer threads, connected to the three partitions. One Java thread is idle.
        //
        // Messages only from the same partition are processed sequentially. There will be no order guarantee
        // unless you use exactly one partition. More specifically, data is only ordered within a partition.
        // If you want to process the incoming data sequentially, then you
        //    1) need to have only one partition per topic
        //    2) use the Hashing-Key technique
        factory.setConcurrency(getConcurrency());

        // There are several ack modes available:
        //
        //    (1) AckMode.RECORD: In this after-processing mode, the consumer sends an acknowledgment for each
        //                        message it processes.
        //
        //    (2) AckMode.BATCH: In this manual mode, the consumer sends an acknowledgment for a batch of messages,
        //                       rather than for each message.
        //
        //    (3) AckMode.COUNT: In this manual mode, the consumer sends an acknowledgment after it has processed
        //                       a specific number of messages.
        //
        //    (4) AckMode.MANUAL: In this manual mode, the consumer doesn’t send an acknowledgment for the
        //                        messages it processes.
        //
        //    (5) AckMode.TIME: In this manual mode, the consumer sends an acknowledgment after a certain amount
        //                      of time has passed.
        factory.getContainerProperties().setAckMode(ContainerProperties.AckMode.RECORD);

        // When true and INFO logging is enabled, each listener container writes a log
        // message summarizing its configuration properties.
        factory.getContainerProperties().setLogContainerConfig(isLogContainerConfig());

        // Set it to "false" allowing the container to start even if any of the configured topics are not present
        // on the broker. Default true;
        factory.getContainerProperties().setMissingTopicsFatal(isMissingTopicsFatal());

        // Specify a ConsumerFactory to use.
        factory.setConsumerFactory(consumerFactory());

        // Set the max time to block in the consumer waiting for records.
        factory.getContainerProperties().setPollTimeout(getPollTimeout());

        // Container error Handlers.
        factory.setCommonErrorHandler(errorHandler());

        return factory;
    }

    private Map<String, Object> consumerConfiguration() {
        Map<String, Object> configs = new HashMap<>();

        // default:	latest
        // valid values: [latest, earliest, none]
        //
        // What to do when there is no initial offset in kafka or if the current offset does not exist any more
        // on the server (e.g. because that data has been deleted):
        //
        //    - earliest: automatically reset the offset to the earliest offset
        //    - latest: automatically reset the offset to the latest offset
        //    - none: throw exception to the consumer if no previous offset is found for the consumer’s group
        //    - anything else: throw exception to the consumer.
        //
        // Note that altering partition numbers while setting this config to latest may cause message delivery
        // loss since producers could start to send messages to newly added partitions (i.e., no initial offsets
        // exist yet) before consumers reset their offsets.
        configs.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, getAutoOffsetReset());

        // default: null
        configs.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, getBootstrapServers());

        // default: true
        //
        // If true, the consumer’s offset will be periodically committed in the background.
        configs.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, isEnableAutoCommit());

        // Consumer should only read committed messages. If the transaction is not successful, kafka message
        // will not be marked as committed and this message will not be visible to consumers. So if the
        // transaction fails to complete, the consumer will not receive that event.
        configs.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, getIsolationLevel());

        return configs;
    }

    private DefaultErrorHandler errorHandler() {
        BackOff fixedBackOff = new FixedBackOff(getBackoffInterval(), getBackoffMaxAttempts());

        DefaultErrorHandler errorHandler = new KafkaConsumerErrorHandler((consumerRecord, e) -> {
            // logic to execute when all the retry attempts are exhausted
            registerKafkaErrorEvent();
            log.error("Error occurred while processing an incoming message. This message will be dropped: "
                            + "{topic: \"{}\", partition: {}, offset: {}, timestamp: {}, key: \"{}\", value: \"{}\"}",
                    consumerRecord.topic(),
                    consumerRecord.partition(),
                    consumerRecord.offset(),
                    InstantConverter.toInstant(consumerRecord.timestamp()),
                    consumerRecord.key().toString(),
                    consumerRecord.value().toString(),
                    e.getCause());
        }, fixedBackOff);

        errorHandler.addRetryableExceptions(KafkaConsumerException.class);
        errorHandler.addNotRetryableExceptions(NullPointerException.class);
        return errorHandler;
    }

    protected abstract void registerKafkaErrorEvent();
}
