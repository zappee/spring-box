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


/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  November 2024
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     A place for package-level documentation and package-level annotations.
 *
 *     Without this "Not annotated parameter overrides @NonNullApi parameter"
 *     warnings appear. Fixed this warning by adding a package-info.java in
 *     the same package where the class file is present.
 */
@NonNullApi
@NonNullFields
package com.remal.springbox.service.message.consumer.error;

import org.springframework.lang.NonNullApi;
import org.springframework.lang.NonNullFields;

/**
 * Custom annotation to log the method execution time.
 *
 * @author Arnold Somogyi <arnold.somogyi@gmail.com>
 */
