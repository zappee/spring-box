/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
 *
 *  Since:  March 2024
 *  Author: Arnold Somogyi <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     A simple POJO.
 */
package com.remal.springbox.commons.model;

import lombok.*;

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
