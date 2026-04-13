---
name: flutter-logging
description: Logging patterns for generated Flutter projects — AppLogger, Dio log interceptor, and console output conventions
---

# Flutter Logging Pattern

Use this skill when modifying `loggerHelperTemplate` or `logInterceptorTemplate` in `lib/src/templates/`, or when adding logging to any generated code.

## AppLogger (logger_helper.dart)

The logger is a zero-dependency static class using only `debugPrint` from Flutter foundation. It does NOT use the `logger` package.

### General Methods
- `AppLogger.debug(msg)` — blue dot, single line
- `AppLogger.info(msg)` — blue circle, single line
- `AppLogger.warning(msg)` — boxed with `┌─┐` border
- `AppLogger.error(msg, [error, stackTrace])` — boxed with `┌─┐`, filters stack frames (excludes `dart:`, `flutter/`, `bloc/`, `dio/`), max 5 frames
- `AppLogger.verbose(msg)` — white circle, single line

### API Methods
- `AppLogger.apiRequest(method, uri, headers?, queryParams?, body?)` — double-line `╔═╗` box, masks authorization headers (first 15 chars), pretty-prints JSON body
- `AppLogger.apiResponse(method, path, statusCode, elapsedMs, body?)` — single-line `┌─┐` box with elapsed time
- `AppLogger.apiError(method, path, statusCode, elapsedMs, body?, errorMessage?)` — bold `┏━┛` box with elapsed time

### Rules
- All logging gated behind `kDebugMode` — zero overhead in release builds
- Use `debugPrint` not `print` (avoids dropped lines on Android)
- JSON bodies are pretty-printed with 2-space indent via `JsonEncoder.withIndent`
- Authorization header values are truncated to 15 chars + `...`
- Never add the `logger` package to pubspec — this is intentionally dependency-free

## LoggingInterceptor (log_interceptor.dart)

A Dio `Interceptor` that delegates all output to `AppLogger` API methods.

### Key patterns
- Tracks request start timestamps in `_timestamps` map keyed by `options.hashCode`
- Calculates elapsed time on response/error via `_elapsed()` helper
- Extracts error messages smartly: checks `response.data.error.message`, then `response.data.message`, then `err.message`
- Registered in ApiService after AuthInterceptor, before Chucker (dev only)

### Interceptor order in ApiService
```
1. AuthInterceptor (adds Bearer token, handles 401 refresh)
2. LoggingInterceptor (logs request/response/error)
3. ChuckerDioInterceptor (dev flavor only)
```
