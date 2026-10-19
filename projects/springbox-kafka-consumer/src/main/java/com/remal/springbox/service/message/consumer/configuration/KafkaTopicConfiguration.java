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

import com.remal.springbox.commons.spring.kafka.KafkaCreateTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.core.KafkaAdmin;

/**
 * Kafka topic configuration.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableKafka
public class KafkaTopicConfiguration extends KafkaCreateTopics {

    @Value("${kafka.bootstrap.servers}")
    private String bootstrapServers;

    // topic

    @Value("${kafka.topic.incoming.name}")
    private String incomingTopicName;

    @Value("${kafka.topic.incoming.partitions:1}")
    private int incomingTopicPartitions;

    @Value("${kafka.topic.incoming.replicas:1}")
    private int incomingTopicReplicas;

    @Value("${kafka.topic.incoming.retention.ms:604800000}")
    private int incomingTopicRetentionMs;

    /**
     * Topic creation.
     *
     * @return the created new topics
     */
    @Bean
    public KafkaAdmin.NewTopics createTopics() {
        return new KafkaAdmin.NewTopics(
                createTopic(
                        incomingTopicName,
                        incomingTopicPartitions,
                        incomingTopicReplicas,
                        incomingTopicRetentionMs));
    }

    /**
     * When using Spring Boot, a KafkaAdmin bean is automatically registered so
     * you only need the NewTopic @Beans. But if you use NewTopic and custom
     * producer config, you need to use that custom config for KafkaAdmin as
     * well.
     *
     * @return custom KafkaAdmin instance
     */
    @Bean
    public KafkaAdmin admin() {
        return super.admin();
    }

    @Override
    protected String getBootstrapServers() {
        return bootstrapServers;
    }
}
