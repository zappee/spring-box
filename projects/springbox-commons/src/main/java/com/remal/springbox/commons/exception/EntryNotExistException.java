/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  January 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     This exception is thrown when a search operation result returns an
 *     empty/null element.
 */
package com.remal.springbox.commons.exception;

import lombok.extern.slf4j.Slf4j;

import java.util.Objects;

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
