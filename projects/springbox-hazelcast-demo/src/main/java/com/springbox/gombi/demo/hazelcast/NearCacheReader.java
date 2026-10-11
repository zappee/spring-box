/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Hazelcast Java demo: Near cache reader Java application.
 *
 *     The Near Cache ID refers to the identifier of a Near Cache configuration. When
 *     you create a NearCacheConfig using new NearCacheConfig(id), you are defining a
 *     caching layer that sits on the client side, allowing for faster access to frequently
 *     used data. The Near Cache ID is used to configure and manage the Near Cache
 *     associated with a specific distributed map. The Near Cache stores a local copy of the
 *     data for quick access, reducing the need to fetch data from the distributed map for
 *     frequently accessed entries.
 *
 *     The map ID refers to the identifier of a distributed map in Hazelcast. When you
 *     create or access a map using HazelcastInstance.getMap(id), you are interacting with a
 *     distributed data structure that is managed by the Hazelcast cluster. The map ID is
 *     used to perform operations on the distributed map, such as adding, retrieving, or
 *     removing entries. The data in the map is stored across the nodes in the Hazelcast
 *     cluster, allowing for distributed data management and scalability.
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

    private static final EntryAdapter<String, Integer> entryAdapter = new EntryAdapter<String, Integer>() {
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
