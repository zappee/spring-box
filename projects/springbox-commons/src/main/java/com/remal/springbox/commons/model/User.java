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
package com.remal.springbox.commons.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * Plain Old Java Object (POJO) serving as a simple data container.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class User {
    private String username;
    private String firstName;
    private String email;
    private String description;
}
