/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Kafka message consumer.
 */
package com.remal.springbox.service.message.consumer.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.remal.springbox.commons.exception.FailureToProcessException;
import com.remal.springbox.commons.model.Event;
import com.remal.springbox.service.message.consumer.mapper.EventMapper;
import com.remal.springbox.service.message.consumer.repository.EventRepository;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Objects;

@Slf4j
@Component
@RequiredArgsConstructor
public class KafkaConsumerService {

    private final ObjectMapper jsonMapper = JsonMapper.builder().addModule(new JavaTimeModule()).build();
    private final EventRepository eventRepository;
    private final EventMapper eventMapper;
    private final MicrometerMeterService meterService;

    @Getter
    @Value("${kafka.topic.incoming.name}")
    private String topicName;

    @KafkaListener(
            // Think of it as the name of the bean, used only internally by Spring.
            // When provided, this value will override the group id property in the consumer
            // factory configuration, unless idIsGroup() is set to false or groupId() is provided.
            //id = "kafkaListener",

            // This is used to generate the Consumer ID of the spring consumer.
            // Consumers read the messages from a partition to be assigned to the consumer. Setting
            // this correctly will help you to identify in a monitoring system to see who is
            // consuming the partition.
            // TThe $FQDN here is an environment variable; its value reflects the full qualified
            // domain name of the host machine on which the consumer is running.
            clientIdPrefix = "${FQDN}",

            // Used by kafka broker to uniquely identify a consumer group.
            groupId = "${kafka.topic.incoming.name}-${random.uuid}",

            topics = "${kafka.topic.incoming.name}",
            containerFactory = "containerFactory")

    // The trick here is giving transactionManager as the value for the @Transactional annotation because
    // there are two transaction manager beans available: transactionManager and kafkaTransactionManager.
    // The transactionManager is an instance of JpaTransactionManager while the kafkaTransactionManager
    // bean is an instance of KafkaTransactionManager.
    // Whenever a new message comes in, it will automatically begin a kafka transaction before it starts
    // running our method.
    @Transactional("transactionManager")
    public void onMessage(ConsumerRecord<String, Event> data, Consumer<?, ?> consumer) {
        var topic = data.topic();
        var partition = data.partition();
        var groupId = consumer.groupMetadata().groupId();
        var consumerId = consumer.groupMetadata().memberId();
        var incomingMessage = data.value();

        log.debug(
                "receiving a message from kafka: {topic: \"{}\", partition: {}, consumer-group: \"{}\", consumer-id-in-the-group:  \"{}\", payload: {}}",
                topic,
                partition,
                groupId,
                consumerId,
                incomingMessage.toString());
        meterService.registerIncomingEvent();

        var eventEntity = eventMapper.toEntity(incomingMessage);
        eventEntity.setTopic(topic);
        eventEntity.setPartition(partition);
        eventEntity.setGroupId(groupId);
        eventEntity.setPayload(eventToJson(incomingMessage));

        eventRepository.save(eventEntity);

        // a deliberately thrown error for testing purposes
        if (Objects.nonNull(incomingMessage.getUserId()) && incomingMessage.getUserId().equals("error")) {
            throw new FailureToProcessException(incomingMessage, topic, "A deliberately thrown error for testing purposes.");
        }

        meterService.registerProcessedEvent();
     }

     private String eventToJson(Event event) {
         try {
             return jsonMapper.writeValueAsString(event);
         } catch (JsonProcessingException e) {
             throw new FailureToProcessException("An error has occurred while trying to convert a com.remal.springbox.commons.model.Event object to JSON.", e);
         }
     }
}
