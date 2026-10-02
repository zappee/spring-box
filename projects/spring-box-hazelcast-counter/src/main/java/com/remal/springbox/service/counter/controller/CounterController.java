/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Spring REST endpoint.
 */
package com.remal.springbox.service.counter.controller;

import com.remal.springbox.commons.monitoring.MethodStatistics;
import com.remal.springbox.service.counter.configuration.HazelcastMapsConfiguration;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

@Slf4j
@AllArgsConstructor
@RestController
@RequestMapping("/api/counter")
public class CounterController {

    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyy-MM-dd HH:mm:ss");

    private final HazelcastMapsConfiguration hazelcastMaps;

    @GetMapping("/show/{username}")
    @MethodStatistics
    public String showCurrentState(@PathVariable("username") String username) {
        var now = LocalDateTime.now().format(DATE_TIME_FORMATTER);
        var counters = hazelcastMaps.counterMap();
        var counter = counters.get(username);
        var response = String.format("Value of the counter for user <b>%s</b> is <b>%s</b>.", username, counter);

        return String.format("%s<br>%s", now, response);
    }

    @GetMapping("/update/{username}")
    @MethodStatistics
    public String updateCurrentState(@PathVariable("username") String username) {
        var now = LocalDateTime.now().format(DATE_TIME_FORMATTER);
        var counters = hazelcastMaps.counterMap();
        var counter = counters.get(username);

        if (Objects.isNull(counter)) {
            counter= 1;
        } else {
            counter++;
        }

        var response = String.format("Updating the counter for user <b>%s</b> to <b>%s</b>.", username, counter);
        counters.put(username, counter);

        return String.format("%s<br>%s", now, response);
    }
}
