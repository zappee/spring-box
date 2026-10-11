/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Hazelcast listener configuration.
 */
package com.remal.springbox.service.counter.haselcast;

import com.hazelcast.core.EntryEvent;
import com.hazelcast.map.MapEvent;
import com.hazelcast.map.listener.EntryAddedListener;
import com.hazelcast.map.listener.EntryEvictedListener;
import com.hazelcast.map.listener.EntryLoadedListener;
import com.hazelcast.map.listener.EntryRemovedListener;
import com.hazelcast.map.listener.EntryUpdatedListener;
import com.hazelcast.map.listener.MapClearedListener;
import com.hazelcast.map.listener.MapEvictedListener;
import com.remal.springbox.service.counter.service.MicrometerMeterService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor
public class HazelcastCounterMapListener implements
        EntryAddedListener<String, Integer>,
        EntryRemovedListener<String, Integer>,
        EntryUpdatedListener<String, Integer>,
        EntryEvictedListener<String, Integer>,
        EntryLoadedListener<String,Integer>,
        MapEvictedListener,
        MapClearedListener {

    private final MicrometerMeterService meterService;

    @Override
    public void entryAdded(EntryEvent<String, Integer> event) {
        log.debug(
                "entry added: {map-alias-name: \"{}\", key: \"{}\", value: {}}",
                event.getName(),
                event.getKey(),
                event.getValue());
        meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
    }

    @Override
    public void entryRemoved(EntryEvent<String, Integer> event) {
        log.debug(
                "entry removed: {map-alias-name: \"{}\", key: \"{}\", value: {}}",
                event.getName(),
                event.getKey(),
                event.getValue());
        meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
    }

    @Override
    public void entryUpdated(EntryEvent<String, Integer> event) {
        log.debug(
                "entry updated: {map-alias-name: \"{}\", key: \"{}\", value: {}}",
                event.getName(),
                event.getKey(),
                event.getValue());
        meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
    }

    @Override
    public void entryEvicted(EntryEvent<String, Integer> event) {
        log.debug(
                "entry evicted: {map-alias-name: \"{}\", key: \"{}\", value: {}}",
                event.getName(),
                event.getKey(),
                event.getValue());
        meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
    }

    @Override
    public void entryLoaded(EntryEvent<String, Integer> event) {
        log.debug(
                "entry loaded: {map-alias-name: \"{}\", key: \"{}\", value: {}}",
                event.getName(),
                event.getKey(),
                event.getValue());
        meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
    }

    @Override
    public void mapEvicted(MapEvent event) {
        log.debug(
                "map evicted: {map-alias-name: \"{}\", affected-entries: {}}",
                event.getName(),
                event.getNumberOfEntriesAffected());
        meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
    }

    @Override
    public void mapCleared(MapEvent event) {
        log.debug(
                "map cleared: {map-alias-name: \"{}\", affected-entries: {}}",
                event.getName(),
                event.getNumberOfEntriesAffected());
        meterService.registerMapCacheEvent(event.getName(),event.getEventType().name());
    }
}
