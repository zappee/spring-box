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
package com.remal.springbox.kafka.player;

import com.remal.springbox.kafka.player.picocli.command.PlayCommand;
import com.remal.springbox.kafka.player.picocli.renderer.CustomOptionRenderer;
import picocli.CommandLine;

/**
 * Application entry point.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
class Application {

    /**
     * Application entry point.
     *
     * @param args command line parametersprovided by the user
     */
    public static void main(String... args) {
        CommandLine cmd = new CommandLine(new PlayCommand());
        cmd.setHelpFactory(new CustomOptionRenderer());
        int exitCode = cmd.execute(args);
        System.exit(exitCode);
    }
}
