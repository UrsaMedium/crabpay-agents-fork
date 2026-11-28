import 'package:crabpay/core/backend/supabase/supabase_conf.dart';
import 'package:crabpay/core/set_up/get_it.dart';
import 'package:crabpay/core/local_storage/local_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: supabaseAccessConf['url']!,
      publishableKey: supabaseAccessConf['publishableKey']!,
    );
    await AppLocalStorage.init();
    setupDependencies();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        systemNavigationBarColor: Color(0x00000000),
        systemNavigationBarDividerColor: Color(0x00000000),
      ),
    );
  }
}
