/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     This exception is thrown when an error occurs while processing an
 *     incoming message from a kafka topic.
 */
package com.remal.springbox.commons.exception;

import com.remal.springbox.commons.model.Event;
import lombok.extern.slf4j.Slf4j;

import java.util.Objects;

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
