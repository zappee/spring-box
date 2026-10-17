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
package com.remal.springbox.service.counter.configuration;

import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;
import com.remal.springbox.service.counter.haselcast.HazelcastCounterMapListener;
import com.remal.springbox.service.counter.service.MicrometerMeterService;
import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Map;

/**
 * Hazelcast IMap data type configuration.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Configuration
@AllArgsConstructor
public class HazelcastMapsConfiguration {

    private final HazelcastInstance hazelcastClient;
    private final MicrometerMeterService meterService;

    @Bean
    public Map<String, Integer> counterMap() {
        IMap<String, Integer> counters = hazelcastClient.getMap(HazelcastGlobalConfiguration.COUNTER_MAP_ID);
        counters.addEntryListener(new HazelcastCounterMapListener(meterService), true);
        return counters;
    }
}
