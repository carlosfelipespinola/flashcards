import 'dart:async';

import 'package:flashcards/services/shared_data_receiver/shared_data_receiver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'flashcards_import_dialog.dart';

class SharedFlashcardsImporterWidget extends StatefulWidget {
  final VoidCallback? beforeShowImportDialog;
  final void Function() onFlashcardsImported;
  final Widget child;
  const SharedFlashcardsImporterWidget(
      {Key? key, required this.child, required this.onFlashcardsImported, this.beforeShowImportDialog})
      : super(key: key);

  @override
  State<SharedFlashcardsImporterWidget> createState() => _SharedDataReceiverWidgetState();
}

class _SharedDataReceiverWidgetState extends State<SharedFlashcardsImporterWidget> {
  bool shouldHideFloatingActionButton = false;
  SharedDataReceiver _sharedDataReceiver = GetIt.I();
  StreamSubscription<SharedDataReceivedType>? _dataReceivedStreamSubscription;
  bool _isImportDialogOpened = false;

  @override
  void initState() {
    super.initState();
    _asyncInit();
  }

  @override
  void dispose() {
    super.dispose();
    _dataReceivedStreamSubscription?.cancel();
  }

  Future<void> _asyncInit() async {
    await tryReceivingSharedContent();
    _dataReceivedStreamSubscription = _sharedDataReceiver.dataReceivedStream().listen((event) {
      if (event == SharedDataReceivedType.FILE_LINES && mounted && !_isImportDialogOpened) {
        _showDialogToImportSharedData();
      }
    });
  }

  Future<void> tryReceivingSharedContent() async {
    if (!_sharedDataReceiver.isAvailableInCurrentPlatform) return;

    try {
      if (!await _sharedDataReceiver.hasData()) return;

      if (!mounted) return;

      await _showDialogToImportSharedData();
    } catch (_) {
      if (kDebugMode) rethrow;
    }
  }

  Future<void> _showDialogToImportSharedData() async {
    _isImportDialogOpened = true;
    widget.beforeShowImportDialog?.call();

    await showDialog(context: context, builder: (context) => FlashcardsImportDialog(dataReceiver: _sharedDataReceiver));

    if (mounted) {
      widget.onFlashcardsImported();
    }

    try {
      await _sharedDataReceiver.discard();
    } catch (_) {
      if (kDebugMode) rethrow;
    }

    _isImportDialogOpened = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}
