/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  July 2024
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     java.util.Date converters.
 */
package com.remal.springbox.commons.converter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

public class LocalDateTimeConverter {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

    public static String toString(LocalDateTime dateTime) {
        if (Objects.isNull(dateTime)) {
            return "null";
        }
        return dateTime.format(FORMATTER);
    }
}
