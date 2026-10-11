/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Service discovery.
 */
package com.remal.springbox.service.message.producer.configuration;

import com.remal.springbox.commons.spring.discovery.ConsulServiceDiscovery;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ServiceDiscoveryConfiguration {

    @Bean
    public ConsulServiceDiscovery initialize(DiscoveryClient discoveryClient) {
        return new ConsulServiceDiscovery(discoveryClient);
    }
}
