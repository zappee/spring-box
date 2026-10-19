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
package com.remal.springbox.service.message.consumer.error;

import com.remal.springbox.service.message.consumer.service.MicrometerMeterService;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.errors.RecordDeserializationException;
import org.springframework.kafka.listener.ConsumerRecordRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.kafka.listener.MessageListenerContainer;
import org.springframework.util.backoff.BackOff;

/**
 * Kafka consumer error handler.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
public class KafkaConsumerErrorHandler extends DefaultErrorHandler {

    private final MicrometerMeterService meterService;

    public KafkaConsumerErrorHandler(ConsumerRecordRecoverer recoverer, BackOff backOff, MicrometerMeterService meterService) {
        super(recoverer, backOff);
        this.meterService = meterService;
    }

    @Override
    public boolean handleOne(Exception thrownException,
                             ConsumerRecord<?, ?> record,
                             Consumer<?, ?> consumer,
                             MessageListenerContainer container) {
        return handle(thrownException, consumer);
    }

    @Override
    public void handleOtherException(Exception thrownException,
                                     Consumer<?, ?> consumer,
                                     MessageListenerContainer container,
                                     boolean batchListener) {
        handle(thrownException, consumer);
    }

    private boolean handle(Exception exception, Consumer<?,?> consumer) {
        if (exception instanceof RecordDeserializationException e) {
            log.error("Unable to parse the incoming record. {}", e.getMessage());
            consumer.seek(e.topicPartition(), e.offset() + 1L);
            consumer.commitSync();
        } else {
            log.error("An unexpected error occurred while trying to process the incoming message: ", exception);
        }
        meterService.registerDroppedEvent();
        return false;
    }
}
