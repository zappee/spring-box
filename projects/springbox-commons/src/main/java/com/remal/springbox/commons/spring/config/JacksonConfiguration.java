/*
 * Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 * Since:  March 2025
 * Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 * Description:
 *    Configuration of the JSON serializer.
 */
package com.remal.springbox.commons.spring.config;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JacksonConfiguration {

    /**
     * Hide or exclude null values from the JSON response.
     *
     * @return jackson mapper instance
     */
    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
        objectMapper.registerModule(new JavaTimeModule());
        return objectMapper;
    }
}
