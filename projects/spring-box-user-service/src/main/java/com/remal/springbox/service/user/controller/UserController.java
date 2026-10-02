/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2024
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Spring REST endpoint.
 */
package com.remal.springbox.service.user.controller;

import com.remal.springbox.commons.exception.EntryNotExistException;
import com.remal.springbox.commons.model.User;
import com.remal.springbox.commons.monitoring.MethodStatistics;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Objects;

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
