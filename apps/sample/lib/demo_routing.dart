/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// DemoCalcRouting — the strategy-routing layer of the sample app, converted
/// from the KMP/Dynamic `DemoCalcRouting.kt`. Every `demo*` member re-routes
/// through the currently selected curve so a single dropdown re-routes the
/// entire page.
library;

import 'package:appdimens_bom/appdimens_bom.dart';
import 'package:flutter/material.dart';

enum DemoCalcStrategy {
  scaled('Scaled (default)', 'Scaled (padrão)'),
  percent('Percent', 'Percentual'),
  power('Power', 'Potência'),
  fluid('Fluid', 'Fluido'),
  auto('Auto', 'Automático'),
  logarithmic('Logarithmic', 'Logarítmico'),
  interpolated('Interpolated', 'Interpolado'),
  diagonal('Diagonal', 'Diagonal'),
  perimeter('Perimeter', 'Perímetro'),
  fit('Fit (contain)', 'Fit (conter)'),
  fill('Fill (cover)', 'Fill (cobrir)'),
  density('Density', 'Densidade');

  const DemoCalcStrategy(this.labelEn, this.labelPt);
  final String labelEn;
  final String labelPt;
}

/// Scope slot mirroring the family's fast-lane publication pattern.
DemoCalcStrategy _current = DemoCalcStrategy.scaled;

class DemoCalcScope extends StatefulWidget {
  final DemoCalcStrategy strategy;
  final ValueChanged<DemoCalcStrategy> onStrategyChanged;
  final Widget child;

  const DemoCalcScope({
    super.key,
    required this.strategy,
    required this.onStrategyChanged,
    required this.child,
  });

  @override
  State<DemoCalcScope> createState() => _DemoCalcScopeState();
}

class _DemoCalcScopeState extends State<DemoCalcScope> {
  @override
  void initState() {
    super.initState();
    _current = widget.strategy;
  }

  @override
  void didUpdateWidget(DemoCalcScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strategy != widget.strategy) {
      setState(() => _current = widget.strategy);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

double _routeSw(num value) {
  final v = value.toDouble();
  switch (_current) {
    case DemoCalcStrategy.scaled:
      return v.sdp;
    case DemoCalcStrategy.percent:
      return v.psdp;
    case DemoCalcStrategy.power:
      return v.pwsdp;
    case DemoCalcStrategy.fluid:
      return v.fsdp;
    case DemoCalcStrategy.auto:
      return v.asdp;
    case DemoCalcStrategy.logarithmic:
      return v.logsdp;
    case DemoCalcStrategy.interpolated:
      return v.isdp;
    case DemoCalcStrategy.diagonal:
      return v.dgsdp;
    case DemoCalcStrategy.perimeter:
      return v.prsdp;
    case DemoCalcStrategy.fit:
      return v.ftsdp;
    case DemoCalcStrategy.fill:
      return v.flsdp;
    case DemoCalcStrategy.density:
      return v.dsdp;
  }
}

/// EN: Routing extensions used by the demo UI — each reads the ambient
/// strategy slot and dispatches to the matching family.
///
/// PT: Extensões de roteamento usadas pela UI de demonstração — cada uma lê o
/// slot da estratégia ambiente e despacha para a família correspondente.
extension DemoCalcNum on num {
  double get demoSwDp => _routeSw(this);

  double get demoSwDpa {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return sdpa;
      case DemoCalcStrategy.percent:
        return psdpa;
      case DemoCalcStrategy.power:
        return pwsdpa;
      default:
        return _routeSw(this);
    }
  }

  double get demoHdp {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return hdp;
      case DemoCalcStrategy.percent:
        return phdp;
      case DemoCalcStrategy.power:
        return pwhdp;
      default:
        return _routeSw(this);
    }
  }

