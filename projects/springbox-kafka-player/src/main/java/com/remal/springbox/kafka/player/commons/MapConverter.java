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


/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     java.util.Map converters.
 */
package com.remal.springbox.kafka.player.commons;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.Map;

/**
 * Custom annotation to log the method execution time.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@RequiredArgsConstructor
@Getter
public class MapConverter {

    public static String toString(Map<String, String> map) {
        StringBuilder sb = new StringBuilder();
        map.forEach((key, value) ->
                sb
                        .append("\"").append(key).append("\"")
                        .append(": ")
                        .append("\"").append(value).append("\"")
                        .append(", ")
        );
        sb.setLength(sb.length() - 2);
        return sb.toString();
    }
}
