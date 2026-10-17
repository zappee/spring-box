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
package com.remal.springbox.commons.model;

import com.remal.springbox.commons.converter.LocalDateTimeConverter;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Objects;

/**
 * Plain Old Java Object (POJO) serving as a simple data container.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Event {

    /**
     * The source system identifier that produced the message.
     */
    private String sourceSystem;

    /**
     * Identifier for the user who initialized the event.
     */
    private String userId;

    /**
     * The business content.
     */
    private String payload;

    /**
     * The creation time of the event in the UTC zone.
     */
    @Builder.Default
    private LocalDateTime createdInUtc = LocalDateTime.now(ZoneOffset.UTC);

    /**
     * Returns a string representation of the object.
     *
     * @return representation of the object
     */
    public String toString() {
        return "{userId: " + (Objects.isNull(userId) ? "null" : "\"" + userId) + "\", "
                + "sourceSystem: " + (Objects.isNull(sourceSystem) ? "null" : "\"" + sourceSystem) + "\", "
                + "payload: " + (Objects.isNull(payload) ? "null" : "\"" + payload) + "\", "
                + "createdInUtc: " + LocalDateTimeConverter.toString(createdInUtc);
    }
}
