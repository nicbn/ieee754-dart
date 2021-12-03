/// Helper class
///
/// Handles integers of arbitrary size but tries to use `int` whenever the
/// result would fit in an `int`.
abstract class Integer {
  factory Integer(BigInt x) {
    if (x.bitLength < 52) {
      return _IntInteger(x.toInt());
    } else {
      return _BigIntInteger(x);
    }
  }

  factory Integer.from(int x) => _IntInteger(x);

  static final Integer zero = _IntInteger(0);

  bool get isIntLossless;

  BigInt toBigInt();
  int toInt();

  /// Same as (x & ((1 << count) - 1)).
  Integer mask(int count);

  Integer operator <<(int i);
  Integer operator >>(int i);
  Integer operator |(Integer x);
  Integer operator -();

  bool get isZero;

  /// Same as (x | (1 << i))
  Integer withBit(int i);

  Integer abs();
}

class _IntInteger with Integer {
  _IntInteger(this._x);

  final int _x;
  late final BigInt _bigInt = BigInt.from(_x);

  @override
  final bool isIntLossless = true;

  @override
  BigInt toBigInt() => _bigInt;

  @override
  int toInt() => _x;

  @override
  bool get isZero => _x == 0;

  @override
  Integer mask(int count) {
    if (count < 52) {
      return Integer.from(_x & ((1 << count) - 1));
    } else {
      return this;
    }
  }

  @override
  Integer operator <<(int i) {
    if (_x.bitLength + i < 52) {
      return Integer.from(_x << i);
    } else {
      return Integer(_bigInt << i);
    }
  }

  @override
  Integer operator >>(int i) => Integer.from(_x >> i);

  @override
  Integer operator -() => Integer(-_bigInt);

  @override
  Integer operator |(Integer x) {
    if (x.isIntLossless) {
      return Integer.from(_x | x.toInt());
    } else {
      return Integer(_bigInt | x.toBigInt());
    }
  }

  @override
  Integer withBit(int i) {
    if (i < 52) {
      return Integer.from(_x | (1 << i));
    } else {
      return Integer(_bigInt | (BigInt.one << i));
    }
  }

  @override
  Integer abs() => Integer(_bigInt.abs());

  @override
  bool operator ==(Object other) {
    if (other is int) {
      return isIntLossless && _x == other;
    } else if (other is _IntInteger) {
      return _x == other._x;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => _x.hashCode;
}

class _BigIntInteger with Integer {
  _BigIntInteger(this._x);

  final BigInt _x;

  @override
  final bool isIntLossless = false;

  @override
  final bool isZero = false;

  @override
  BigInt toBigInt() => _x;

  @override
  int toInt() => _x.toInt();

  @override
  Integer mask(int count) => Integer(_x & ~(~BigInt.zero << count));

  @override
  Integer operator <<(int i) => Integer(_x << i);

  @override
  Integer operator >>(int i) => Integer(_x >> i);

  @override
  Integer operator -() => Integer(-_x);

  @override
  Integer operator |(Integer x) {
    return Integer(_x | x.toBigInt());
  }

  @override
  Integer abs() => Integer(_x.abs());

  @override
  Integer withBit(int i) {
    return Integer(_x | (BigInt.one << i));
  }

  @override
  bool operator ==(Object other) {
    if (other is BigInt) {
      return isIntLossless && _x == other;
    } else if (other is _BigIntInteger) {
      return _x == other._x;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => _x.hashCode;
}
