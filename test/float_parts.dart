import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:ieee754/ieee754.dart';

void main() {
  group('FloatParts', () {
    test('minimize', () {
      var parts = FloatParts(10, 1).minimize();
      expect(parts.exponent, 2);
      expect(parts.mantissa.toInt(), 5);
    });

    // Float 16

    test('fromFloat16Bytes(0.0)', () {
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0x00, 0x00]));
      expect(parts.mantissa.toInt(), 0);
      expect(parts.isNegative, false);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromFloat16Bytes(-0.0)', () {
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0x80, 0x00]));
      expect(parts.mantissa.toInt(), 0);
      expect(parts.isNegative, true);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromFloat16Bytes(1.375)', () {
      // 1.375 = 11 * 2 ^ -3
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0x3D, 0x80]));
      expect(parts.mantissa.toInt(), 11);
      expect(parts.exponent, -3);
      expect(parts.isNegative, false);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromFloat16Bytes(65504)', () {
      // 65504 = 2047 * 2 ^ 5
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0x7B, 0xFF]));
      expect(parts.mantissa.toInt(), 2047);
      expect(parts.exponent, 5);
      expect(parts.isNegative, false);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromFloat16Bytes(infinity)', () {
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0x7C, 0x00]));
      expect(parts.isNegative, false);
      expect(parts.isInfinite, true);
      expect(parts.isNaN, false);
    });

    test('fromFloat16Bytes(-infinity)', () {
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0xFC, 0x00]));
      expect(parts.isNegative, true);
      expect(parts.isInfinite, true);
      expect(parts.isNaN, false);
    });

    test('fromFloat16Bytes(NaN)', () {
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0x7e, 0x00]));
      expect(parts.isNaN, true);
    });

    test('fromFloat16Bytes(-NaN)', () {
      var parts = FloatParts.fromFloat16Bytes(Uint8List.fromList([0xfe, 0x00]));
      expect(parts.isNaN, true);
    });

    test('toFloat16Bytes(0.0)', () {
      var parts = FloatParts(0, 0);
      expect(parts.isFloat16Lossless, true);
      expect(parts.toFloat16Bytes(), [0x00, 0x00]);
    });

    test('toFloat16Bytes(-0.0)', () {
      var parts = FloatParts(0, 0, forceNegative: true);
      expect(parts.isFloat16Lossless, true);
      expect(parts.toFloat16Bytes(), [0x80, 0x00]);
    });

    test('toFloat16Bytes(65504)', () {
      var parts = FloatParts(2047, 5);
      expect(parts.isFloat16Lossless, true);
      expect(parts.toFloat16Bytes(), [0x7B, 0xFF]);
    });

    test('toFloat16Bytes(2e-14)', () {
      var parts = FloatParts(1, -14);
      expect(parts.isFloat16Lossless, true);
      expect(parts.toFloat16Bytes(), [0x00, 0x01]);
    });

    test('toFloat16Bytes(infinity)', () {
      var parts = FloatParts.infinity;
      expect(parts.isFloat16Lossless, true);
      expect(parts.toFloat16Bytes(), [0x7C, 0x00]);
    });

    test('toFloat16Bytes(-infinity)', () {
      var parts = FloatParts.negativeInfinity;
      expect(parts.isFloat16Lossless, true);
      expect(parts.toFloat16Bytes(), [0xFC, 0x00]);
    });

    test('toFloat16Bytes(NaN)', () {
      var parts = FloatParts.nan;
      expect(parts.isFloat16Lossless, true);
      expect(parts.toFloat16Bytes(), [0x7e, 0x00]);
    });

    // 32

    test('fromFloat32Bytes(0.0)', () {
      final input = [0x00, 0x00, 0x00, 0x00];
      var parts = FloatParts.fromFloat32Bytes(Uint8List.fromList(input));
      expect(parts.mantissa.toInt(), 0);
      expect(parts.isNegative, false);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromFloat32Bytes(-0.0)', () {
      final input = [0x80, 0x00, 0x00, 0x00];
      var parts = FloatParts.fromFloat32Bytes(Uint8List.fromList(input));
      expect(parts.mantissa.toInt(), 0);
      expect(parts.isNegative, true);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromFloat32Bytes(1.375)', () {
      // 1.375 = 11 * 2 ^ -3
      final input = [0x3f, 0xb0, 0x00, 0x00];
      var parts = FloatParts.fromFloat32Bytes(Uint8List.fromList(input));
      expect(parts.mantissa.toInt(), 11);
      expect(parts.exponent, -3);
      expect(parts.isNegative, false);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromFloat32Bytes(3.40282346639e+38)', () {
      // 3.40282346639e+38 = 9007198717882551 * 2 ^ 75
      final input = [0x7f, 0x7f, 0xff, 0xff];
      var parts = FloatParts.fromFloat32Bytes(Uint8List.fromList(input));
      expect(parts.mantissa.toInt(), 9007198717882551);
      expect(parts.exponent, 75);
      expect(parts.isNegative, false);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromFloat32Bytes(infinity)', () {
      final input = [0x7f, 0x80, 0x00, 0x00];
      var parts = FloatParts.fromFloat32Bytes(Uint8List.fromList(input));
      expect(parts.isNegative, false);
      expect(parts.isInfinite, true);
      expect(parts.isNaN, false);
    });

    test('fromFloat32Bytes(-infinity)', () {
      final input = [0xff, 0x80, 0x00, 0x00];
      var parts = FloatParts.fromFloat32Bytes(Uint8List.fromList(input));
      expect(parts.isNegative, true);
      expect(parts.isInfinite, true);
      expect(parts.isNaN, false);
    });

    test('fromFloat32Bytes(NaN)', () {
      final input = [0x7f, 0xc0, 0x00, 0x00];
      var parts = FloatParts.fromFloat32Bytes(Uint8List.fromList(input));
      expect(parts.isNaN, true);
    });

    test('fromFloat32Bytes(-NaN)', () {
      final input = [0xff, 0xc0, 0x00, 0x00];
      var parts = FloatParts.fromFloat32Bytes(Uint8List.fromList(input));
      expect(parts.isNaN, true);
    });

    test('toFloat32Bytes(0.0)', () {
      var parts = FloatParts(0, 0);
      expect(parts.isFloat32Lossless, true);
      expect(parts.toFloat32Bytes(), [0x00, 0x00, 0x00, 0x00]);
    });

    test('toFloat32Bytes(-0.0)', () {
      var parts = FloatParts(0, 0, forceNegative: true);
      expect(parts.isFloat32Lossless, true);
      expect(parts.toFloat32Bytes(), [0x80, 0x00, 0x00, 0x00]);
    });

    test('toFloat32Bytes(1.375)', () {
      var parts = FloatParts(11, -3);
      expect(parts.isFloat32Lossless, true);
      expect(parts.toFloat32Bytes(), [0x3f, 0xb0, 0x00, 0x00]);
    });

    test('toFloat32Bytes(3.40282346639e+38)', () {
      var parts = FloatParts(9007198717882551, 75);
      expect(parts.isFloat32Lossless, true);
      expect(parts.toFloat32Bytes(), [0x7f, 0x7f, 0xff, 0xff]);
    });

    test('toFloat32Bytes(infinity)', () {
      var parts = FloatParts.infinity;
      expect(parts.isFloat32Lossless, true);
      expect(parts.toFloat32Bytes(), [0x7f, 0x80, 0x00, 0x00]);
    });

    test('toFloat32Bytes(-infinity)', () {
      var parts = FloatParts.negativeInfinity;
      expect(parts.isFloat32Lossless, true);
      expect(parts.toFloat32Bytes(), [0xff, 0x80, 0x00, 0x00]);
    });

    test('toFloat32Bytes(NaN)', () {
      var parts = FloatParts.nan;
      expect(parts.isFloat32Lossless, true);
      expect(parts.toFloat32Bytes(), [0x7f, 0xc0, 0x00, 0x00]);
    });

    // 64

    test('fromDouble(1.375)', () {
      // 1.375 = 11 * 2 ^ -3

      var parts = FloatParts.fromDouble(1.375);
      expect(parts.mantissa.toInt(), 11);
      expect(parts.exponent, -3);
      expect(parts.isNegative, false);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('fromDouble(infinity)', () {
      var parts = FloatParts.fromDouble(double.infinity);
      expect(parts.isNegative, false);
      expect(parts.isInfinite, true);
      expect(parts.isNaN, false);
    });

    test('fromDouble(NaN)', () {
      var parts = FloatParts.fromDouble(double.nan);
      expect(parts.isNaN, true);
    });

    test('toDouble(1.375)', () {
      var parts = FloatParts(11, -3);
      expect(parts.isFloat64Lossless, true);
      expect(parts.toDouble(), 1.375);
    });

    test('toDouble(infinity)', () {
      var parts = FloatParts.infinity;
      expect(parts.isFloat32Lossless, true);
      expect(parts.toDouble(), double.infinity);
    });

    test('toDouble(NaN)', () {
      var parts = FloatParts.nan;
      expect(parts.isFloat32Lossless, true);
      expect(parts.toDouble().isNaN, true);
    });

    // 128

    test('fromFloat128Bytes(1.375)', () {
      // 1.375 = 11 * 2 ^ -3

      final input = [
        0x3f,
        0xff,
        0x60,
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
      ];
      var parts = FloatParts.fromFloat128Bytes(Uint8List.fromList(input));
      expect(parts.mantissa.toInt(), 11);
      expect(parts.exponent, -3);
      expect(parts.isNegative, false);
      expect(parts.isNaN, false);
      expect(parts.isInfinite, false);
    });

    test('toFloat128Bytes(1.375)', () {
      var parts = FloatParts(11, -3);
      expect(parts.isFloat128Lossless, true);
      expect(parts.toFloat128Bytes(), [
        0x3f,
        0xff,
        0x60,
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
      ]);
    });
  });
}
