/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Hazelcast cache configuration.
 */
package com.remal.springbox.service.counter.configuration;

import com.hazelcast.client.HazelcastClient;
import com.hazelcast.client.config.ClientConfig;
import com.hazelcast.config.EvictionConfig;
import com.hazelcast.config.EvictionPolicy;
import com.hazelcast.config.InMemoryFormat;
import com.hazelcast.config.NearCacheConfig;
import com.hazelcast.core.EntryAdapter;
import com.hazelcast.core.EntryEvent;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.MapEvent;
import com.remal.springbox.service.counter.service.MicrometerMeterService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;

@Configuration
@Slf4j
@RequiredArgsConstructor
public class HazelcastGlobalConfiguration {

    public static final String COUNTER_MAP_ID = "5-minutes-store";

    private final MicrometerMeterService meterService;

    // environment variables

    @Value("${HAZELCAST_CLUSTER_NAME}")
    private String clusterName;

    @Value("${HAZELCAST_CLUSTER_MEMBERS}")
    private String[] clusterMembers;

    @Bean
    public HazelcastInstance hazelcastClient() {
        HazelcastInstance client = HazelcastClient.newHazelcastClient(clientConfig());
        client.getMap(COUNTER_MAP_ID).addEntryListener(COUNTER_ENTRY_ADAPTER, true);
        return client;
    }

    private ClientConfig clientConfig() {
        log.debug("creating hazelcast ClientConfig: {cluster-name: \"{}\", members: {}}", clusterName, clusterMembers);
        ClientConfig clientConfig = new ClientConfig();
        clientConfig.setClusterName(clusterName);

        Arrays.stream(clusterMembers).forEach(memberName ->
                clientConfig.getNetworkConfig().getAddresses().add(memberName.trim()));

        clientConfig.addNearCacheConfig(shortLivedNearCacheConfig(COUNTER_MAP_ID));
        return clientConfig;
    }

    /**
     * Creates a new Hazelcast Near-Cache configuration.
     *
     * @param name the name of the Near Cache
     * @return the cache configuration instance
     */
    private NearCacheConfig shortLivedNearCacheConfig(String name) {
        return new NearCacheConfig(name)
                .setInMemoryFormat(InMemoryFormat.BINARY)


                // Limits the size of a map. If the size of the map grows larger than the limit, the eviction
                // policy defines which entries to remove from the map to reduce its size. You can configure
                // the size limit and eviction policy using the elements size and eviction-policy.
                .setEvictionConfig(new EvictionConfig()
                        .setEvictionPolicy(EvictionPolicy.LRU)
                        .setSize(1000))

                // This is relative to the time of a map’s last write.
                // For example a time to live (TTL) of 60 seconds means that an entry will be removed
                // if it is not written to at least every 60 seconds.
                //
                // Default value: 0 (disabled)
                .setTimeToLiveSeconds(30)

                // This is relative to the time of the last get(), put(), EntryProcessor.process() or containsKey()
                // method called on it. For example a setting of 60 seconds means that an entry will be removed
                // if it is not written to or read from at least every 60 seconds.
                //
                // Default value: 0 (disabled)
                .setMaxIdleSeconds(10);
    }

    private final EntryAdapter<String, Integer> COUNTER_ENTRY_ADAPTER = new EntryAdapter<>() {
        @Override
        public void entryAdded(EntryEvent<String, Integer> event) {
            log.debug("hazelcast cluster event >| a new entry added {map-id: \"{}\", key: \"{}\", value: {}}",
                    event.getName(),
                    event.getKey(),
                    event.getValue());
            meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
        }

        @Override
        public void entryUpdated(EntryEvent<String, Integer> event) {
            log.debug("hazelcast cluster event > entry updated {map-id: \"{}\", key: \"{}\", old-value: {}, new-value: {}}",
                    event.getName(),
                    event.getKey(),
                    event.getOldValue(),
                    event.getValue());
            meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
        }

        @Override
        public void entryRemoved(EntryEvent<String, Integer> event) {
            log.debug("hazelcast cluster event > entry removed: {map-id: \"{}\", key: \"{}\", value: {}}",
                    event.getName(),
                    event.getKey(),
                    event.getValue());
            meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
        }

        @Override
        public void entryExpired(EntryEvent<String, Integer> event) {
            log.debug("hazelcast cluster event > entry expired: {map-id: \"{}\", key: \"{}\"}",
                    event.getName(),
                    event.getKey());
            meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
        }

        @Override
        public void entryEvicted(EntryEvent<String, Integer> event) {
            log.debug("hazelcast cluster event > entry evicted: {map-id: \"{}\", key: \"{}\", value: {}}",
                    event.getName(),
                    event.getKey(),
                    event.getValue());
            meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
        }

        @Override
        public void mapCleared(MapEvent event) {
            log.debug("hazelcast cluster event > map cleared: {map-id: \"{}\"}", event.getName());
            meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
        }

        @Override
        public void mapEvicted(MapEvent event) {
            log.debug("hazelcast cluster event > map evicted: {map-name: \"{}\"}", event.getName());
            meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
        }
    };
}
