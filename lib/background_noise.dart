import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

Future<RepeatedTextureComponent> generateBackgroundNoise(
  Size worldSize,
  double padding, {
  double opacity = 0.002,
}) async {
  final noiseTile = await _generateNoiseTile(128, 128);

  return RepeatedTextureComponent(noiseTile, worldSize, padding, opacity);
}

class RepeatedTextureComponent extends PositionComponent {
  late ui.Image _image;
  final Size worldSize;
  final double padding;
  final double opacity;

  RepeatedTextureComponent(
    this._image,
    this.worldSize,
    this.padding,
    this.opacity,
  );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      -worldSize.width / 2 - padding,
      -worldSize.height / 2 - padding,
      worldSize.width + padding * 2,
      worldSize.height + padding * 2,
    );
    paintImage(
      canvas: canvas,
      rect: rect,
      image: _image,
      repeat: ImageRepeat.repeat,
      fit: BoxFit.fill,
      opacity: opacity,
    );
  }
}

Future<ui.Image> _generateNoiseTile(int width, int height) async {
  final rng = Random();
  final pixels = Uint8List(width * height * 4);

  for (var x = 0; x < width; x++) {
    final value = rng.nextInt(256);
    final offset = x * 4;
    pixels[offset] = value; // R
    pixels[offset + 1] = value; // G
    pixels[offset + 2] = value; // B
    pixels[offset + 3] = 255; // A
  }

  for (var y = 0; y < height; y++) {
    final value = rng.nextInt(256);
    final offset = (y * width) * 4;
    pixels[offset] = value; // R
    pixels[offset + 1] = value; // G
    pixels[offset + 2] = value; // B
    pixels[offset + 3] = 255; // A
  }

  for (var y = 1; y < height; y++) {
    for (var x = 1; x < width; x++) {
      final offset = (y * width + x) * 4;
      final leftPixelValue = pixels[(y * width + x - 1) * 4];
      final topPixelValue = pixels[((y - 1) * width + x) * 4];
      final value = ((rng.nextInt(256) + leftPixelValue + topPixelValue) / 3)
          .round();
      pixels[offset] = value; // R
      pixels[offset + 1] = value; // G
      pixels[offset + 2] = value; // B
      pixels[offset + 3] = 255; // A
    }
  }

  final descriptor = ui.ImageDescriptor.raw(
    await ui.ImmutableBuffer.fromUint8List(pixels),
    width: width,
    height: height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );

  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  return frame.image;
}
