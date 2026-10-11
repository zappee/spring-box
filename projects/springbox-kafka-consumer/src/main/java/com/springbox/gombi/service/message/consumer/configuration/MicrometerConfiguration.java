/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Application monitoring with Micrometer.
 */
package com.remal.springbox.service.message.consumer.configuration;

import com.remal.springbox.commons.Internet;
import io.micrometer.core.instrument.Metrics;
import io.micrometer.core.instrument.composite.CompositeMeterRegistry;
import org.springframework.boot.info.BuildProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

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
