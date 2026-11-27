import 'package:crabpay/core/backend/chat_service/chat_inner_circle/chat_bloc/chat_bloc.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/support_page/driver/support_page_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppLayoutCubit buildLayoutCubit() {
    return AppLayoutCubit(
      observeBinding: false,
      metricsReader: () => (width: 800, topPadding: 0, bottomPadding: 0),
    );
  }

  ChatBloc buildChatBloc() {
    final authInterface = MockAuthInnerInterface();
    when(() => authInterface.userStream).thenAnswer((_) => Stream.empty());
    final chatBloc = ChatBloc(
      chatHandler: MockInnerChatHandler(),
      authInterface: authInterface,
    );
    addTearDown(chatBloc.close);
    return chatBloc;
  }

  SupportPageCubit buildCubit(AppLayoutCubit layoutCubit) {
    final cubit = SupportPageCubit(
      chatBloc: buildChatBloc(),
      scrollController: ScrollController(),
      textEdditingController: TextEditingController(),
      user: makeAuthUser(),
      layoutCubit: layoutCubit,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  group('SupportPageCubit layout', () {
    test('derives layout metrics from AppLayoutCubit and syncs on changes', () async {
      const AppLayoutConfig config = AppLayoutConfig();
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = buildCubit(layoutCubit);

      expect(cubit.state.layout.pageWidth, closeTo(512, 1e-9));
      expect(cubit.state.layout.padding, closeTo(512 * config.standardPaddingCoeff, 1e-9));
      expect(cubit.state.layout.outerCornerRadius, closeTo(512 * config.cornerRadiusCoeff, 1e-9));

      layoutCubit.updateMetrics(rawWidth: 360, topPadding: 24, bottomPadding: 34);
      await pumpEventQueue();

      final layout = cubit.state.layout;
      expect(layout.pageWidth, closeTo(360, 1e-9));
      expect(layout.topPadding, closeTo(layoutCubit.state.pageTopPadding, 1e-9));
      expect(layout.bottomPadding, closeTo(layoutCubit.state.pageBottomPadding, 1e-9));
      expect(layout.bannerTopOffset, closeTo(layout.topPadding + layout.padding, 1e-9));
      expect(layout.inputBarBottomOffset, closeTo(layout.bottomPadding + layout.padding, 1e-9));
    });

    test('keeps messages and the down arrow clear of the floating bars', () async {
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = buildCubit(layoutCubit);

      layoutCubit.updateMetrics(rawWidth: 360, topPadding: 24, bottomPadding: 34);
      await pumpEventQueue();

      final layout = cubit.state.layout;
      expect(
        layout.messagesListPadding.top,
        greaterThan(layout.bannerTopOffset + layout.bannerMinHeight),
      );
      expect(
        layout.messagesListPadding.bottom,
        greaterThan(layout.inputBarBottomOffset + layout.inputBarMinHeight),
      );
      expect(
        layout.downArrowBottomOffset,
        greaterThan(layout.inputBarBottomOffset + layout.inputBarMinHeight),
      );
      expect(layout.inputBarCornerRadius, closeTo(layout.inputBarMinHeight / 2, 1e-9));
    });

    test('clamps the page width to the configured minimum', () async {
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = buildCubit(layoutCubit);

      layoutCubit.updateMetrics(rawWidth: 80);
      await pumpEventQueue();

      expect(cubit.state.layout.pageWidth, closeTo(320, 1e-9));
    });

    test('close cancels layout updates', () async {
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = buildCubit(layoutCubit);
      final emitted = <SupportPageState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await cubit.close();
      layoutCubit.updateMetrics(rawWidth: 300);
      await pumpEventQueue();

      expect(emitted, isEmpty);
    });
  });
}
