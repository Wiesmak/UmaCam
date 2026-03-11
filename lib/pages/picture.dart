import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

class UmaCamPicturePageRoute extends MaterialPageRoute<void> {
  UmaCamPicturePageRoute({required String imagePath}) : super(
    builder: (context) => UmaCamPicturePage(imagePath: imagePath),
  );
}

class UmaCamPicturePage extends HookWidget {
  const UmaCamPicturePage({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final overlay = useState(_Overlay.none);
    final isLoading = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyślij zdjęcie'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ImageEditor(imagePath, overlay: overlay),
                ),
                _PictureSendForm(
                  imagePath,
                  overlay: overlay.value,
                  scrollController: scrollController,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
          if (isLoading.value) LinearProgressIndicator(),
        ],
      ),
    );
  }
}

enum _Overlay implements Comparable<_Overlay> {
  none(0),
  ssrSpeed(1, name: 'SPD'),
  ssrStamina(2, name: 'STA'),
  ssrPower(3, name: 'PWR'),
  ssrGuts(4, name: 'GUTS'),
  ssrWit(5, name: 'WIT'),
  ssrPal(6, name: 'PAL');

  const _Overlay(this.order, {String? name}) : name = name ?? 'NONE';

  factory _Overlay.fromIndex(int index) {
    return switch (index) {
      -1 => _Overlay.ssrPal,
      0 => _Overlay.none,
      1 => _Overlay.ssrSpeed,
      2 => _Overlay.ssrStamina,
      3 => _Overlay.ssrPower,
      4 => _Overlay.ssrGuts,
      5 => _Overlay.ssrWit,
      6 => _Overlay.ssrPal,
      7 => _Overlay.none,
      _ => throw ArgumentError('Invalid index for _Overlays: $index'),
    };
  }

  final int order;
  final String name;

  @override
  int compareTo(_Overlay other) => order.compareTo(other.order);
}

class _ImageEditor extends StatelessWidget {
  const _ImageEditor(this.imagePath, {required this.overlay});

