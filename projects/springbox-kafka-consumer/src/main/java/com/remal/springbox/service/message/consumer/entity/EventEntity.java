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
package com.remal.springbox.service.message.consumer.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * JPA entity.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
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
