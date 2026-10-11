/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Application entry point.
 */
package com.remal.springbox.kafka.player;

import com.remal.springbox.kafka.player.picocli.command.PlayCommand;
import com.remal.springbox.kafka.player.picocli.renderer.CustomOptionRenderer;
import picocli.CommandLine;

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