  final String imagePath;
  final ValueNotifier<_Overlay> overlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        switch (details.primaryVelocity) {
          case != null && > 0:
            HapticFeedback.lightImpact();
            overlay.value = _Overlay.fromIndex(overlay.value.index - 1);
          case != null && < 0:
            HapticFeedback.lightImpact();
            overlay.value = _Overlay.fromIndex(overlay.value.index + 1);
        }
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Container(
              padding: const EdgeInsets.all(2),
              alignment: Alignment.center,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (overlay.value != _Overlay.none)
            Image.asset(
              'assets/ssr_template/UmaMusumeTemplate${overlay.value.name}.png',
              fit: BoxFit.contain,
            ),
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.white,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              style: IconButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                overlay.value = _Overlay.fromIndex(overlay.value.index - 1);
              },
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              color: Colors.white,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              style: IconButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                overlay.value = _Overlay.fromIndex(overlay.value.index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PictureSendForm extends HookWidget {
  const _PictureSendForm(this.imagePath, {
    required this.overlay,
    required this.scrollController,
    required this.isLoading,
  });

  final String imagePath;
  final _Overlay overlay;
  final ScrollController scrollController;
  final ValueNotifier<bool> isLoading;

  @override
  Widget build(BuildContext context) {
    final state = useState(const _PictureFormState(
      sendToEmail: false,
      emailAddress: '',
      sendToInstagram: false,
      instagramUsername: '',
      postPublicly: true,
    ));

    final formKey = useMemoized(() => GlobalKey<FormState>());

    final emailFocusNode = useFocusNode();
    final instagramFocusNode = useFocusNode();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            value: state.value.sendToEmail,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Wyślij na email'),
            onChanged: (value) => {
              state.value = state.value.copyWith(sendToEmail: value ?? false),
              if (value == true) {
                emailFocusNode.requestFocus(),
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Durations.medium2,
                  curve: Easing.standard,
                ),
              },
            },
          ),
          AnimatedSize(
            duration: Durations.medium2,
            curve: Easing.standard,
            child: Visibility(
              visible: state.value.sendToEmail,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: TextFormField(
                  enabled: state.value.sendToEmail,
                  initialValue: state.value.emailAddress,
                  keyboardType: TextInputType.emailAddress,
                  focusNode: emailFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Adres email',
                    hintText: 'tokai.teio@umamusume.pl',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Podaj adres email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Podaj poprawny adres email';
                    }
                    return null;
                  },
                  onChanged: (value) => state.value = state.value.copyWith(
                    emailAddress: value,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: state.value.sendToInstagram,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Wyślij na Instagram'),
            onChanged: (value) => {
              state.value = state.value.copyWith(sendToInstagram: value ?? false),
              if (value == true) {
                instagramFocusNode.requestFocus(),
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Durations.medium2,
                  curve: Easing.standard,
                ),
              },
            },
          ),
          AnimatedSize(
            duration: Durations.medium2,
            curve: Easing.standard,
            child: Visibility(
              visible: state.value.sendToInstagram,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: TextFormField(
                  enabled: state.value.sendToInstagram,
                  initialValue: state.value.instagramUsername,
                  focusNode: instagramFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa użytkownika',
                    hintText: '@tokaiteio',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Podaj nazwę użytkownika';
                    }
                    final instaRegex = RegExp(r'^@?(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,29}$');
                    if (!instaRegex.hasMatch(value)) {
                      return 'Podaj poprawną nazwę użytkownika';
                    }
                    return null;
                  },
                  onChanged: (value) => state.value = state.value.copyWith(
                    instagramUsername: value,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: state.value.postPublicly,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Opublikuj na naszym Instagramie'),
            onChanged: (value) => state.value = state.value.copyWith(
              postPublicly: value ?? false,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: isLoading.value ? null : () async {
                if (formKey.currentState?.validate() ?? false) {
                  HapticFeedback.selectionClick();
                  //final file = await compute(_createPicture, _PictureSendParams(imagePath, overlay));
                  isLoading.value = true;
                  final file = await _createPicture(_PictureSendParams(imagePath, overlay));
                  final status = await _sendPicture(XFile(file.path));
                  isLoading.value = false;
                  if (context.mounted) {
                    switch (status){
                      case ShareResultStatus.success:
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('Zdjęcie zostało wysłane!'),
                          ),
                        );
                        HapticFeedback.successNotification();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      case ShareResultStatus.unavailable:
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('Nie udało się wysłać zdjęcia.'),
                          ),
                        );
                        HapticFeedback.errorNotification();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      case ShareResultStatus.dismissed:
                        HapticFeedback.warningNotification();
                    }
                  }
                }
              },
              child: const Text('Wyślij'),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PictureFormState extends Equatable {
  const _PictureFormState({
    required this.sendToEmail,
    required this.emailAddress,
    required this.sendToInstagram,
    required this.instagramUsername,
    required this.postPublicly,
  });

  final bool sendToEmail;
  final String emailAddress;
  final bool sendToInstagram;
  final String instagramUsername;
  final bool postPublicly;

  _PictureFormState copyWith({
    bool? sendToEmail,
    String? emailAddress,
    bool? sendToInstagram,
    String? instagramUsername,
    bool? postPublicly,
  }) {
    return _PictureFormState(
      sendToEmail: sendToEmail ?? this.sendToEmail,
      emailAddress: emailAddress ?? this.emailAddress,
      sendToInstagram: sendToInstagram ?? this.sendToInstagram,
      instagramUsername: instagramUsername ?? this.instagramUsername,
      postPublicly: postPublicly ?? this.postPublicly,
    );
  }

  @override
  List<Object?> get props => [
    sendToEmail,
    emailAddress,
    sendToInstagram,
    instagramUsername,
    postPublicly,
  ];
}

final class _PictureSendParams extends Equatable {
  const _PictureSendParams(this.imagePath, this.overlay);

  final String imagePath;
  final _Overlay overlay;

  @override
  List<Object?> get props => [imagePath, overlay];
}

Future<File> _createPicture(_PictureSendParams params) async {
  final imagePath = params.imagePath;
  final overlay = params.overlay;
  var photo = await img.decodeJpgFile(imagePath);
  if (photo == null) throw Exception('Could not decode photo');
  if (overlay != _Overlay.none) {
    final overlayImg = await rootBundle
        .load('assets/ssr_template/UmaMusumeTemplate${overlay.name}.png')
        .then((data) => img.decodePng(data.buffer.asUint8List()));
    if (overlayImg == null) throw Exception('Could not decode overlay image');
    photo = img.copyCrop(photo, x: 0, y: 0, width: photo.width, height: photo.height, radius: 300);
    img.compositeImage(
      photo,
      overlayImg,
      center: true,
      srcX: 15,
      srcY: 21,
      srcW: overlayImg.width - 30,
      srcH: overlayImg.height - 41,
    );
  }
  final tempDir = Directory.systemTemp;
  final date = DateTime.now();
  final timestamp = '${date.year}${date.month.toString().padLeft(2, '0')}${date
      .day.toString().padLeft(2, '0')}_${date.hour.toString().padLeft(
      2, '0')}${date.minute.toString().padLeft(2, '0')}${date.second
      .toString()
      .padLeft(2, '0')}';
  final outputPath = '${tempDir.path}/umacam-$timestamp.png';
  await img.encodePngFile(outputPath, photo);
  return File(outputPath);
}

Future<ShareResultStatus> _sendPicture(XFile file) async {
  final params = ShareParams(
    title: 'UmaCam Photo',
    text: 'Check my UmaCam photo!',
    files: [file],
  );

  final result = await SharePlus.instance.share(params);
  return result.status;
}