import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Serves the Flutter web app's entry document at `/`.
///
/// Dart Frog's static handler serves explicit file paths (`/main.dart.js`,
/// `/index.html`, `/assets/...`) but not the bare directory root, so without
/// this route `/` 404s with "Route not found". Asset requests the shell
/// triggers (base href `/`) are still served by the static handler.
Future<Response> onRequest(RequestContext context) async {
  final indexHtml = File('public/index.html');
  if (!indexHtml.existsSync()) {
    return Response(
      statusCode: HttpStatus.notFound,
      body: 'App not staged. Run `flutter build web` and copy build/web/* '
          'into backend/public/.',
    );
  }
  return Response(
    body: await indexHtml.readAsString(),
    headers: {HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8'},
  );
}
