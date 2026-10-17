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
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Picocli command group.
 */
package com.remal.springbox.kafka.player.picocli.param;


import lombok.Getter;
import picocli.CommandLine;

/**
 * SQL password argument group.
 */
/**
 * Custom annotation to log the method execution time.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Getter
public class SqlPasswordGroup {
    @CommandLine.Option(
            names = {"-S", "--sql-password"},
            required = true,
            description = "Password for the connecting user.")
    private String password;

    @CommandLine.Option(
            names = {"-I", "--sql-iPassword"},
            required = true,
            interactive = true,
            description = "Interactive way to get the password for the connecting user.")
    private String interactivePassword;
}
