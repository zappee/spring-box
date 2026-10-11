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

import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.admin.AdminClientConfig;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.common.config.TopicConfig;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.KafkaAdmin;

import java.util.HashMap;
import java.util.Map;

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
