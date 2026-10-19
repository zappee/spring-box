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
package com.remal.springbox.service.message.consumer.configuration;

import com.remal.springbox.commons.model.Event;
import com.remal.springbox.commons.spring.kafka.KafkaConsumerConfiguration;
import com.remal.springbox.service.message.consumer.service.MicrometerMeterService;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;

/**
 * Kafka consumer configuration.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableKafka
@Getter
public class KafkaIncomingConsumerConfiguration extends KafkaConsumerConfiguration {

    private final MicrometerMeterService meterService;

    @Value("${kafka.bootstrap.servers}")
    private String bootstrapServers;

    @Value("${kafka.topic.incoming.consumer.auto.offset.reset:latest}")
    private String autoOffsetReset;

    @Value("${kafka.topic.incoming.consumer.batch.listener:false}")
    private boolean batchListener;

    @Value(value = "${kafka.topic.incoming.consumer.backoff.interval:5000}")
    private Long backoffInterval;

    @Value(value = "${kafka.topic.incoming.consumer.backoff.max.attempts:9}")
    private Long backoffMaxAttempts;

    @Value("${kafka.topic.incoming.consumer.concurrency:1}")
    private int concurrency;

    @Value("${kafka.topic.incoming.consumer.enable.auto.commit:true}")
    private boolean enableAutoCommit;

    @Value("${kafka.topic.incoming.consumer.isolation.level:read_uncommitted}")
    private String isolationLevel;

    @Value("${kafka.topic.incoming.consumer.log.container.config:false}")
    private boolean logContainerConfig;

    @Value("${kafka.topic.incoming.consumer.missing.topics.fatal:true}")
    private boolean missingTopicsFatal;

    @Value("${kafka.topic.incoming.consumer.poll.timeout:5000}")
    private Long pollTimeout;

    /**
     * Create a consumer with the group id and client id as configured in the properties.
     *
     * @return the ConsumerFactory bean
     */
    @Bean
    public ConsumerFactory<String, Event> consumerFactory() {
        return super.consumerFactory();
    }

    /**
     * This factory is primarily for building containers for {@code KafkaListener} annotated
     * methods.
     *
     * @return the kafka listener container factory
     */
    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, Event> containerFactory() {
        return super.containerFactory();
    }

    @Override
    protected void registerKafkaErrorEvent() {
        meterService.registerDroppedEvent();
    }
}
