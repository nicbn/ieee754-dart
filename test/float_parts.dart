import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:ieee754/ieee754.dart';

void main() {
  group('FloatParts', () {
    test('minimize', () {
      var parts = FloatParts(10, 1).minimize();
      expect(parts.exponent, equals(2));
      expect(parts.mantissa.toInt(), equals(5));
    });

    test('fromFloat16Bytes', () {
      // 1.375 = 11 * 2 ^ -3
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0x3D, 0x80]));
      expect(parts.mantissa.toInt(), equals(11));
      expect(parts.exponent, equals(-3));
      expect(parts.isNegative, equals(false));
      expect(parts.isNaN, equals(false));
      expect(parts.isInfinite, equals(false));
    });

    test('fromFloat16Bytes(infinity)', () {
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0x7C, 0x00]));
      expect(parts.isNegative, equals(false));
      expect(parts.isInfinite, equals(true));
      expect(parts.isNaN, equals(false));
    });

    test('fromFloat32Bytes', () {
      // -8.5 = -17 * 2 ^ -1
      var parts = FloatParts.fromFloat32Bytes(
          Uint8List.fromList([0xC1, 0x08, 0x00, 0x00]));
      expect(parts.isNegative, equals(true));
      expect(parts.mantissa.toInt(), equals(-17));
      expect(parts.exponent, equals(-1));
    });

    test('fromDouble', () {
      var parts = FloatParts.fromDouble(-8.5);
      expect(parts.isNegative, equals(true));
      expect(parts.mantissa.toInt(), equals(-17));
      expect(parts.exponent, equals(-1));
    });

    test('toFloat16Bytes(infinity)', () {
      var parts = FloatParts.fromDouble(double.infinity);
      expect(parts.toFloat16Bytes(), equals([0x7C, 0x00]));
    });

    test('toFloat16Bytes', () {
      var parts = FloatParts.fromDouble(-8.5);
      expect(parts.toFloat16Bytes(), equals([0xC8, 0x40]));
    });

    test('toFloat32Bytes', () {
      var parts = FloatParts.fromDouble(-8.5);
      expect(parts.toFloat32Bytes(), equals([0xC1, 0x08, 0x00, 0x00]));
    });

    test('toFloat64Bytes', () {
      var parts = FloatParts.fromDouble(10);
      expect(parts.toFloat64Bytes(),
          equals([0x40, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]));
    });

    test('toFloat128Bytes', () {
      var parts = FloatParts.fromDouble(10);
      expect(
          parts.toFloat128Bytes(),
          equals([
            0x40,
            0x02,
            0x40,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00
          ]));
    });

    test('toDouble', () {
      var parts = FloatParts.fromFloat32Bytes(
          Uint8List.fromList([0xC1, 0x08, 0x00, 0x00]));
      expect(parts.toDouble(), equals(-8.5));
    });

    test('isFloat16Lossless true', () {
      var parts = FloatParts.fromFloat32Bytes(
          Uint8List.fromList([0xC1, 0x08, 0x00, 0x00]));
      expect(parts.isFloat16Lossless, equals(true));
    });

    test('isFloat16Lossless false', () {
      var parts = FloatParts.fromFloat32Bytes(
          Uint8List.fromList([0xC1, 0x08, 0x00, 0x02]));
      expect(parts.isFloat16Lossless, equals(false));
    });
  });
}
