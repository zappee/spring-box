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
package com.remal.springbox.service.counter.service;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.composite.CompositeMeterRegistry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * Micrometer meter implementation.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MicrometerMeterService {

    private final CompositeMeterRegistry meterRegistry;

    public void registerMapCacheEvent(String mapId, String event) {
        var counter = Counter
                .builder("remal_hazelcast")
                .tags("map-id", mapId, "event", event)
                .description("Hazelcast cache events")
                .register(meterRegistry);
        counter.increment();
    }
}
