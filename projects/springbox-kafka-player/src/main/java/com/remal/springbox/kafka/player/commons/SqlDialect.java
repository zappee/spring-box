/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Supported SQL dialects.
 */
package com.remal.springbox.kafka.player.commons;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

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
