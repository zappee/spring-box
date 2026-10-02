/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Kafka consumer configuration.
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


@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableKafka
@Getter
public class KafkaIncomingConsumerConfiguration extends KafkaConsumerConfiguration {

    private final MicrometerMeterService meterService;

    @Value("${kafka.bootstrap.servers:kafka-1.hello.com:9092, kafka-2.hello.com:9092}")
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
