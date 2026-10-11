/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
 *
 *  Since:  March 2024
 *  Author: Arnold Somogyi <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Hostname and IP utils..
 */
package com.remal.springbox.commons;

import java.net.InetAddress;
import java.net.UnknownHostException;

public class Internet {

    public static String getHostname() {
        String hostname;
        try {
            hostname = InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            hostname = "unknown";
        }
        return hostname;
    }
}
