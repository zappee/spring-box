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
package com.remal.springbox.commons.spring.kafka;

import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.admin.AdminClientConfig;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.common.config.TopicConfig;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.KafkaAdmin;

import java.util.HashMap;
import java.util.Map;

/**
 *  Kafka topic provisioning utility.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
public abstract class KafkaCreateTopics {

    /**
     * Topic creation.
     * <br>
     * The recommended method body is as follows:
     *    return new KafkaAdmin.NewTopics(
     *        createTopic(topicName1, topicPartitions1, topicReplicas1, topic1RetentionMs),
     *        createTopic(topicName2, topicPartitions2, topicReplicas2, topic2RetentionMs));
     *
     * @return the created new topics
     */
    protected abstract KafkaAdmin.NewTopics createTopics();

    /**
     * When using Spring Boot, a KafkaAdmin bean is automatically registered so
     * you only need the NewTopic @Beans. But if you use NewTopic and custom
     * producer config, you need to use that custom config for KafkaAdmin as
     * well.
     *
     * @return custom KafkaAdmin instance
     */
    protected KafkaAdmin admin() {
        log.debug("initializing a KafkaAdmin: {bootstrap.servers: \"{}\"}...", getBootstrapServers());
        Map<String, Object> configs = new HashMap<>();
        configs.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, getBootstrapServers());
        return new KafkaAdmin(configs);
    }

    protected abstract String getBootstrapServers();

    protected NewTopic createTopic(String name, Integer partitions, Integer replicas, int retentionMs) {
        log.debug("creating a new kafka topic: {name: \"{}\", partitions: {}, replicas: {}}", name, partitions, replicas);
        return TopicBuilder
                .name(name)
                .partitions(partitions)
                .replicas(replicas)
                .config(TopicConfig.RETENTION_MS_CONFIG, String.valueOf(retentionMs))
                .build();
    }
}
