/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     A simple sql query executor.
 */
package com.remal.springbox.kafka.player.sql;

import com.remal.springbox.kafka.player.commons.MapConverter;
import com.remal.springbox.kafka.player.commons.NullPrintStream;
import com.remal.springbox.kafka.player.kafka.KafkaSender;
import com.remal.springbox.kafka.player.picocli.param.KafkaConnectionGroup;
import com.remal.springbox.kafka.player.picocli.param.SqlConnectionGroup;

import java.io.PrintStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.IntStream;

public class SqlExecutor {

    private final boolean dryRun;
    private final SqlConnectionGroup sqlParams;
    private final PrintStream logWriter;
    private final KafkaSender kafkaSender;

    public SqlExecutor(boolean quiet, boolean dryRun, SqlConnectionGroup sqlParams, KafkaConnectionGroup kafkaParams) {
        this.dryRun = dryRun;
        this.sqlParams = sqlParams;
        this.logWriter = quiet ? NullPrintStream.getPrintStream() : System.out;
        this.kafkaSender = new KafkaSender(quiet, kafkaParams);
    }

    public int execute() {
        var jdbcUrl = sqlParams
                .getSqlDialect()
                .getJdbcUrl(sqlParams.getSqlHost(), sqlParams.getSqlPort(), sqlParams.getSqlDatabase());
        var username = sqlParams.getSqlUser();
        var password = getPassword(sqlParams);
        var query = sqlParams.getSqlCommand();

        logWriter.printf("\nConnecting to %s using \"%s\" for username...\n", jdbcUrl, username);
        logWriter.printf("Query to execute: \"%s\"\n", query);

        if (!dryRun) {
            logWriter.printf("Connecting to Kafka using \"%s\"...\n", kafkaSender.getBootstrapServers());
            kafkaSender.connect();
        }

        try (Connection connection = DriverManager.getConnection(jdbcUrl, username, password);
             PreparedStatement preparedStatement = connection.prepareStatement(query)) {

            AtomicLong recordIndex = new AtomicLong();
            ResultSet rs = preparedStatement.executeQuery();
            ResultSetMetaData metadata = rs.getMetaData();
            int columnsNumber = metadata.getColumnCount();

            Map<String, String> records = new LinkedHashMap<>();
            while (rs.next()) {
                IntStream.rangeClosed(1, columnsNumber).forEach(columnId -> {
                    try {
                        records.put(metadata.getColumnName(columnId), rs.getString(columnId));
                    } catch (SQLException e) {
                        throw new RuntimeException(e);
                    }
                });
                logWriter.printf("%6d: %s\n", recordIndex.incrementAndGet(), MapConverter.toString(records));

                if (!dryRun) {
                    var key = getValueByMapIndex(records, 1);
                    var message = getValueByMapIndex(records, 2);
                    logWriter.printf("        sending a message to Kafka topic: %s : %s\n\n", key, message);
                    kafkaSender.send(key, message);
                }
            }

            if (!dryRun) {
                if (recordIndex.get() > 0) {
                    logWriter.printf("%d messages has been inserted into the Kafka topic.\n", recordIndex.get());
                }
                logWriter.print("Closing the Kafka connection...\n\n");
                kafkaSender.disconnect();
            }

            return 0;

        } catch (Exception e) {
            logWriter.printf("Error while trying to run the tool. Reason: %s\n", e.getMessage());
            return 1;
        }
    }

    private String getPassword(SqlConnectionGroup params) {
        var sqlPasswords = params.getSqlPasswords();
        if (Objects.nonNull(sqlPasswords)) {
            return Objects.nonNull(sqlPasswords.getPassword())
                    ? sqlPasswords.getPassword()
                    : sqlPasswords.getInteractivePassword();
        }
        return null;
    }

    private String getValueByMapIndex(Map<String, String> entries, int expectedMapIndex) {
        String result = null;
        int currentMapIndex = 1;
        for (String value : entries.values()) {
            if (currentMapIndex == expectedMapIndex) {
                result = value;
            }
            currentMapIndex++;
        }
        return result;
    }
}
