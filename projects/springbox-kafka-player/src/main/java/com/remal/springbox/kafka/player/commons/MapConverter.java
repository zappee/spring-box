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
