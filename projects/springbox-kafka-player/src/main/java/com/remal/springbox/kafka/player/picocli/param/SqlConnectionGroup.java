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

import com.remal.springbox.kafka.player.commons.SqlDialect;
import lombok.Getter;
import picocli.CommandLine;

/**
 * SQL connection parameters group.
 */
@Getter
public class SqlConnectionGroup {
    @CommandLine.Option(
            names = {"-A", "--sql-dialect"},
            defaultValue = SqlDialect.POSTGRES_DIALECT,
            description = "Sql dialect using to read persisted messages from the database. "
                    + "Candidates: ${COMPLETION-CANDIDATES}. Default: ${DEFAULT-VALUE}")
    private SqlDialect sqlDialect;

    @CommandLine.Option(
            names = {"-H", "--sql-host"},
            description = "Hostname of the database server. Default: ${DEFAULT-VALUE}",
            required = true,
            defaultValue = "localhost")
    private String sqlHost;

    @CommandLine.Option(
            names = {"-P", "--sql-port"},
            description = "Number of the port where the database server listens for requests. Default: ${DEFAULT-VALUE}",
            required = true,
            defaultValue = "5432")
    private int sqlPort;

    @CommandLine.Option(
            names = {"-D", "--sql-database"},
            required = true,
            description = "Name of the particular database on the server.")
    private String sqlDatabase;

    @CommandLine.Option(
            names = {"-C", "--sql-command"},
            required = true,
            description = "Sql query to get the messages from the database. "
                    + "The query must return a minimum of two columns. "
                    + "The first column becomes the Kafka key, the second is the message. "
                    + "E.g.: SELECT user_id, payload FROM event WHERE topic = 'incoming' and created_in_utc BETWEEN '2025-03-01 00:00:00' AND '2025-03-01 23:59:59' ORDER BY id")
    private String sqlCommand;

    @CommandLine.Option(
            names = {"-U", "--sql-user"},
            required = true,
            description = "Name for the login.")
    private String sqlUser;

    @CommandLine.ArgGroup(multiplicity = "1")
    SqlPasswordGroup sqlPasswords;
}
