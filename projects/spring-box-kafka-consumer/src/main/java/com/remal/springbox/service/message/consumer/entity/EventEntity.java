/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *    JPA entity.
 */
package com.remal.springbox.service.message.consumer.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "event")
@Data
public class EventEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "event-id-sequence")
    @SequenceGenerator(name = "event-id-sequence", sequenceName = "event_id_seq", allocationSize = 1)
    @Column(name = "id")
    private Long id;

    @Column(name = "topic", length = 30)
    private String topic;

    @Column(name = "partition")
    private Integer partition;

    @Column(name = "group_id", length = 50)
    private String groupId;

    @Column(name = "source_system", length = 30)
    private String sourceSystem;

    @Column(name = "user_id", length = 50)
    private String userId;

    @Column(name = "payload")
    private String payload;

    @Column(name = "created_in_utc")
    private LocalDateTime createdInUtc;
}
