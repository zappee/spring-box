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
package com.remal.springbox.service.message.consumer.repository;

import com.remal.springbox.service.message.consumer.entity.EventEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Class to manage database operations.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Repository
public interface EventRepository extends JpaRepository<EventEntity, Long> {

    @Query("SELECT COUNT(e.id) FROM EventEntity e")
    Long countById();

    @Query("SELECT e FROM EventEntity e ORDER BY e.id DESC LIMIT 20")
    List<EventEntity> findLast20();
}
