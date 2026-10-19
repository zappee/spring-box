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

import com.remal.springbox.commons.monitoring.MethodStatistics;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;

/**
 * <p>This a Spring-Bean with RefreshScope that allows for beans to be refreshed
 * dynamically at runtime. If a bean is refreshed then the next time the bean
 * is accessed (i.e. call the getter method) a new instance is created.</p>
 *
 * <p>Beans with @RefreshScope feature will be dynamically updated when a value in
 * the HashiCorp Consul KV store has changed. This configuration keeps
 * up-to-date the configuration values without restarting the spring boot
 * application.</p>
 *
 * <p>Access to values from the VK store can be monitored by adding the
 * @MethodStatistics annotation to the method. The statistics data is stored
 * in Prometheus and can be viewed in Grafana.</p>
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Component
@RefreshScope
@Slf4j
public class TemplateService {

    @Value("${template.welcome}")
    private String welcomeTemplate;

    @Value("${template.welcome-back}")
    private String welcomeBackTemplate;

    @MethodStatistics(logToLogfile = false)
    public String getWelcomeTemplate() {
        return welcomeTemplate;
    }

    @MethodStatistics(logToLogfile = false)
    public String getWelcomeBackTemplate() {
        return welcomeBackTemplate;
    }
}
