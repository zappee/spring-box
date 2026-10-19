/*
 * Copyright (c) 2020-2026 Remal Software. All rights reserved.
 * Contact: arnold.somogyi@gmail.com
 *
 * This work is licensed under the Creative Commons Attribution-
 * NonCommercial 4.0 International License. To view a copy of this license,
 * visit: https://creativecommons.org
 *
 * You are free to share and adapt the material for personal or hobby
 * purposes, provided you give appropriate credit and do not use the material
 * for commercial gain.
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

/**
 * Kafka producer configuration.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableKafka
@Getter
public class KafkaIncomingProducerConfiguration extends KafkaProducerConfiguration {

    @Value("${FQDN}") // environment variable
    private String fqdn;

    @Value("${kafka.bootstrap.servers}")
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
