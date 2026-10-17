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
package com.remal.springbox.commons.exception;

import com.remal.springbox.commons.model.Event;
import lombok.extern.slf4j.Slf4j;

import java.util.Objects;

/**
 * Thrown when an error occurs while processing an incoming message from a
 * Kafka topic.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
public class FailureToProcessException extends RuntimeException {

    /**
     * Constructor.
     *
     * @param event the event from kafka topic that caused the error
     * @param topic the kafka topic name
     * @param errorMessage the error message
     */
    public FailureToProcessException(Event event, String topic, String errorMessage) {
        super(String.format(
                "Failure while trying to process an incoming message from kafka: {event: \"%s\", topic: \"%s\", error: \"%s\"}",
                Objects.isNull(event) ? "null" : event.toString(),
                topic,
                errorMessage));
        log.error(getMessage());
    }

    /**
     * Constructor.
     *
     * @param message the detail message
     * @param exception the cause
     */
    public FailureToProcessException(String message, Exception exception) {
        super(message, exception);
        log.error(getMessage());
    }
}
