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
package com.remal.springbox.service.welcome.configuration;

import com.remal.springbox.commons.spring.discovery.ConsulServiceDiscovery;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Consul service discovery configuration.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Configuration
public class ServiceDiscoveryConfiguration {

    @Bean
    public ConsulServiceDiscovery initialize(DiscoveryClient discoveryClient) {
        return new ConsulServiceDiscovery(discoveryClient);
    }
}
