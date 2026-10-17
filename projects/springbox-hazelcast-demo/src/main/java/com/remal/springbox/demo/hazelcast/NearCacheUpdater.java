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
package com.remal.springbox.demo.hazelcast;

import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;
import com.remal.springbox.demo.hazelcast.commons.HazelcastConfiguration;
import com.remal.springbox.demo.hazelcast.commons.LocalTimeConverter;
import com.remal.springbox.demo.hazelcast.commons.MapKeyGenerator;

import java.util.Timer;
import java.util.TimerTask;

/**
 * Hazelcast near cache demo application.
 *
 * <p></p>The Near Cache ID refers to the identifier of a Near Cache configuration.
 * When you create a NearCacheConfig using new NearCacheConfig(id), you are
 * defining a caching layer that sits on the client side, allowing for faster
 * access to frequently used data.
 * The Near Cache ID is used to configure and manage the Near Cache associated
 * with a specific distributed map. The Near Cache stores a local copy of the
 * data for quick access, reducing the need to fetch data from the distributed
 * map for frequently accessed entries.</p>
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
public class NearCacheUpdater {

    public static void main(String[] args) {
        String username = "zappee";
        String key = MapKeyGenerator.getKey(username);

        HazelcastInstance hazelcastClient = HazelcastConfiguration.getHazelcastInstance();
        IMap<String, Integer> nearCache = hazelcastClient.getMap(HazelcastConfiguration.COUNTER_MAP_ID);
        nearCache.put(key, 1);

        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                int value = nearCache.get(key);
                value++;
                nearCache.put(key, value);

                System.out.printf(
                        "[%s] value in the cache has been updated: {username: \"%s\", new-value: %s}\n",
                        LocalTimeConverter.nowAsString(),
                        username,
                        value);
            }
        };

        // schedule the timer task to run after 1 second
        Timer timer = new Timer();
        timer.scheduleAtFixedRate(task, 0, 1000);
    }
}
