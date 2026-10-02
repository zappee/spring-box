/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Picocli command.
 */
package com.remal.springbox.kafka.player.picocli.command;

import com.remal.springbox.kafka.player.picocli.param.KafkaConnectionGroup;
import com.remal.springbox.kafka.player.picocli.param.SqlConnectionGroup;
import com.remal.springbox.kafka.player.sql.SqlExecutor;
import picocli.CommandLine;
import picocli.CommandLine.ArgGroup;
import picocli.CommandLine.Command;

import java.util.concurrent.Callable;

@Command(
        name = "play", mixinStandardHelpOptions = true,
        usageHelpWidth = 100,
        sortOptions = false,
        header = {
                "@|bold,yellow ______ _______ _______ _______|@",
                "@|bold,yellow |_____/ |______ |  |  | |_____| ||@",
                "@|bold,yellow |    \\_ |______ |  |  | |     | |_____|@",
                "@|bold,yellow _______  _____  _______ _______ _  _  _ _______  ______ _______|@",
                "@|bold,yellow |______ |     | |______    |    |  |  | |_____| |_____/ |______|@",
                "@|bold,yellow ______| |_____| |          |    |__|__| |     | |    \\_ |______|@%n",
                "@|yellow :: remal-kafka-player :: 0.7.1 ::|@",
                "@|yellow Copyright (c) 2020-2026 REMAL SOFTWARE and Arnold SOMOGYI All rights reserved|@",
                "%n"},
        description = "Re-inject saved messages to a Kafka topic.%n",

        parameterListHeading = "General options:%n",
        exitCodeListHeading = "%nExit codes:%n",
        exitCodeList = {
                "0:Successful program execution.",
                "1:An unexpected error appeared while executing the tool."},
        footerHeading = "%nPlease report issues at arnold.somogyi@gmail.com.",
        footer = "%nDocumentation, source code: https://github.com/zappee/springbox%n")
public class PlayCommand implements  Callable<Integer> {

    @CommandLine.Option(names = {"-q", "--quiet"},
            description = "In this mode nothing will be printed to the output.")
    private boolean quiet;

    @CommandLine.Option(names = {"-d", "--dry-run"},
            description = "Displays only the selected messages, but does not send them to the Kafka topic.")
    private boolean dryRun;

    @ArgGroup(
            exclusive = false,
            multiplicity = "1",
            heading = "%nDatabase connection parameters:%n")
    private SqlConnectionGroup sqlParams;

    @ArgGroup(
            exclusive = false,
            multiplicity = "1",
            heading = "%nKafka connection parameters:%n")
    private KafkaConnectionGroup kafkaParams;

    @Override
    public Integer call() throws Exception {
        SqlExecutor executor = new SqlExecutor(quiet, dryRun, sqlParams, kafkaParams);
        return executor.execute() ;
    }
}
