/*
 * Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 * Since:  Jun 2025
 * Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 * Description:
 *    Processing incoming Kafka message error.
 */
package com.remal.springbox.commons.exception;

import com.remal.springbox.commons.model.Event;
import lombok.extern.slf4j.Slf4j;

import java.util.Objects;

@Slf4j
public class KafkaConsumerException extends RuntimeException {

    /**
     * Constructor.
     *
     * @param message the event from kafka topic that caused the error
     * @param topic the kafka topic name
     * @param errorMessage the error message
     */
    public KafkaConsumerException(Event message, String topic, String errorMessage) {
        super(String.format(
                "Failure while trying to process an incoming message from kafka: {event: \"%s\", topic: \"%s\", error: \"%s\"}",
                Objects.isNull(message) ? "null" : message.toString(),
                topic,
                errorMessage));
        log.error(getMessage());
    }
}
