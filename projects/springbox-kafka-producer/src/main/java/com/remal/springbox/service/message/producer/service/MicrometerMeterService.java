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
package com.remal.springbox.service.message.producer.service;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.composite.CompositeMeterRegistry;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Micrometer meter configuration.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MicrometerMeterService {

    @Getter
    @Value("${kafka.topic.incoming.name}")
    private String topicName;

    private final CompositeMeterRegistry meterRegistry;

    public void registerSentMessage() {
        getCounter("to_be_sent", "Total number of the sent messages to kafka topic.").increment();
    }

    public void registerProcessedMessage() {
        getCounter("sent", "Total number of the processed messages.").increment();
    }

    public void registerUnprocessedMessage() {
        getCounter("dropped", "Total number of unprocessed messages.").increment();
    }

    private Counter getCounter(String status, String description) {
        return Counter
                .builder("remal_kafka_producer_" + topicName)
                .tags("topic", topicName, "status", status)
                .description(description)
                .register(meterRegistry);
    }
}
