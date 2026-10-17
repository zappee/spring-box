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
package com.remal.springbox.commons.spring.discovery;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.DiscoveryClient;

import java.net.URI;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

/**
 * Consul service discovery implementation.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
public class ConsulServiceDiscovery {

    private final DiscoveryClient discoveryClient;

    /**
     * Constructor with object injections.
     *
     * @param discoveryClient object to be injected by spring
     */
    public ConsulServiceDiscovery(DiscoveryClient discoveryClient) {
        this.discoveryClient = discoveryClient;
    }

    public URI getServiceUri(String serviceId) {
        log.debug("getting service URIs for {}...", serviceId);

        List<ServiceInstance> serviceInstances = discoveryClient.getInstances(serviceId);
        var serviceUris = serviceInstances.size();
        if (serviceUris == 0) {
            var message = String.format("No service URL registered in the service-registry for \"%s\".", serviceId);
            throw new IllegalArgumentException(message);
        } else {
            log.debug("service URIs for {}: {}",
                    serviceId,
                    serviceInstances.stream().map(x -> x.getUri().toString()).collect(Collectors.joining(", ")));

            int randomIndex = ThreadLocalRandom.current().nextInt(serviceInstances.size());
            URI uri = serviceInstances.get(randomIndex).getUri();
            log.info("selected URI for {} is {}", serviceId, uri);
            return uri;
        }
    }
}
