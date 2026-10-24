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

/// EN The simplest form: the formula you write is the value (`base` = the
/// value you pass). PT A forma mais simples: a fórmula é o valor.
final ScalingStrategy demoFormula =
    scalingFormula('base * (tablet ? 0.9 : 1) * clamp(sw / 360, 0.85, 1.6)');

/// EN Programmable factor in plain Dart: runs once per window, then one
/// multiply per value. PT Fator programável em Dart puro.
final ScalingStrategy demoProduct =
    customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.80));

/// EN Typed code formula (autocompleted scope); the text form is for JSON.
/// PT Fórmula em código tipada; a forma em texto é para JSON.
final ScalingStrategy demoCode =
    scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8));

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
                Wrap(children: [
                  for (final (label, s) in [
                    (demoBrand.id, demoBrand),
                    ('tabletFriendly', CustomPresets.tabletFriendly),
                    ('gameHud', CustomPresets.gameHud),
                    ('formula', demoFormula),
                    ('factor', demoProduct),
                    ('code', demoCode),
                    // EN Inline: the formula is the value (shared per text).
                    // PT Inline: a fórmula é o valor.
                    (
                      'inline',
                      ScalingStrategies.formula('base * pow(sw / 360, 0.8)')
                    ),
                  ])
                    Padding(
                      padding: EdgeInsets.only(right: 8.cdpWith(s)),
                      child: Column(children: [
                        Container(
                            width: 48.cdpWith(s),
                            height: 48.cdpWith(s),
                            color: const Color(0xFF6A1B9A)),
                        Text(label, style: const TextStyle(fontSize: 10)),
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
