/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// AppDimens 3.2 — smart and mathematically refined responsive dimensioning
/// for Flutter. Flutter port of the AppDimens Dynamic / KMP family.
library;

export 'appdimens_core.dart';
export 'src/flutter/app_dimens_provider.dart';
export 'src/internals/strategy_resolution.dart'
    show
        StrategyFormula,
        StrategyResolution,
        StrategyBranching,
        StrategyChain;
export 'src/scaled/dimen_sdp_extensions.dart';
export 'src/scaled/dimen_sdp_facade.dart';
export 'src/scaled/dimen_ssp_extensions.dart';
export 'src/scaled/dimen_scaled_builder.dart';

const String appDimensVersion = '3.2.0';
const String appDimensDescription =
    'AppDimens — responsive dimensioning with 12+ scaling strategies, '
    'snapshot cache and fast-lane resolution for Flutter.';
