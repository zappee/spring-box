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
package com.remal.springbox.kafka.player.picocli.param;

import lombok.Getter;
import picocli.CommandLine;

/**
 * Picocli Command Line Interface (CLI) definition.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
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
