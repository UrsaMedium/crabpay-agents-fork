import 'package:crabpay/views/custom_ui_elements/utilities/app_expanding_circle_transition.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_upward_reveres_clipper.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/custom_faster_page_scroll_physics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final metrics = FixedScrollMetrics(
    minScrollExtent: 0,
    maxScrollExtent: 200,
    pixels: 0,
    viewportDimension: 100,
    axisDirection: AxisDirection.down,
    devicePixelRatio: 1,
  );

  group('AppUpwardReveresClipper', () {
    test('shouldReclip is true when radius changes', () {
      final clipper = AppUpwardReveresClipper(radius: 24, isUpward: true);
      expect(clipper.shouldReclip(AppUpwardReveresClipper(radius: 24, isUpward: true)), isFalse);
      expect(clipper.shouldReclip(AppUpwardReveresClipper(radius: 25, isUpward: true)), isTrue);
    });

    test('getClip returns a non-empty path', () {
      final path = AppUpwardReveresClipper(radius: 24, isUpward: true).getClip(const Size(100, 200));
      expect(path, isNotNull);
      expect(path.getBounds().isEmpty, isFalse);
    });
  });

  group('AppExpandingCircleTransitionClipper', () {
    test('getClip returns a non-empty path', () {
      final path = AppExpandingCircleTransitionClipper(center: Offset.zero, transitionFraction: 0.5).getClip(const Size(100, 100));
      expect(path, isNotNull);
      expect(path.getBounds().isEmpty, isFalse);
    });
  });

  group('CustomFasterPageScrollPhysics', () {
    test('multiplies the user offset by 3', () {
      const physics = CustomFasterPageScrollPhysics();
      expect(physics.applyPhysicsToUserOffset(metrics, 2), 6);
      expect(physics.applyPhysicsToUserOffset(metrics, 0), 0);
    });

    test('spring is mass 1, stiffness 500, damping 40', () {
      const physics = CustomFasterPageScrollPhysics();
      expect(physics.spring.mass, 1);
      expect(physics.spring.stiffness, 500);
      expect(physics.spring.damping, 40);
    });
  });
}
