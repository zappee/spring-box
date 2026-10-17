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


/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Spring application entry point.
 */
package com.remal.springbox.service.message.consumer;

import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.annotation.ComponentScan;

/**
 * Custom annotation to log the method execution time.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@SpringBootApplication
@ComponentScan({"com.remal.springbox.service.message.consumer", "com.remal.springbox.commons.spring"})
public class Application {

    public static void main(String[] args) {
        new SpringApplicationBuilder(Application.class).web(WebApplicationType.SERVLET).run(args);
    }
}
