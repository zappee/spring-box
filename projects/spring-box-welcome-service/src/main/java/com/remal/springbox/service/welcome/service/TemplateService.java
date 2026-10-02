/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  April 2024
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     This a Spring-Bean with RefreshScope that allows for beans to be
 *     refreshed dynamically at runtime. If a bean is refreshed then the next
 *     time the bean is accessed (i.e. call the getter method) a new instance
 *     is created.
 *
 *     Beans with @RefreshScope feature will be dynamically updated when a
 *     value in the Hashicorp Consul KV store has changed. This configuration
 *     keeps up-to-date the configuration values without restarting the spring
 *     boot application.
 *
 *     +1:
 *     Access to values from the VK store can be monitored by adding the
 *     @MethodStatistics annotation to the method. The statistics data is
 *     stored in Prometheus and can be viewed in Grafana.
 */
package com.remal.springbox.service.welcome.service;

import com.remal.springbox.commons.monitoring.MethodStatistics;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;

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
