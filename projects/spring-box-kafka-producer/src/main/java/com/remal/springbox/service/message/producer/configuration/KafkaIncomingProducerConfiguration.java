/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Kafka producer configuration.
 */
package com.remal.springbox.service.message.producer.configuration;

import com.remal.springbox.commons.model.Event;
import com.remal.springbox.commons.spring.kafka.KafkaProducerConfiguration;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;


@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableKafka
@Getter
public class KafkaIncomingProducerConfiguration extends KafkaProducerConfiguration {

    @Value("${FQDN}") // environment variable
    private String fqdn;

    @Value("${kafka.bootstrap.servers:kafka-1.hello.com:9092, kafka-2.hello.com:9092}")
    private String bootstrapServers;

    @Value("${kafka.topic.incoming.producer.acks:all}")
    private String acks;

    @Value("${kafka.topic.incoming.producer.delivery.timeout.ms:120000}")
    private String deliveryTimeoutMs;

    @Value("${kafka.topic.incoming.producer.enable.idempotence:true}")
    private String enableIdempotence;

    @Value("${kafka.topic.incoming.producer.linger.ms:0}")
    private String lingerMs;

    @Value("${kafka.topic.incoming.producer.per.thread:false}")
    private boolean perThread;

    @Value("${kafka.topic.incoming.producer.request.timeout.ms:30000}")
    private String requestTimeoutMs;

    @Value("${kafka.topic.incoming.producer.retries:2147483647}")
    private String retries;

    @Value("${kafka.topic.incoming.producer.retry.backoff.max.ms:1000}")
    private String retryBackoffMaxMs;

    @Value("${kafka.topic.incoming.producer.retry.backoff.ms:100}")
    private String retryBackoffMs;

    /**
     * Create a producer which will be transactional if the factory is so configured.
     *
     * @return the ProducerFactory bean
     */
    @Bean
    public ProducerFactory<String, Event> chatRequestProducerFactory() {
        return super.producerFactory();
    }

    /**
     * Create a template for executing high-level operations.
     * The built-in micrometer timers are disabled as we use custom meters.
     *
     * @return template for executing high-level operations
     */
    @Bean
    public KafkaTemplate<String, Event> chatRequestProducerKafkaTemplate() {
        return super.kafkaTemplate();
    }
}
