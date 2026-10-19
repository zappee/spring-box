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
package com.remal.springbox.service.user.configuration;

import com.remal.springbox.commons.Internet;
import io.micrometer.core.instrument.Metrics;
import io.micrometer.core.instrument.composite.CompositeMeterRegistry;
import org.springframework.boot.info.BuildProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * Micrometer configuration.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Configuration
@ComponentScan("com.remal.springbox.commons.monitoring")
public class MicrometerConfiguration {

    private final BuildProperties buildProperties;

    public MicrometerConfiguration(BuildProperties buildProperties) {
        this.buildProperties = buildProperties;
    }

    @Bean
    public CompositeMeterRegistry buildMeterRegistry() {
        CompositeMeterRegistry registry = new CompositeMeterRegistry();
        registry.config().commonTags("project", buildProperties.getName());
        registry.config().commonTags("host", Internet.getHostname());
        Metrics.addRegistry(registry);
        return registry;
    }
}
