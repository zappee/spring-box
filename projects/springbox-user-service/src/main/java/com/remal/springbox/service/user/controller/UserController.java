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
package com.remal.springbox.service.user.controller;

import com.remal.springbox.commons.exception.EntryNotExistException;
import com.remal.springbox.commons.model.User;
import com.remal.springbox.commons.monitoring.MethodStatistics;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Objects;

/**
 * REST endpoint implementation.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
@RestController
@RequestMapping("/api/user")
public class UserController {

    private static final HashMap<String, User> users = new HashMap<>();

    @GetMapping("/{username}")
    @MethodStatistics
    public User getUserByUsername(@PathVariable("username") String username) {
        var user = users.get(username);
        if (Objects.isNull(user)) {
            throw new EntryNotExistException(User.class, "username", username);
        }
        return user;
    }

    @PostMapping("/")
    @MethodStatistics
    public void saveUser(@RequestBody User user) {
        users.put(user.getUsername(), user);
    }
}
