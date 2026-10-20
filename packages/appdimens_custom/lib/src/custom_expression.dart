/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// EN Free-form formulas for custom strategies — a small, safe expression
/// language with the same grammar, variables, functions and results on every
/// AppDimens platform. Booleans are numbers (true = 1, false = 0).
///
/// Operators: `+ - * / % ^` (`^` = power, right-associative; `%` keeps the
/// dividend's sign), `== != < <= > >=`, `&& || !`, `cond ? a : b`.
/// Functions: `min max clamp pow sqrt ln log log10 log2 exp abs sign floor
/// ceil round lerp step smoothstep`. Variables: [screenVariables]; curves add
/// `ratio axis ref refWidth refHeight`; formulas add `base scaled factor`.
///
/// PT Fórmulas livres — linguagem de expressões segura e idêntica em todas as
/// plataformas AppDimens.
library;

import 'dart:math' as math;

import 'custom_engine.dart';

/// Variables read from the window.
const List<String> screenVariables = [
  'sw', 'width', 'height', 'shortSide', 'longSide', 'diagonal', 'perimeter', //
  'aspectRatio', 'density', 'fontScale', 'landscape', 'portrait',
  'multiWindow', 'phone', 'tablet', 'desktop', 'tv', 'watch', 'car', 'vr',
  'pi', 'e',
];

/// Variables of a curve expression.
const List<String> curveVariables = [
  ...screenVariables, 'ratio', 'axis', 'ref', 'refWidth', 'refHeight', //
];

/// Variables of a per-value formula.
const List<String> formulaVariables = [
  ...curveVariables, 'base', 'scaled', 'factor', //
];

/// A parsed, immutable expression.
class ScalingExpression {
  final String source;
  final _Node _root;

  ScalingExpression._(this.source, this._root);

  /// Parses [source]; every identifier must be in [allowed]. Errors carry the
  /// position.
  factory ScalingExpression.parse(String source,
          {List<String> allowed = formulaVariables}) =>
      ScalingExpression._(source, _Parser(source, allowed.toSet()).parseAll());

  /// Evaluates with a name → value lookup.
  double evaluate(double Function(String name) vars) => _root.eval(vars);

  @override
  bool operator ==(Object other) =>
      other is ScalingExpression && other.source == source;

  @override
  int get hashCode => source.hashCode;

  @override
  String toString() => source;
}

/// Variable lookup for [screen] plus the strategy context.
double Function(String) expressionVariables(ScreenSnapshot screen, double ratio,
    double axisDp, double refDp, ReferenceScreen reference,
    {double base = double.nan,
    double scaled = double.nan,
    double factor = double.nan}) {
  final mn = math.min(screen.widthDp, screen.heightDp);
  final mx = math.max(screen.widthDp, screen.heightDp);
  double flag(DeviceClass d) => screen.device == d ? 1 : 0;
  return (name) => switch (name) {
        'sw' => screen.smallestWidthDp,
        'width' => screen.widthDp,
        'height' => screen.heightDp,
        'shortSide' => mn,
        'longSide' => mx,
        'diagonal' => math.sqrt(mn * mn + mx * mx),
        'perimeter' => mn + mx,
        'aspectRatio' => mn > 0 ? mx / mn : 1,
        'density' => screen.density,
        'fontScale' => screen.fontScale,
        'landscape' => screen.isLandscape ? 1 : 0,
        'portrait' => screen.isLandscape ? 0 : 1,
        'multiWindow' => screen.isMultiWindow ? 1 : 0,
        'phone' => flag(DeviceClass.phone),
        'tablet' => flag(DeviceClass.tablet),
        'desktop' => flag(DeviceClass.desktop),
        'tv' => flag(DeviceClass.tv),
        'watch' => flag(DeviceClass.watch),
        'car' => flag(DeviceClass.car),
        'vr' => flag(DeviceClass.vr),
        'pi' => math.pi,
        'e' => math.e,
        'ratio' => ratio,
        'axis' => axisDp,
        'ref' => refDp,
        'refWidth' => reference.width,
        'refHeight' => reference.height,
        'base' => base,
        'scaled' => scaled,
        'factor' => factor,
        _ => double.nan,
      };
}

sealed class _Node {
  double eval(double Function(String) v);
}

class _Num extends _Node {
  final double value;
  _Num(this.value);
  @override
  double eval(double Function(String) v) => value;
}

class _Var extends _Node {
  final String name;
  _Var(this.name);
  @override
  double eval(double Function(String) v) => v(name);
}

