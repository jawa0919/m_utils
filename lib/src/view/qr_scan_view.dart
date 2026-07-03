import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class QrScanView extends StatefulWidget {
  const QrScanView({super.key});

  static Uint8List qrPng(String text, {int sizePx = 200, int borderPx = 10}) {
    final result = zx.encodeBarcode(
      contents: text,
      params: EncodeParams(
        format: Format.qrCode,
        width: sizePx,
        height: sizePx,
        margin: borderPx,
        eccLevel: EccLevel.medium,
      ),
    );
    return pngFromBytes(result.data!, sizePx, sizePx);
  }

  @override
  State<QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  CameraController? _controller;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        scrolledUnderElevation: 0,
        centerTitle: true,
        shadowColor: null,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_search_rounded),
            onPressed: () => analyzeImage(),
          ),
        ],
      ),
      body: Stack(children: [_buildScanning(context), _buildTips(context)]),
    );
  }

  void analyzeImage() async {
    var file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    debugPrint('analyzeImage: ${file.path}');
    final DecodeParams params = DecodeParams(
      imageFormat: ImageFormat.rgb,
      format: Format.any,
      tryHarder: false,
      tryInverted: false,
      isMultiScan: false,
    );
    var result = await zx.readBarcodeImagePath(file, params);
    _onScanResult(result);
  }

  Widget _buildScanning(BuildContext context) {
    return ReaderWidget(
      showFlashlight: false,
      showGallery: false,
      showToggleCamera: false,
      onControllerCreated: (controller, error) {
        _controller = controller;
      },
      onScan: (result) => _onScanResult(result),
    );
  }

  void _onScanResult(Code result) async {
    debugPrint('_onScanResult :${result.text}');
    final text = result.text?.trim() ?? '';
    if (text.isEmpty) return;
    Navigator.of(context).maybePop(text);
  }

  Widget _buildTips(BuildContext context) {
    return Container();
    // return QrCodeScanAnimation();
  }
}

class QrCodeScanAnimation extends StatefulWidget {
  final double boxSize;
  const QrCodeScanAnimation({super.key, this.boxSize = 250});

  @override
  State<QrCodeScanAnimation> createState() => _QrCodeScanAnimationState();
}

class _QrCodeScanAnimationState extends State<QrCodeScanAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: ScannerPainter(
          _controller,
          Theme.of(context).colorScheme.primary,
        ),
        size: Size(widget.boxSize, widget.boxSize),
      ),
    );
  }
}

class ScannerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final double borderLength;

  ScannerPainter(
    this.animation,
    this.borderColor, {
    this.borderRadius = 8,
    this.borderWidth = 3,
    this.borderLength = 16,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 绘制四角圆角
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;
    Path path = Path()
      ..moveTo(borderRadius + borderLength, 0)
      ..lineTo(borderRadius, 0)
      ..quadraticBezierTo(0, 0, 0, borderRadius)
      ..lineTo(0, borderRadius + borderLength)
      ..moveTo(0, height - borderRadius - borderLength)
      ..lineTo(0, height - borderRadius)
      ..quadraticBezierTo(0, height, borderRadius, height)
      ..lineTo(borderRadius + borderLength, height)
      ..moveTo(width - borderRadius - borderLength, height)
      ..lineTo(width - borderRadius, height)
      ..quadraticBezierTo(width, height, width, height - borderRadius)
      ..lineTo(width, height - borderRadius - borderLength)
      ..moveTo(width, borderRadius + borderLength)
      ..lineTo(width, borderRadius)
      ..quadraticBezierTo(width, 0, width - borderRadius, 0)
      ..lineTo(width - borderRadius - borderLength, 0);
    canvas.drawPath(path, borderPaint);

    // 绘制扫描线
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, borderColor, Colors.transparent],
        stops: [0.1, 0.5, 0.9],
      ).createShader(Rect.fromLTWH(0, 0, width, 3))
      ..strokeWidth = 3;
    final lineY = height * animation.value;
    canvas.drawLine(Offset(0, lineY), Offset(width, lineY), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
