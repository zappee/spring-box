/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     java.time.Instant converters.
 */
package com.remal.springbox.commons.converter;

import java.time.Instant;
import java.util.Objects;

public class InstantConverter {

    public static Instant toInstant(Long millisecond) {
        if (Objects.isNull(millisecond)) {
            return null;
        }
        return Instant.ofEpochMilli(millisecond);
    }
}
