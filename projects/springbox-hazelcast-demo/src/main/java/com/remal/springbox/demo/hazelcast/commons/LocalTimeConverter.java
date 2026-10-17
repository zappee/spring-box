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
package com.remal.springbox.demo.hazelcast.commons;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Type converters for handling {@link LocalTime} values.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
public class LocalTimeConverter {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");

    public static String nowAsString() {
        return FORMATTER.format(LocalTime.now());
    }
}
