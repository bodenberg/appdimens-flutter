/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Custom strategies demo (`appdimens_custom`): definition, presets, scope and
/// `explain()`.
library;

import 'package:appdimens_bom/appdimens_bom.dart';
import 'package:flutter/material.dart';

/// EN App-specific strategy: designed on a 360 dp phone, sublinear growth,
/// damped on tablets / desktop. Same JSON shape as every AppDimens platform.
final ScalingStrategy demoBrand = ScalingStrategy.define(
  'demoBrand',
  reference: ReferenceScreen(width: 360, height: 640),
  curve: ScalingCurve.power(0.8),
  minFactor: 0.85,
  maxFactor: 1.6,
  fontScale: FontScalePolicy.clamp(1.3),
  rules: [
    ScalingRule.on({
      DeviceClass.tablet,
      DeviceClass.desktop
    }, ScalingPatch(curve: ScalingCurve.logarithmic(0.4)), name: 'large'),
  ],
);

class CustomStrategyCard extends StatelessWidget {
  const CustomStrategyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ScalingStrategyScope(
      strategy: demoBrand,
      child: Builder(builder: (context) {
        return Card(
          color: const Color(0xFFF3E5F5),
          child: Padding(
            padding: EdgeInsets.all(context.cdp(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.explainScaling(),
                    style: TextStyle(fontSize: context.csp(11))),
                SizedBox(height: context.cdp(8)),
                Row(children: [
                  for (final s in [
                    demoBrand,
                    CustomPresets.tabletFriendly,
                    CustomPresets.gameHud,
                  ])
                    Padding(
                      padding: EdgeInsets.only(right: 8.cdpWith(s)),
                      child: Column(children: [
                        Container(
                            width: 48.cdpWith(s),
                            height: 48.cdpWith(s),
                            color: const Color(0xFF6A1B9A)),
                        Text(s.id, style: const TextStyle(fontSize: 10)),
                      ]),
                    ),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }
}
