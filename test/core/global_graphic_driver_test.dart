import 'package:bloc_test/bloc_test.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlobalGraphicBloc', () {
    test('starts with highGraphics false', () {
      final bloc = GlobalGraphicBloc();
      addTearDown(bloc.close);
      expect(bloc.state, const GlobalGraphicState(highGraphics: false));
    });

    blocTest<GlobalGraphicBloc, GlobalGraphicState>(
      'emits highGraphics true when GlobalGraphicEventSetHigh is added',
      build: () => GlobalGraphicBloc(),
      act: (bloc) => bloc.add(GlobalGraphicEventSetHigh()),
      expect: () => <GlobalGraphicState>[const GlobalGraphicState(highGraphics: true)],
    );

    blocTest<GlobalGraphicBloc, GlobalGraphicState>(
      'emits highGraphics false when GlobalGraphicEventSetLow is added',
      build: () => GlobalGraphicBloc(),
      seed: () => const GlobalGraphicState(highGraphics: true),
      act: (bloc) => bloc.add(GlobalGraphicEventSetLow()),
      expect: () => <GlobalGraphicState>[const GlobalGraphicState(highGraphics: false)],
    );
  });
}
