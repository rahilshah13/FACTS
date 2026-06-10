import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:image/image.dart' as img;

void main() {
  final JSObject global = globalContext;
  global['generateUVMapWasm'] = _generateUVMapBridge.toJS;
}

JSUint8Array _generateUVMapBridge(JSFloat32Array rawUVs, JSInt32Array rawIndices, int size) {
  // Direct, zero-copy mapping of JavaScript TypedArrays to Dart native TypedData structures
  final Float32List dartUVs = rawUVs.toDart;
  final Int32List dartIndices = rawIndices.toDart;
  // Initialize canvas with a dark charcoal background
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgba8(30, 30, 30, 255));
  
  // Neon green stroke color for clean wireframe visualization
  final stroke = img.ColorRgba8(0, 255, 120, 255);
  final double maxCoord = (size - 1).toDouble();

  // Iterate directly through the flat index buffer 3 steps at a time (representing faces)
  for (int i = 0; i < dartIndices.length; i += 3) {
    final int v1 = dartIndices[i];
    final int v2 = dartIndices[i + 1];
    final int v3 = dartIndices[i + 2];
    // Indices map to vertex pairs, multiply by 2 to align with flat Float32List [u0, v0, u1, v1...]
    final int uvIndex1 = v1 * 2;
    final int uvIndex2 = v2 * 2;
    final int uvIndex3 = v3 * 2;

    // avoid out-of-bounds pointer reads on mismatched buffers
    if (uvIndex3 + 1 >= dartUVs.length) continue;

    final int x1 = (dartUVs[uvIndex1] * maxCoord).clamp(0.0, maxCoord).toInt();
    final int y1 = ((1.0 - dartUVs[uvIndex1 + 1]) * maxCoord).clamp(0.0, maxCoord).toInt();
    final int x2 = (dartUVs[uvIndex2] * maxCoord).clamp(0.0, maxCoord).toInt();
    final int y2 = ((1.0 - dartUVs[uvIndex2 + 1]) * maxCoord).clamp(0.0, maxCoord).toInt();
    final int x3 = (dartUVs[uvIndex3] * maxCoord).clamp(0.0, maxCoord).toInt();
    final int y3 = ((1.0 - dartUVs[uvIndex3 + 1]) * maxCoord).clamp(0.0, maxCoord).toInt();

    img.drawLine(image, x1: x1, y1: y1, x2: x2, y2: y2, color: stroke);
    img.drawLine(image, x1: x2, y1: y2, x2: x3, y2: y3, color: stroke);
    img.drawLine(image, x1: x3, y1: y3, x2: x1, y2: y1, color: stroke);
  }

  return img.encodePng(image).toJS;
}