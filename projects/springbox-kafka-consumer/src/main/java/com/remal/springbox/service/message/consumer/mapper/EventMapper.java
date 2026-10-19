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
package com.remal.springbox.service.message.consumer.mapper;

import com.remal.springbox.commons.model.Event;
import com.remal.springbox.service.message.consumer.entity.EventEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/**
 * Object mapper configuration.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Mapper
public interface EventMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "topic", ignore = true)
    @Mapping(target = "partition", ignore = true)
    @Mapping(target = "groupId", ignore = true)
    @Mapping(target = "payload", ignore = true)
    EventEntity toEntity(Event pojo);
}