  double get demoWdp {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return wdp;
      case DemoCalcStrategy.percent:
        return pwdp;
      case DemoCalcStrategy.power:
        return pwwdp;
      default:
        return _routeSw(this);
    }
  }

  double get demoSwPh {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return sdpPh;
      default:
        return hdpAxis();
    }
  }

  double get demoSwLw {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return sdpLw;
      default:
        return wdpAxis();
    }
  }

  double get demoHLw {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return hdpLw;
      default:
        return wdpAxis();
    }
  }

  double get demoWLh {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return wdpLh;
      default:
        return hdpAxis();
    }
  }

  double hdpAxis() {
    switch (_current) {
      case DemoCalcStrategy.percent:
        return phdp;
      case DemoCalcStrategy.power:
        return pwhdp;
      case DemoCalcStrategy.fluid:
        return fhdp;
      case DemoCalcStrategy.auto:
        return ahdp;
      case DemoCalcStrategy.logarithmic:
        return loghdp;
      case DemoCalcStrategy.interpolated:
        return ihdp;
      case DemoCalcStrategy.diagonal:
        return dghdp;
      case DemoCalcStrategy.perimeter:
        return prhdp;
      case DemoCalcStrategy.fit:
        return fthdp;
      case DemoCalcStrategy.fill:
        return flhdp;
      case DemoCalcStrategy.density:
        return dhdp;
      case DemoCalcStrategy.scaled:
        return hdp;
    }
  }

  double wdpAxis() {
    switch (_current) {
      case DemoCalcStrategy.percent:
        return pwdp;
      case DemoCalcStrategy.power:
        return pwwdp;
      case DemoCalcStrategy.fluid:
        return fwdp;
      case DemoCalcStrategy.auto:
        return awdp;
      case DemoCalcStrategy.logarithmic:
        return logwdp;
      case DemoCalcStrategy.interpolated:
        return iwdp;
      case DemoCalcStrategy.diagonal:
        return dgwdp;
      case DemoCalcStrategy.perimeter:
        return prwdp;
      case DemoCalcStrategy.fit:
        return ftwdp;
      case DemoCalcStrategy.fill:
        return flwdp;
      case DemoCalcStrategy.density:
        return dwdp;
      case DemoCalcStrategy.scaled:
        return wdp;
    }
  }

  double demoSdpRotate(num rotationValue) {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return sdpRotate(rotationValue);
      case DemoCalcStrategy.percent:
        return psdpRotate(rotationValue);
      case DemoCalcStrategy.power:
        return pwsdpRotate(rotationValue);
      case DemoCalcStrategy.fluid:
        return fsdpRotate(rotationValue);
      case DemoCalcStrategy.auto:
        return asdpRotate(rotationValue);
      case DemoCalcStrategy.logarithmic:
        return logsdpRotate(rotationValue);
      case DemoCalcStrategy.interpolated:
        return isdpRotate(rotationValue);
      case DemoCalcStrategy.diagonal:
        return dgsdpRotate(rotationValue);
      case DemoCalcStrategy.perimeter:
        return prsdpRotate(rotationValue);
      case DemoCalcStrategy.fit:
        return ftsdpRotate(rotationValue);
      case DemoCalcStrategy.fill:
        return flsdpRotate(rotationValue);
      case DemoCalcStrategy.density:
        return dsdpRotate(rotationValue);
    }
  }

  double demoSdpMode(num modeValue, UiModeType uiModeType) {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return sdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.percent:
        return psdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.power:
        return pwsdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.fluid:
        return fsdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.auto:
        return asdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.logarithmic:
        return logsdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.interpolated:
        return isdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.diagonal:
        return dgsdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.perimeter:
        return prsdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.fit:
        return ftsdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.fill:
        return flsdpMode(modeValue, uiModeType);
      case DemoCalcStrategy.density:
        return dsdpMode(modeValue, uiModeType);
    }
  }

  double demoSdpQualifier(
      num qualifiedValue, DpQualifier qualifierType, num qualifierValue) {
    switch (_current) {
      case DemoCalcStrategy.scaled:
        return sdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.percent:
        return psdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.power:
        return pwsdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.fluid:
        return fsdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.auto:
        return asdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.logarithmic:
        return logsdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.interpolated:
        return isdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.diagonal:
        return dgsdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.perimeter:
        return prsdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.fit:
        return ftsdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.fill:
        return flsdpQualifier(qualifiedValue, qualifierType, qualifierValue);
      case DemoCalcStrategy.density:
        return dsdpQualifier(qualifiedValue, qualifierType, qualifierValue);
    }
  }

  double demoSdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      sdpRotatePlain(alternative, orientation: orientation);
}
