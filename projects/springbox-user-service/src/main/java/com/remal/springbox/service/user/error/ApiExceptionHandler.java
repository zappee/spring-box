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
package com.remal.springbox.service.user.error;

import com.remal.springbox.commons.exception.EntryNotExistException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

/**
 * Global Spring exception handler. It generates HTTP responses based on the
 * thrown exception.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@ControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(EntryNotExistException.class)
    public ResponseEntity<String> handleEntryNotExist(EntryNotExistException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
    }
}
