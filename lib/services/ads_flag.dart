import 'package:flutter/foundation.dart';

/// Global ad feature flag.
///
/// By default, ads are disabled in release builds.
///
/// TODO(geeks): Enable ads in release later by setting `--dart-define=ENABLE_ADS=true`
/// and revisiting the default behavior/rollout strategy.
final class AdsFlag {
  AdsFlag._();

  static const bool enabled = !kReleaseMode;
}
