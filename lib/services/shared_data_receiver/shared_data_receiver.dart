import 'dart:async';
import 'dart:io';

import 'package:flashcards/services/platform_utils.dart';
import 'package:flutter/services.dart';
part '_shared_data_receiver_android_impl.dart';
part '_shared_data_receiver_ios_impl.dart';

enum SharedDataReceivedType { FILE_LINES, UNKNOWN }

abstract class SharedDataReceiver {
  Future<bool> hasData();
  Future<void> discard();
  Future<List<String>> receiveFileLines();
  Stream<SharedDataReceivedType> dataReceivedStream();
  bool get isAvailableInCurrentPlatform;

  factory SharedDataReceiver.create() {
    if (Platform.isAndroid) {
      return _SharedDataReceiverAndroidImpl();
    } else if (Platform.isIOS) {
      return _SharedDataReceiverIosImpl();
    }
    throw UnimplementedError();
  }
}
