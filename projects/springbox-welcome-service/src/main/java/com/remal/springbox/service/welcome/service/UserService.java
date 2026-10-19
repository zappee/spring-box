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
package com.remal.springbox.service.welcome.service;

import com.remal.springbox.commons.model.User;
import com.remal.springbox.commons.spring.discovery.ConsulServiceDiscovery;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestTemplate;

import java.net.URI;

/**
 * User service implementation.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Service
public class UserService {
    private final ConsulServiceDiscovery serviceDiscovery;
    private final RestTemplate restTemplate;

    /**
     * Constructor with object injections.
     *
     * @param serviceDiscovery object to be injected by spring
     */
    public UserService(ConsulServiceDiscovery serviceDiscovery, RestTemplate restTemplate) {
        this.serviceDiscovery = serviceDiscovery;
        this.restTemplate = restTemplate;
    }

    public User getUser(String userId) {
        URI uri = getServiceUri().resolve("/api/user/" + userId);
        RestClient restClient = RestClient.create(restTemplate);
        return restClient.get().uri(uri).retrieve().body(User.class);
    }

    private URI getServiceUri() {
        return serviceDiscovery.getServiceUri("springbox-user-service");
    }
}
