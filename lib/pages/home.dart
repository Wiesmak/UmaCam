import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:umacam/pages/pages.dart';

class UmaCamHomePageRoute extends MaterialPageRoute<void> {
  UmaCamHomePageRoute() : super(
    builder: (context) => const UmaCamHomePage(title: 'UmaCam Home'),
  );
}

class UmaCamHomePage extends HookWidget {
  const UmaCamHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);
    final imageData = useState<Uint8List?>(null);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '${counter.value}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            IconButton.filled(
              icon: Icon(Icons.camera_alt),
              onPressed: () => Navigator.push(context, UmaCamCameraPageRoute()),
            ),
            if (imageData.value != null) ...[
              const SizedBox(height: 16),
              Image.memory(imageData.value!),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counter.value++,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

void readPsd({required ValueNotifier<Uint8List?> valueNotifier}) async {
  final data = await rootBundle.load('assets/ssr_template/UmaMusumeTemplateGUTS.png');
  final bytes = data.buffer.asUint8List();
  final image = img.decodePng(bytes);
  if (image != null) {
    final pngBytes = img.encodePng(image);
    valueNotifier.value = Uint8List.fromList(pngBytes);
  }
}