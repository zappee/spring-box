/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Pre configured micrometer meters.
 */
package com.remal.springbox.service.message.producer.service;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.composite.CompositeMeterRegistry;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

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