class _Unary extends _Node {
  final String op;
  final _Node a;
  _Unary(this.op, this.a);
  @override
  double eval(double Function(String) v) {
    final x = a.eval(v);
    return op == '-' ? -x : (x != 0 ? 0 : 1);
  }
}

class _Binary extends _Node {
  final String op;
  final _Node a, b;
  _Binary(this.op, this.a, this.b);
  @override
  double eval(double Function(String) v) {
    if (op == '&&') return a.eval(v) != 0 && b.eval(v) != 0 ? 1 : 0;
    if (op == '||') return a.eval(v) != 0 || b.eval(v) != 0 ? 1 : 0;
    final x = a.eval(v), y = b.eval(v);
    return switch (op) {
      '+' => x + y,
      '-' => x - y,
      '*' => x * y,
      '/' => x / y,
      '%' => x.remainder(y),
      '^' => math.pow(x, y).toDouble(),
      '==' => x == y ? 1 : 0,
      '!=' => x != y ? 1 : 0,
      '<' => x < y ? 1 : 0,
      '<=' => x <= y ? 1 : 0,
      '>' => x > y ? 1 : 0,
      _ => x >= y ? 1 : 0,
    };
  }
}

class _Ternary extends _Node {
  final _Node c, a, b;
  _Ternary(this.c, this.a, this.b);
  @override
  double eval(double Function(String) v) =>
      c.eval(v) != 0 ? a.eval(v) : b.eval(v);
}

class _Call extends _Node {
  final String name;
  final List<_Node> args;
  _Call(this.name, this.args);
  @override
  double eval(double Function(String) v) {
    final x = [for (final a in args) a.eval(v)];
    switch (name) {
      case 'min':
        return x.reduce(math.min);
      case 'max':
        return x.reduce(math.max);
      case 'clamp':
        return math.max(x[1], math.min(x[2], x[0]));
      case 'pow':
        return math.pow(x[0], x[1]).toDouble();
      case 'sqrt':
        return math.sqrt(x[0]);
      case 'ln':
      case 'log':
        return math.log(x[0]);
      case 'log10':
        return math.log(x[0]) / math.ln10;
      case 'log2':
        return math.log(x[0]) / math.ln2;
      case 'exp':
        return math.exp(x[0]);
      case 'abs':
        return x[0].abs();
      case 'sign':
        return x[0].sign;
      case 'floor':
        return x[0].floorToDouble();
      case 'ceil':
        return x[0].ceilToDouble();
      case 'round':
        return (x[0] + 0.5).floorToDouble();
      case 'lerp':
        return x[0] + (x[1] - x[0]) * x[2];
      case 'step':
        return x[1] < x[0] ? 0 : 1;
      default:
        final t = ((x[2] - x[0]) / (x[1] - x[0])).clamp(0.0, 1.0);
        return t * t * (3 - 2 * t);
    }
  }
}

const Map<String, (int, int)> _arity = {
  'min': (1, 1 << 30), 'max': (1, 1 << 30), 'clamp': (3, 3), 'pow': (2, 2), //
  'sqrt': (1, 1), 'ln': (1, 1), 'log': (1, 1), 'log10': (1, 1),
  'log2': (1, 1), 'exp': (1, 1), 'abs': (1, 1), 'sign': (1, 1),
  'floor': (1, 1), 'ceil': (1, 1), 'round': (1, 1), 'lerp': (3, 3),
  'step': (2, 2), 'smoothstep': (3, 3),
};

const List<String> _comparisons = ['==', '!=', '<=', '>=', '<', '>'];

class _Parser {
  final String src;
  final Set<String> allowed;
  int i = 0;

  _Parser(this.src, this.allowed);

  _Node parseAll() {
    if (src.trim().isEmpty) throw _fail('empty expression');
    final n = _ternary();
    _ws();
    if (i < src.length) throw _fail("unexpected '${src[i]}'");
    return n;
  }

  _Node _ternary() {
    final c = _or();
    if (!_eat('?')) return c;
    final a = _ternary();
    if (!_eat(':')) throw _fail("expected ':'");
    return _Ternary(c, a, _ternary());
  }

  _Node _or() {
    var n = _and();
    while (_eat('||')) {
      n = _Binary('||', n, _and());
    }
    return n;
  }

  _Node _and() {
    var n = _cmp();
    while (_eat('&&')) {
      n = _Binary('&&', n, _cmp());
    }
    return n;
  }

  _Node _cmp() {
    final n = _add();
    for (final op in _comparisons) {
      if (_eat(op)) return _Binary(op, n, _add());
    }
    return n;
  }

