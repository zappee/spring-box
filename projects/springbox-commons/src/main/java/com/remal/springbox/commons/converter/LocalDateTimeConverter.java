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
package com.remal.springbox.commons.converter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

/**
 * Type converters for handling {@link LocalDateTime} values.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
public class LocalDateTimeConverter {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

    public static String toString(LocalDateTime dateTime) {
        if (Objects.isNull(dateTime)) {
            return "null";
        }
        return dateTime.format(FORMATTER);
    }
}
