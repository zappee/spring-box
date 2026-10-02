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

import lombok.Getter;
import picocli.CommandLine;

/**
 * Kafka connection parameters group.
 */
@Getter
public class KafkaConnectionGroup {

    @CommandLine.Option(
            names = {"-k", "--kafka-host"},
            description = "Hostname of the Kafka server. Default: ${DEFAULT-VALUE}",
            required = true,
            defaultValue = "localhost")
    private String kafkaHost;

    @CommandLine.Option(
            names = {"-o", "--kafka-port"},
            description = "Number of the port where the Kafka server listens for requests. Default: ${DEFAULT-VALUE}",
            required = true,
            defaultValue = "9093")
    private Integer kafkaPort;

    @CommandLine.Option(
            names = {"-t", "--kafka-topic"},
            required = true,
            description = "Name of the Kafka topic to send messages to.")
    private String kafkaTopic;
}
