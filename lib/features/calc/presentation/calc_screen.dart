import 'package:flutter/material.dart';

class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  String _display = '0';
  double? _acc; // accumulator (left operand)
  String? _op;  // '+', '-', '×', '÷'
  bool _overwrite = true; // next digit overwrites display
  bool _hasDecimal = false;

  void _inputDigit(String d) {
    setState(() {
      if (_overwrite) {
        _display = d == '.' ? '0.' : d;
        _overwrite = false;
        _hasDecimal = d == '.';
        return;
      }
      if (d == '.' && _hasDecimal) return;
      if (d == '.') {
        _display += d;
        _hasDecimal = true;
      } else {
        if (_display == '0') {
          _display = d;
        } else {
          _display += d;
        }
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display == '0') return;
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  void _percent() {
    setState(() {
      final v = _toDouble(_display);
      final res = v / 100.0;
      _display = _fmt(res);
      _overwrite = true;
      _hasDecimal = _display.contains('.');
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _acc = null;
      _op = null;
      _overwrite = true;
      _hasDecimal = false;
    });
  }

  void _delete() {
    setState(() {
      if (_overwrite || _display.length <= 1) {
        _display = '0';
        _overwrite = true;
        _hasDecimal = false;
      } else {
        if (_display.endsWith('.')) _hasDecimal = false;
        _display = _display.substring(0, _display.length - 1);
        if (_display == '-' || _display.isEmpty) {
          _display = '0';
          _overwrite = true;
        }
      }
    });
  }

  void _setOp(String op) {
    setState(() {
      final current = _toDouble(_display);
      if (_acc == null) {
        _acc = current;
      } else if (_op != null && !_overwrite) {
        _acc = _calc(_acc!, current, _op!);
        _display = _fmt(_acc!);
      }
      _op = op;
      _overwrite = true;
      _hasDecimal = false;
    });
  }

  void _equals() {
    setState(() {
      if (_op == null || _acc == null) return;
      final right = _toDouble(_display);
      final res = _calc(_acc!, right, _op!);
      _display = _fmt(res);
      _acc = null;
      _op = null;
      _overwrite = true;
      _hasDecimal = _display.contains('.');
    });
  }

  double _toDouble(String s) => double.tryParse(s) ?? 0.0;

  double _calc(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return double.nan;
        return a / b;
      default:
        return b;
    }
  }

  String _fmt(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';
    final text = v.toStringAsFixed(12); // tame FP noise
    final trimmed = text.replaceFirst(RegExp(r'\.?0+$'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final btnTextStyle = Theme.of(context).textTheme.titleLarge;

    final ops = ['÷', '×', '-', '+'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: FittedBox(
                  alignment: Alignment.bottomRight,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _display,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            // Keypad
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 10.0;
                  return Column(
                    children: [
                      Row(
                        children: [
                          _key('C', onTap: _clear, style: btnTextStyle),
                          _key('±', onTap: _toggleSign, style: btnTextStyle),
                          _key('%', onTap: _percent, style: btnTextStyle),
                          _key('÷', onTap: () => _setOp('÷'), style: btnTextStyle, filled: true, color: cs.primary),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        children: [
                          _key('7', onTap: () => _inputDigit('7'), style: btnTextStyle),
                          _key('8', onTap: () => _inputDigit('8'), style: btnTextStyle),
                          _key('9', onTap: () => _inputDigit('9'), style: btnTextStyle),
                          _key('×', onTap: () => _setOp('×'), style: btnTextStyle, filled: true, color: cs.primary),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        children: [
                          _key('4', onTap: () => _inputDigit('4'), style: btnTextStyle),
                          _key('5', onTap: () => _inputDigit('5'), style: btnTextStyle),
                          _key('6', onTap: () => _inputDigit('6'), style: btnTextStyle),
                          _key('-', onTap: () => _setOp('-'), style: btnTextStyle, filled: true, color: cs.primary),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        children: [
                          _key('1', onTap: () => _inputDigit('1'), style: btnTextStyle),
                          _key('2', onTap: () => _inputDigit('2'), style: btnTextStyle),
                          _key('3', onTap: () => _inputDigit('3'), style: btnTextStyle),
                          _key('+', onTap: () => _setOp('+'), style: btnTextStyle, filled: true, color: cs.primary),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        children: [
                          _key('⌫', onTap: _delete, style: btnTextStyle),
                          _key('0', onTap: () => _inputDigit('0'), style: btnTextStyle),
                          _key('.', onTap: () => _inputDigit('.'), style: btnTextStyle),
                          _key('=', onTap: _equals, style: btnTextStyle, filled: true, color: cs.secondary),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _key(
    String label, {
    required VoidCallback onTap,
    TextStyle? style,
    bool filled = false,
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final bg = filled ? (color ?? cs.primary) : cs.surface;
    final fg = filled ? cs.onPrimary : cs.onSurfaceVariant;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: filled ? 1 : 0,
            ),
            onPressed: onTap,
            child: Text(label, style: style),
          ),
        ),
      ),
    );
  }
}
