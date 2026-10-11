/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Spring REST endpoint.
 */
package com.remal.springbox.service.message.consumer.controller;

import com.remal.springbox.commons.monitoring.MethodStatistics;
import com.remal.springbox.service.message.consumer.repository.EventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/kafka")
public class KafkaConsumerController {

    private final EventRepository eventRepository;

    @GetMapping("/events")
    @MethodStatistics
    public String showReceivedMessages() {
        var count = eventRepository.countById();

        StringBuilder sb = new StringBuilder()
                .append("<!DOCTYPE html>")
                .append("<html>")
                .append("<head>")
                .append("<style>")
                .append("table, th, td { border: 1px solid black; border-collapse: collapse; padding: 5px; text-align: center; font-family: \"Lucida Console\", \"Courier New\", monospace; }")
                .append("table.center { margin-left: auto; margin-right: auto; }")
                .append("</style>")
                .append("<meta charset=\"UTF-8\">")
                .append("<title>Kafka last 20 messages</title>")
                .append("</head>")
                .append("<body>")
                .append("<p align=\"center\">").append("records in the EVENT table: ").append(count).append("</p>")
                .append("<p align=\"center\">").append("showed only the last 20 records").append("</p>")
                .append("<table class=\"center\">")
                .append("<tr>")
                .append("<th>id</th>")
                .append("<th>topic</th>")
                .append("<th>partition</th>")
                .append("<th>group_id</th>")
                .append("<th>source_system</th>")
                .append("<th>user_id</th>")
                .append("<th>created_in_utc</th>")
                .append("<th>payload</th>")
                .append("</tr>");

        eventRepository.findLast20().forEach(event ->
                sb.append("<tr>")
                        .append("<td>").append(event.getId()).append("</td>")
                        .append("<td>").append(event.getTopic()).append("</td>")
                        .append("<td>").append(event.getPartition()).append("</td>")
                        .append("<td>").append(event.getGroupId()).append("</td>")
                        .append("<td>").append(event.getSourceSystem()).append("</td>")
                        .append("<td>").append(event.getUserId()).append("</td>")
                        .append("<td>").append(event.getCreatedInUtc()).append("</td>")
                        .append("<td>").append(event.getPayload()).append("</td>")
                        .append("</tr>"));

        sb.append("</table>")
                .append("<p align=\"center\">").append("records in the EVENT table: ").append(count).append("</p>")
                .append("<p align=\"center\">").append("showed only the last 20 records").append("</p>")
                .append("</body>")
                .append("</html>");

        return sb.toString();
    }
}