  _Node _add() {
    var n = _mul();
    while (true) {
      if (_eat('+')) {
        n = _Binary('+', n, _mul());
      } else if (_eat('-')) {
        n = _Binary('-', n, _mul());
      } else {
        return n;
      }
    }
  }

  _Node _mul() {
    var n = _unary();
    while (true) {
      if (_eat('*')) {
        n = _Binary('*', n, _unary());
      } else if (_eat('/')) {
        n = _Binary('/', n, _unary());
      } else if (_eat('%')) {
        n = _Binary('%', n, _unary());
      } else {
        return n;
      }
    }
  }

  _Node _unary() {
    if (_eat('-')) return _Unary('-', _unary());
    if (_eat('+')) return _unary();
    if (_peekIs('!') && !_peekIs('!=')) {
      _eat('!');
      return _Unary('!', _unary());
    }
    return _power();
  }

  _Node _power() {
    final n = _primary();
    return _eat('^') ? _Binary('^', n, _unary()) : n;
  }

  static final _digit = RegExp(r'[0-9.]');
  static final _identStart = RegExp(r'[A-Za-z_]');
  static final _ident = RegExp(r'[A-Za-z0-9_]');

  _Node _primary() {
    _ws();
    if (i >= src.length) throw _fail('unexpected end');
    final c = src[i];
    if (c == '(') {
      i++;
      final n = _ternary();
      if (!_eat(')')) throw _fail("expected ')'");
      return n;
    }
    if (_digit.hasMatch(c)) return _number();
    if (_identStart.hasMatch(c)) {
      final start = i;
      while (i < src.length && _ident.hasMatch(src[i])) {
        i++;
      }
      final name = src.substring(start, i);
      if (_eat('(')) return _call(name, start);
      if (name == 'true') return _Num(1);
      if (name == 'false') return _Num(0);
      if (!allowed.contains(name)) {
        i = start;
        throw _fail(
            "unknown variable '$name' (allowed: ${(allowed.toList()..sort()).join(', ')})");
      }
      return _Var(name);
    }
    throw _fail("unexpected '$c'");
  }

  _Node _call(String name, int start) {
    final args = <_Node>[];
    if (!_eat(')')) {
      do {
        args.add(_ternary());
      } while (_eat(','));
      if (!_eat(')')) throw _fail("expected ')'");
    }
    final arity = _arity[name];
    if (arity == null) {
      i = start;
      throw _fail("unknown function '$name'");
    }
    if (args.length < arity.$1 || args.length > arity.$2) {
      i = start;
      final n = arity.$1 == arity.$2 ? '${arity.$1}' : '${arity.$1}+';
      throw _fail("'$name' takes $n argument(s), got ${args.length}");
    }
    return _Call(name, args);
  }

  _Node _number() {
    final start = i;
    while (i < src.length && _digit.hasMatch(src[i])) {
      i++;
    }
    if (i < src.length && (src[i] == 'e' || src[i] == 'E')) {
      final save = i;
      i++;
      if (i < src.length && (src[i] == '+' || src[i] == '-')) i++;
      if (i < src.length && RegExp(r'[0-9]').hasMatch(src[i])) {
        while (i < src.length && RegExp(r'[0-9]').hasMatch(src[i])) {
          i++;
        }
      } else {
        i = save;
      }
    }
    final text = src.substring(start, i);
    final v = double.tryParse(text);
    if (v == null) {
      i = start;
      throw _fail("bad number '$text'");
    }
    return _Num(v);
  }

  void _ws() {
    while (i < src.length && src[i].trim().isEmpty) {
      i++;
    }
  }

  bool _peekIs(String token) {
    _ws();
    return src.startsWith(token, i);
  }

  bool _eat(String token) {
    if (!_peekIs(token)) return false;
    i += token.length;
    return true;
  }

  FormatException _fail(String msg) =>
      FormatException('Invalid expression at $i: $msg in "$src"');
}

/// EN Per-value formula written as text (`"formula": "max(scaled, base)"`).
/// PT Fórmula por valor em texto.
class ScalingFormula {
  final ScalingExpression expression;

  ScalingFormula(String source)
      : expression = ScalingExpression.parse(source, allowed: formulaVariables);

  String get source => expression.source;

  @override
  bool operator ==(Object other) =>
      other is ScalingFormula && other.expression == expression;

  @override
  int get hashCode => expression.hashCode;

  @override
  String toString() => 'formula($source)';
}
