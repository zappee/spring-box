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
package com.remal.springbox.kafka.player.commons;

import java.io.OutputStream;
import java.io.PrintStream;

/**
 * This is a replacement of the standard Java System.out stream, will print
 * everything to dev/null. Used in quiet mode.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
public final class NullPrintStream {

    /**
     * Print stream that  prints to dev/null.
     *
     * @return the dev/null print stream
     */
    public static PrintStream getPrintStream() {
        return new PrintStream(new OutputStream() {
            public void write(int b) {
                // do nothing
            }
        });
    }

    /**
     * Utility classes should not have a public or default constructor.
     */
    private NullPrintStream() {
    }
}
