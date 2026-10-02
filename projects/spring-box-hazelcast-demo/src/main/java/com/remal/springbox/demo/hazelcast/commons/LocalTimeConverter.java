/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Hazelcast Java demo: LocalTime converters.
 */
package com.remal.springbox.demo.hazelcast.commons;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

public class LocalTimeConverter {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");

    public static String nowAsString() {
        return FORMATTER.format(LocalTime.now());
    }
}
