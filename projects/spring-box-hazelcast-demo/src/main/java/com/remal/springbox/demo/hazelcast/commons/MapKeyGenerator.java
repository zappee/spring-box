/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Hazelcast Java demo: Key generator used for java.util.Map.
 */
package com.remal.springbox.demo.hazelcast.commons;

public class MapKeyGenerator {

    public static String getKey(String username) {
        return String.format("counter-%s", username);
    }
}
