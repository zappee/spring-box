/*
 * Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 * Since:  July 2025
 * Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 * Description:
 *    Kafka consumer error handler.
 */
package com.remal.springbox.commons.spring.kafka;

import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.errors.RecordDeserializationException;
import org.springframework.kafka.listener.ConsumerRecordRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.kafka.listener.MessageListenerContainer;
import org.springframework.util.backoff.BackOff;

@Slf4j
public class KafkaConsumerErrorHandler extends DefaultErrorHandler {

    public KafkaConsumerErrorHandler(ConsumerRecordRecoverer recoverer, BackOff backOff) {
        super(recoverer, backOff);
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
        return false;
    }
}
