import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_link_opener.dart';
import 'package:url_launcher/url_launcher.dart';

/// I link si aprono nel browser del telefono, fuori dall'app.
class BrowserLinkOpener implements ILinkOpener {
  const BrowserLinkOpener();

  @override
  Future<Validation<bool>> open(String url) async {
    try {
      return Valid(await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication));
    } catch (e) {
      return Fail.withError(e is Error ? e : StateError('$e'), message: '$e').toInvalid();
    }
  }
}
