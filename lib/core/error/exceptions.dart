/// Exception thrown when a local data storage operation fails.
class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'A local database error occurred.']);

  @override
  String toString() => message;
}
