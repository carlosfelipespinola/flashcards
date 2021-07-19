
import 'package:flashcards/services/app_info/app_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoImpl implements AppInfo {

  PackageInfo? _packageInfo;

  Future<void> loadInfos() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (error) {
      print(error);
    }
  }

  @override
  String? get appVersion => _packageInfo?.version;

  @override
  String? get appIconPath => 'assets/icon/icon.png';

}