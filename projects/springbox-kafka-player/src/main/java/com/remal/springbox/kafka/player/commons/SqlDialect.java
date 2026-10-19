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

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * Supported SQL dialects definition.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@RequiredArgsConstructor
@Getter
public enum SqlDialect {

    POSTGRES(SqlDialect.POSTGRES_DIALECT, "jdbc:postgresql://$host:$port/$database");

    /**
     * String representation of the enum item, used by picocli.
     */
    public static final String POSTGRES_DIALECT = "POSTGRES";

    private final String value;
    private final String jdbcUrlTemplate;

    /**
     * Getter method, builds the JDBC URL based on the given values.
     *
     * @param host name of the database server
     * @param port number of the port where the server listens for requests
     * @param database name of the particular database on the server, also known as the SID in Oracle
     * @return the JDBC URL
     */
    public String getJdbcUrl(String host, int port, String database) {
        return jdbcUrlTemplate
                .replace("$host", host)
                .replace("$port", String.valueOf(port))
                .replace("$database", database);
    }
}
