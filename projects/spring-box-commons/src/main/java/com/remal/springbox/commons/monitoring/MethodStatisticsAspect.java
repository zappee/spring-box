/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  March 2024
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Custom annotation to log the execution time of a method.
 */
package com.remal.springbox.commons.monitoring;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.composite.CompositeMeterRegistry;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;

import java.util.Objects;
import java.util.concurrent.TimeUnit;

@Component
@Aspect
@Slf4j
public class MethodStatisticsAspect {

    enum ProceedStatus {
        ok, error
    }

    private static final String CALL_END_TEMPLATE = "< call ended: {name: {}, return: {}, execution-in-ms: {}}";

    private static final String METER_NAME_COUNTER = "remal_method_calls";
    private static final String METER_NAME_TIMER = "remal_method_execution_time";

    private final CompositeMeterRegistry meterRegistry;

    /**
     * Constructor.
     *
     * @param meterRegistry micrometer's meters registry
     */
    public MethodStatisticsAspect(CompositeMeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    @Around("@annotation(com.remal.springbox.commons.monitoring.MethodStatistics)")
    public Object aroundAdvice(ProceedingJoinPoint joinPoint) throws Throwable {
        long startInNano = System.nanoTime();
        long endInNano = -1;
        String className = joinPoint.getTarget().getClass().getSimpleName();
        String methodName = joinPoint.getSignature().getName();
        String fullQualifiedMethodName = className + "." + methodName;
        MethodStatistics annotationParams = ((MethodSignature) joinPoint.getSignature())
                .getMethod()
                .getAnnotation(MethodStatistics.class);

        try {
            // log arguments before the call
            var arguments = getArgumentsAsString(joinPoint);
            if (annotationParams.logToLogfile()) {
                if (arguments.isEmpty()) {
                    log.debug("> calling the {}()...", fullQualifiedMethodName);
                } else {
                    log.debug("> calling the {}() with parameters: {}...", fullQualifiedMethodName, arguments);
                }
            }

            // call the method
            Object o = joinPoint.proceed();

            // log the result of the call
            if (annotationParams.recordMethodCalls()) {
                registerMethodCall(fullQualifiedMethodName, ProceedStatus.ok);
            }

            if (annotationParams.logToLogfile()) {
                endInNano = System.nanoTime() - startInNano;
                var endInMilliseconds = TimeUnit.MILLISECONDS.convert(endInNano, TimeUnit.NANOSECONDS);

                var returnType = ((MethodSignature) joinPoint.getSignature()).getReturnType();
                var hasReturnType = !returnType.getTypeName().equals("void");

                log.debug(
                        CALL_END_TEMPLATE,
                        fullQualifiedMethodName,
                        hasReturnType ? getReturnValueAsString(o) : "void", endInMilliseconds);
            }
            return o;

        } catch(Throwable t) {
            if (annotationParams.recordMethodCalls()) {
                registerMethodCall(fullQualifiedMethodName, ProceedStatus.error);
            }
            throw t;
        } finally {
            if (annotationParams.recordExecutionTime()) {
                if (endInNano == -1) {
                    // an unexpected exception has appeared during the method call
                    endInNano = System.nanoTime() - startInNano;
                }
                registerMethodExecutionTime(fullQualifiedMethodName, endInNano);
            }
        }
    }

    private String getArgumentsAsString(ProceedingJoinPoint joinPoint) {
        StringBuilder sb = new StringBuilder();
        String[] argumentNames = ((MethodSignature) joinPoint.getSignature()).getParameterNames();
        Object[] argumentValues = joinPoint.getArgs();

        for (int i = 0; i < argumentNames.length; i++) {
            String argumentName = argumentNames[i];
            Object argumentValue = argumentValues[i];
            sb.append(String.format("[name: \"%s\", value: \"%s\"]", argumentName, argumentValue.toString()));
            if (i < argumentNames.length-1) {
                sb.append(", ");
            }
        }
        return sb.toString();
    }

    private String getReturnValueAsString(Object object) {
        if (Objects.nonNull(object)) {
            return switch (object) {
                case String value -> "\"" + value + "\"";
                case Integer value -> value.toString();
                default -> object.toString();
            };
        }
        return "<null>";
    }

    private void registerMethodExecutionTime(String id, long executionTimeInNano) {
        var endInMilliseconds = TimeUnit.MILLISECONDS.convert(executionTimeInNano, TimeUnit.NANOSECONDS);
        log.debug("registering the method execution time to Micrometer: "
                        + "{meter-name: \"{}\", method: \"{}\", execution-time-in-ms: {}}...",
                METER_NAME_TIMER, id, endInMilliseconds);
        Timer
                .builder(METER_NAME_TIMER)
                .tag("id", id)
                .description("Execution time of a Java method")
                .register(meterRegistry)
                .record(executionTimeInNano, TimeUnit.NANOSECONDS);
    }

    private void registerMethodCall(String id, ProceedStatus status) {
        log.debug("registering the method call to Micrometer: {meter-name: \"{}\", method: \"{}\", status: \"{}\"}",
                METER_NAME_COUNTER, id, status.name());
        Counter
                .builder(METER_NAME_COUNTER)
                .tags("id", id, "status", status.name())
                .description("Total number of the method calls")
                .register(meterRegistry)
                .increment();
    }
}
