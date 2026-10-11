/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     This is a replacement of the standard Java System.out stream, will
 *     print everything to dev/null. Used in quiet mode.
 */
package com.remal.springbox.kafka.player.commons;

import java.io.OutputStream;
import java.io.PrintStream;

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
