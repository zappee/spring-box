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

import org.springframework.boot.ssl.SslBundles;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * HTTPS configuration for REST endpoints.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Configuration
public class RestTemplateConfiguration {

    private static final String SSL_BUNDLE_ID = "rest-template";

    /**
     * Rest template configuration for HTTPS.
     *
     * @return restTemplate instance
     */
    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder, SslBundles sslBundles) {
        return builder.sslBundle(sslBundles.getBundle(SSL_BUNDLE_ID)).build();
    }
}
