/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2024
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Service discovery.
 */
package com.remal.springbox.service.welcome.service;

import com.remal.springbox.commons.model.User;
import com.remal.springbox.commons.spring.discovery.ConsulServiceDiscovery;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestTemplate;

import java.net.URI;

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
