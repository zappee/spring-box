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
package com.remal.springbox.commons.exception;

import lombok.extern.slf4j.Slf4j;

import java.util.Objects;

/**
 * Thrown when a search operation returns an empty result or a {@code null}
 * element.
 *
 * <p>This exception indicates that the lookup succeeded structurally but
 * failed to find any matching records.</p>
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Slf4j
public class EntryNotExistException extends RuntimeException {

    /**
     * Constructor.
     *
     * @param clazz type of the result
     * @param field name of the field being searched
     * @param value identifier of the item you are looking for
     */
    public EntryNotExistException(Class<?> clazz, String field,  String value) {
        super(String.format(
                "The entry was not found: {class: \"%s\", field: \"%s\", value: \"%s\"}",
                Objects.isNull(clazz) ? "null" : clazz.getCanonicalName(),
                field,
                value));
        log.error(getMessage());
    }
}
