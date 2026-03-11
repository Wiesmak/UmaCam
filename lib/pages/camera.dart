import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:umacam/pages/pages.dart';

class UmaCamCameraPageRoute extends MaterialPageRoute<void> {
  UmaCamCameraPageRoute() : super(
    builder: (BuildContext context) => const UmaCamCameraPage(),
  );
}

class UmaCamCameraPage extends HookWidget {
  const UmaCamCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() => Future(() async {
      final cameras = await availableCameras();
      debugPrint('Available cameras: $cameras');
      final camera = cameras.firstWhere((camera) =>
        camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(camera, ResolutionPreset.max);
      await controller.initialize();
      return controller;
    }));

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: FutureBuilder<CameraController>(
          future: controller,
          builder: (context, snapshot) {
            return switch (snapshot.connectionState) {
              ConnectionState.done => _UmaCamCamera(controller: snapshot.data!),
              _ => const Center(child: CircularProgressIndicator()),
            };
          },
        ),
      ),
    );
  }
}

class _UmaCamCamera extends HookWidget {
  const _UmaCamCamera({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      return controller.dispose;
    }, [controller]);

    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (controller.value.aspectRatio * mediaSize.aspectRatio);
    return Stack(
      children: [
        ClipRect(
          clipper: _MediaSizeClipper(mediaSize),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: CameraPreview(controller),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 64),
          child: IconButton.filled(
            icon: const Icon(Icons.camera, size: 64),
            onPressed: () async {
              HapticFeedback.successNotification();
              final file = await controller.takePicture();
              if (context.mounted) {
                Navigator.of(context).push(UmaCamPicturePageRoute(
                  imagePath: file.path,
                ));
              }
            },
          ),
        ),
      ],
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  const _MediaSizeClipper(this.mediaSize);

  final Size mediaSize;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}