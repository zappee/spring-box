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

import com.hazelcast.core.EntryAdapter;
import com.hazelcast.core.EntryEvent;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;
import com.hazelcast.map.LocalMapStats;
import com.hazelcast.map.MapEvent;
import com.remal.springbox.demo.hazelcast.commons.HazelcastConfiguration;
import com.remal.springbox.demo.hazelcast.commons.LocalTimeConverter;
import com.remal.springbox.demo.hazelcast.commons.MapKeyGenerator;

import java.util.Objects;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Hazelcast near cache demo application.
 *
 * <p><strong>Near Cache ID:</strong> Represents the unique name of a Near
 * Cache configuration. When initializing a {@code NearCacheConfig(id)}, you
 * establish a localized client-side caching layer that accelerates access to
 * frequently read entries. This identifier binds the specific Near Cache
 * instance to its corresponding distributed map.</p>
 *
 * <p><strong>Map ID:</strong> Refers to the identifier of a distributed map
 * instance in Hazelcast. Invoking {@code HazelcastInstance.getMap(id)}
 * retrieves a cluster-managed, highly scalable data structure. Data within
 * this map is partitioned across cluster nodes to guarantee high availability
 * and fault tolerance.</p>
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
public class NearCacheReader {

     public static void main(String[] args) {
         String username = "zappee";
         String key = MapKeyGenerator.getKey(username);

        HazelcastInstance hazelcastClient = HazelcastConfiguration.getHazelcastInstance();

        IMap<String, Integer> nearCache = hazelcastClient.getMap(HazelcastConfiguration.COUNTER_MAP_ID);

         // registers a listener that is notified of events occurring on the map
         // across the entire Hazelcast cluster
         nearCache.addEntryListener(entryAdapter, true); // true to include initial values

         TimerTask task = new TimerTask() {
            @Override
            public void run() {
                LocalMapStats mapStatistics = nearCache.getLocalMapStats();
                boolean isNullNearCacheStat = Objects.isNull(mapStatistics.getNearCacheStats());

                Integer value = nearCache.get(key);
                if (Objects.isNull(value)) {
                    // cache miss
                    System.out.printf(
                            "[%s] near-cache    | entry does not exist in the cache: {map-id: \"%s\", key: \"%s\", cache-miss: %s, cache-hits: %s}%n",
                            LocalTimeConverter.nowAsString(),
                            HazelcastConfiguration.COUNTER_MAP_ID,
                            username,
                            isNullNearCacheStat ? "null" : mapStatistics.getNearCacheStats().getMisses(),
                            isNullNearCacheStat ? "null" : mapStatistics.getNearCacheStats().getHits());
                } else {
                    // cache hit
                    System.out.printf(
                            "[%s] near-cache    | get entry from the cache: {map-id: \"%s\", key: \"%s\", value: %s, cache-miss: %s, cache-hits: %s}%n",
                            LocalTimeConverter.nowAsString(),
                            HazelcastConfiguration.COUNTER_MAP_ID,
                            username,
                            value,
                            isNullNearCacheStat ? "null" : mapStatistics.getNearCacheStats().getMisses(),
                            isNullNearCacheStat ? "null" : mapStatistics.getNearCacheStats().getHits());
                }
            }
        };

        // schedule the timer task to run after 1 second
        Timer timer = new Timer();
        timer.scheduleAtFixedRate(task, 0, 1000);
    }

    private static final EntryAdapter<String, Integer> entryAdapter = new EntryAdapter<>() {
        @Override
        public void entryAdded(EntryEvent<String, Integer> event) {
            System.out.printf("[%s] cluster event | a new entry added {map-id: \"%s\", key: \"%s\", value: %s}\n",
                    LocalTimeConverter.nowAsString(),
                    event.getName(),
                    event.getKey(),
                    event.getValue());
        }

        @Override
        public void entryUpdated(EntryEvent<String, Integer> event) {
            System.out.printf("[%s] cluster event | entry updated {map-id: \"%s\", key: \"%s\", old-value: %s, new-value: %s}\n",
                    LocalTimeConverter.nowAsString(),
                    event.getName(),
                    event.getKey(),
                    event.getOldValue(),
                    event.getValue());
        }

        @Override
        public void entryRemoved(EntryEvent<String, Integer> event) {
            System.out.printf("[%s] cluster event | entry removed: {map-id: \"%s\", key: \"%s\", value: %s}\n",
                    LocalTimeConverter.nowAsString(),
                    event.getName(),
                    event.getKey(),
                    event.getValue());
        }

        @Override
        public void entryExpired(EntryEvent<String, Integer> event) {
            System.out.printf("[%s] cluster event | entry expired: {map-id: \"%s\", key: \"%s\"}\n",
                    LocalTimeConverter.nowAsString(),
                    event.getName(),
                    event.getKey());
        }

        @Override
        public void entryEvicted(EntryEvent<String, Integer> event) {
            System.out.printf("[%s] cluster event | entry evicted: {map-id: \"%s\", key: \"%s\", value: %s}\n",
                    LocalTimeConverter.nowAsString(),
                    event.getName(),
                    event.getKey(),
                    event.getValue());
        }

        @Override
        public void mapCleared(MapEvent event) {
            System.out.printf("[%s] cluster event | map cleared: {map-id: \"%s\"}\n",
                    LocalTimeConverter.nowAsString(),
                    event.getName());
        }

        @Override
        public void mapEvicted(MapEvent event) {
            System.out.printf("[%s] cluster event | map evicted: {map-name: \"%s\"}\n",
                    LocalTimeConverter.nowAsString(),
                    event.getName());
        }
    };
}
