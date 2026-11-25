import 'package:crabpay/core/global_language_driver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlobalLanguageCubit', () {
    test('starts with isRu false', () {
      final cubit = GlobalLanguageCubit();
      addTearDown(cubit.close);
      expect(cubit.state.isRu, isFalse);
    });

    test('setRuLang(isRu: true) makes state isRu true', () {
      final cubit = GlobalLanguageCubit();
      addTearDown(cubit.close);
      cubit.setRuLang(isRu: true);
      expect(cubit.state.isRu, isTrue);
    });

    test('setRuLang(isRu: false) turns it back off', () {
      final cubit = GlobalLanguageCubit();
      addTearDown(cubit.close);
      cubit.setRuLang(isRu: true);
      cubit.setRuLang(isRu: false);
      expect(cubit.state.isRu, isFalse);
    });

    test('copyWith preserves isRu when omitted and overrides it when given', () {
      const state = GlobalLanguageState(isRu: true);
      expect(state.copyWith().isRu, isTrue);
      expect(state.copyWith(isRu: false).isRu, isFalse);
    });
  });
}
