/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Kafka massage producer.
 */
package com.remal.springbox.service.message.producer.service;

import com.remal.springbox.commons.model.Event;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.errors.RetriableException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class KafkaProducerService {

    @Value("${kafka.topic.incoming.name}")
    private String topicName;

    private final KafkaTemplate<String, Event> kafkaTemplate;
    private final MicrometerMeterService meterService;

    /**
     * Sending a message to the kafka topic.
     * Use the @Transactional if you want to send records to kafka and perform some database updates.
     * The database transaction will commit followed by the kafka transaction.
     *
     * @param event the message to send
     */
    public void send(Event event) {
        log.debug("sending message to kafka: {topic: \"{}\", payload: {}}", topicName, event);
        meterService.registerSentMessage();

        // Why are all producer messages sent to one partition?
        // If you are not specifying any custom partition, it will use the default partitioner
        // as per the below rule:
        //
        //   1) If a partition is specified in the record, use it that partition to publish.
        //
        //   2) If no partition is specified but a key is present, choose a partition based on
        //      a hash of the key
        //
        //   3) If no partition or key is present, choose a partition in a round-robin fashion
        ProducerRecord<String, Event> record = new ProducerRecord<>(topicName, event.getUserId(), event);
        kafkaTemplate.send(record).
                whenComplete((result, ex) -> {
                    if (ex == null) {
                        log.info(
                                "message successfully sent to kafka: {topic: \"{}\", partition: {}, offset: {}, key: \"{}\", value: \"{}\"}",
                                result.getRecordMetadata().topic(),
                                result.getRecordMetadata().partition(),
                                result.getRecordMetadata().offset(),
                                result.getProducerRecord().key(),
                                result.getProducerRecord().value());
                        meterService.registerProcessedMessage();
                    } else {
                        // If Spring is unable to deliver the message to the kafka topic within the time specified
                        // in 'delivery.timeout.ms' (ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG), Spring
                        // throws an exception.
                        var cause = ex.getCause();
                        var isRetryable = cause instanceof RetriableException;
                        log.error(
                                "failed to send message to kafka: {topic: \"{}\", event: {}, error: {}, isRetryable: {}}",
                                topicName,
                                event,
                                cause.getMessage(),
                                isRetryable,
                                ex);
                        meterService.registerUnprocessedMessage();
                    }});
    }
}
