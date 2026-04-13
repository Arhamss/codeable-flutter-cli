---
name: api-response-parser
description: API response parsing pattern for generated Flutter projects — ApiResponseParser with parse, parseList, and parseValue
---

# API Response Parser Pattern

Use this skill when modifying `apiResponseParserTemplate` in `lib/src/templates/utils_templates.dart`, or when writing repository implementations in generated projects.

## Expected API Response Shape

All backend responses follow this envelope:
```json
{
  "data": { ... }       // single object or list
  "message": "..."      // optional
}
```

## ApiResponseParser Methods

### `_extractData(response)` (private)
Extracts `response.data['data']` as `Map<String, dynamic>`. Returns null if shape doesn't match.

### `parse<T>(response, fromJson, {key?})`
Parse a single object from the response.
- Without `key`: parses `response.data['data']` directly
- With `key`: parses `response.data['data'][key]` (nested object)

### `parseList<T>(response, fromJson, {key?})`
Parse a list of objects from the response.
- Without `key`: expects `response.data['data']` to be a `List`
- With `key`: expects `response.data['data'][key]` to be a `List`
- Silently skips items that fail `fromJson` (returns null, filtered out)

### `parseValue<T>(response, key)`
Extract a single primitive value from `response.data['data'][key]`. Useful for responses like `{"data": {"count": 42}}`.

## Usage in Repositories

```dart
// Single object
final user = ApiResponseParser.parse(response, UserModel.fromJson);

// Nested object
final profile = ApiResponseParser.parse(response, ProfileModel.fromJson, key: 'profile');

// List
final users = ApiResponseParser.parseList(response, UserModel.fromJson);

// Nested list
final items = ApiResponseParser.parseList(response, ItemModel.fromJson, key: 'items');

// Single value
final count = ApiResponseParser.parseValue<int>(response, 'total_count');
```

## Rules
- Always use `ApiResponseParser` in repository implementations — don't manually dig into `response.data`
- The parser is null-safe throughout — returns `null` or `[]` on shape mismatch, never throws
- `parseList` catches and skips individual item deserialization failures
