import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/chat_bloc/chat_bloc.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/chat_bloc/chat_state.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/chat_message_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Every layout value the support page needs, derived once per layout sync so
/// the views can render them without any arithmetic.
@immutable
class SupportPageLayout extends Equatable {
  /// Platform safe area plus the in-app top bar height.
  final double topPadding;

  /// Platform safe area plus the in-app bottom navigation bar height.
  final double bottomPadding;

  /// Full page width, capped by the app layout.
  final double pageWidth;

  final double screenEdgePadding;
  final double padding;
  final double outerCornerRadius;

  /// Horizontal padding around the whole page.
  final EdgeInsets pageHorizontalPadding;

  final double bannerTopOffset;
  final double bannerHorizontalInset;
  final double bannerMinHeight;
  final double bannerCornerRadius;
  final EdgeInsets bannerContentPadding;
  final double bannerIconSize;
  final double bannerFontSize;

  final double inputBarBottomOffset;
  final double inputBarHorizontalInset;
  final double inputBarMinHeight;
  final double inputBarCornerRadius;
  final double inputFontSize;

  final double downArrowBottomOffset;
  final double downArrowRightInset;
  final double downArrowCornerRadius;
  final double downArrowBadgeSize;

  /// Padding that keeps messages clear of the floating banner and input bar.
  final EdgeInsets messagesListPadding;

  final double bubbleCornerRadius;
  final double bubbleBottomMargin;
  final double bubbleNearHorizontalPadding;
  final double bubbleFarHorizontalPadding;
  final EdgeInsets bubbleContentPadding;
  final double bubbleTextFontSize;
  final double bubbleTimestampFontSize;

  const SupportPageLayout({
    required this.topPadding,
    required this.bottomPadding,
    required this.pageWidth,
    required this.screenEdgePadding,
    required this.padding,
    required this.outerCornerRadius,
    required this.pageHorizontalPadding,
    required this.bannerTopOffset,
    required this.bannerHorizontalInset,
    required this.bannerMinHeight,
    required this.bannerCornerRadius,
    required this.bannerContentPadding,
    required this.bannerIconSize,
    required this.bannerFontSize,
    required this.inputBarBottomOffset,
    required this.inputBarHorizontalInset,
    required this.inputBarMinHeight,
    required this.inputBarCornerRadius,
    required this.inputFontSize,
    required this.downArrowBottomOffset,
    required this.downArrowRightInset,
    required this.downArrowCornerRadius,
    required this.downArrowBadgeSize,
    required this.messagesListPadding,
    required this.bubbleCornerRadius,
    required this.bubbleBottomMargin,
    required this.bubbleNearHorizontalPadding,
    required this.bubbleFarHorizontalPadding,
    required this.bubbleContentPadding,
    required this.bubbleTextFontSize,
    required this.bubbleTimestampFontSize,
  });

  factory SupportPageLayout.fromAppLayout(AppLayoutState layout) {
    final double topPadding = math.max(0.0, layout.pageTopPadding);
    final double bottomPadding = math.max(0.0, layout.pageBottomPadding);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double outerCornerRadius = math.max(0.0, layout.cornerRadius);

    final double bannerTopOffset = topPadding + padding;
    final double bannerMinHeight = (layout.width * 0.24).clamp(88.0, 112.0).toDouble();
    final double inputBarBottomOffset = bottomPadding + padding;
    final double inputBarMinHeight = math.max(48.0, layout.appBarHeight);

    return SupportPageLayout(
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      pageWidth: math.max(0.0, layout.width),
      screenEdgePadding: screenEdgePadding,
      padding: padding,
      outerCornerRadius: outerCornerRadius,
      pageHorizontalPadding: EdgeInsets.symmetric(horizontal: padding / 2),
      bannerTopOffset: bannerTopOffset,
      bannerHorizontalInset: screenEdgePadding * 1.5,
      bannerMinHeight: bannerMinHeight,
      bannerCornerRadius: outerCornerRadius,
      bannerContentPadding: EdgeInsets.symmetric(horizontal: screenEdgePadding, vertical: padding),
      bannerIconSize: (layout.bigFontSize * 1.25).clamp(22.0, 28.0).toDouble(),
      bannerFontSize: layout.mediumFontSize.clamp(13.0, 17.0).toDouble(),
      inputBarBottomOffset: inputBarBottomOffset,
      inputBarHorizontalInset: padding / 2,
      inputBarMinHeight: inputBarMinHeight,
      inputBarCornerRadius: inputBarMinHeight / 2,
      inputFontSize: layout.mediumFontSize.clamp(14.0, 17.0).toDouble(),
      downArrowBottomOffset: inputBarBottomOffset + inputBarMinHeight + padding * 2,
      downArrowRightInset: screenEdgePadding,
      downArrowCornerRadius: outerCornerRadius,
      downArrowBadgeSize: (padding * 1.2).clamp(8.0, 12.0).toDouble(),
      messagesListPadding: EdgeInsets.only(
        top: bannerTopOffset + bannerMinHeight + padding,
        bottom: inputBarBottomOffset + inputBarMinHeight + padding,
      ),
      bubbleCornerRadius: outerCornerRadius,
      bubbleBottomMargin: padding / 2,
      bubbleNearHorizontalPadding: padding,
      bubbleFarHorizontalPadding: (layout.width * 0.16).clamp(48.0, 80.0).toDouble(),
      bubbleContentPadding: EdgeInsets.symmetric(horizontal: screenEdgePadding, vertical: padding * 1.25),
      bubbleTextFontSize: layout.mediumFontSize.clamp(14.0, 17.0).toDouble(),
      bubbleTimestampFontSize: layout.tinyFontSize.clamp(10.0, 12.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    topPadding,
    bottomPadding,
    pageWidth,
    screenEdgePadding,
    padding,
    outerCornerRadius,
    pageHorizontalPadding,
    bannerTopOffset,
    bannerHorizontalInset,
    bannerMinHeight,
    bannerCornerRadius,
    bannerContentPadding,
    bannerIconSize,
    bannerFontSize,
    inputBarBottomOffset,
    inputBarHorizontalInset,
    inputBarMinHeight,
    inputBarCornerRadius,
    inputFontSize,
    downArrowBottomOffset,
    downArrowRightInset,
    downArrowCornerRadius,
    downArrowBadgeSize,
    messagesListPadding,
    bubbleCornerRadius,
    bubbleBottomMargin,
    bubbleNearHorizontalPadding,
    bubbleFarHorizontalPadding,
    bubbleContentPadding,
    bubbleTextFontSize,
    bubbleTimestampFontSize,
  ];
}

@immutable
class SupportPageState extends Equatable {
  final bool showDownScrollArrow;
  final ScrollController scrollController;
  final TextEditingController messageInputController;
  final bool isSubscribed;
  final AppAuthUser currentUser;
  final List<ChatMessage>? messages;
  final ChatMessage? sentMessage;
  final bool isGettingThread;
  final bool isSenndingMessage;
  final SupportPageLayout layout;

  const SupportPageState({
    this.showDownScrollArrow = false,
    required this.scrollController,
    required this.messageInputController,
    this.isSubscribed = false,
    required this.currentUser,
    this.messages,
    this.isGettingThread = false,
    this.isSenndingMessage = false,
    this.sentMessage,
    required this.layout,
  });

  /// Builds the state with every derived layout value from [layout].
  factory SupportPageState.fromLayout(
    AppLayoutState layout, {
    required ScrollController scrollController,
    required TextEditingController messageInputController,
    required AppAuthUser currentUser,
  }) => SupportPageState(
    scrollController: scrollController,
    messageInputController: messageInputController,
    currentUser: currentUser,
    layout: SupportPageLayout.fromAppLayout(layout),
  );

  SupportPageState copyWith({
    bool? showDownScrollArrow,
    ScrollController? scrollController,
    TextEditingController? messageInputController,
    bool? isSubscribed,
    AppAuthUser? currentUser,
    List<ChatMessage>? messages,
    bool? isGettingThread,
    bool? isSendingMessage,
    ChatMessage? sentMessage,
    SupportPageLayout? layout,
  }) {
    return SupportPageState(
      showDownScrollArrow: showDownScrollArrow ?? this.showDownScrollArrow,
      scrollController: scrollController ?? this.scrollController,
      messageInputController: messageInputController ?? this.messageInputController,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      currentUser: currentUser ?? this.currentUser,
      messages: messages ?? this.messages,
      isGettingThread: isGettingThread ?? this.isGettingThread,
      isSenndingMessage: isSendingMessage ?? isSenndingMessage,
      sentMessage: sentMessage ?? this.sentMessage,
      layout: layout ?? this.layout,
    );
  }

  @override
  List<Object?> get props => [
    showDownScrollArrow,
    scrollController,
    messageInputController,
    isSubscribed,
    currentUser,
    isGettingThread,
    messages,
    sentMessage,
    isSenndingMessage,
    layout,
  ];
}

class SupportPageCubit extends Cubit<SupportPageState> {
  final ChatBloc _chatBloc;
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _chatSubscription;
  late final StreamSubscription _layoutSubscription;
  SupportPageCubit({
    required ChatBloc chatBloc,
    required ScrollController scrollController,
    required TextEditingController textEdditingController,
    required AppAuthUser user,
    required AppLayoutCubit layoutCubit,
  }) : _chatBloc = chatBloc,
       _appLayoutCubit = layoutCubit,
       super(
         SupportPageState.fromLayout(
           layoutCubit.state,
           scrollController: scrollController,
           messageInputController: textEdditingController,
           currentUser: user,
         ),
       ) {
    final msgs = chatBloc.state.messages;
    emit(state.copyWith(messages: msgs));
    _chatSubscription = _chatBloc.stream.listen((chatState) {
      _syncChatBloc(chatState);
    });
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: SupportPageLayout.fromAppLayout(layout)),
  );

  void _syncChatBloc(ChatState chatState) {
    if (chatState.status == ChatStates.messagesUpdated) {
      _onNewMessage(chatState.messages ?? []);
    }
    _whatchSubStatus(chatState);
    if (chatState.status == ChatStates.messageSent || chatState.status == ChatStates.shadowMessageSent) {
      final msgs = state.messages == null ? <ChatMessage>[] : [...state.messages!];
      if (state.sentMessage != null) {
        msgs.add(state.sentMessage!);
        emit(state.copyWith(isSendingMessage: false, messages: msgs));
      } else {
        emit(state.copyWith(isSendingMessage: false));
      }
    } else if (chatState.status == ChatStates.messageSentFailed || chatState.status == ChatStates.shadowMessageSentFailed) {
      emit(state.copyWith(isSendingMessage: false));
      Fluttertoast.showToast(msg: 'failedToSendTheMessage');
    }
  }

  void _whatchSubStatus(ChatState chatState) {
    if (state.isSubscribed != chatState.isSubscribed) {
      emit(
        state.copyWith(
          isSubscribed: chatState.isSubscribed,
          isGettingThread: false,
        ),
      );
    } else if (chatState.status == ChatStates.error) {
      emit(state.copyWith(isGettingThread: false));
    }
  }

  void _onNewMessage(List<ChatMessage> messages) {
    emit(state.copyWith(messages: messages));
    if (state.scrollController.hasClients) {
      final currentOffset = state.scrollController.offset;
      if (currentOffset <= 300) {
        state.scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _setArrowState(true);
      }
    }
  }

  void onDonwArrowPressed() {
    state.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _setArrowState(false);
  }

  void _setArrowState(bool doShow) {
    emit(state.copyWith(showDownScrollArrow: doShow));
  }

  void setGettingThreadState(bool isGettingThread) {
    emit(state.copyWith(isGettingThread: isGettingThread));
  }

  void setSendingMessageState(bool isSenndingMessage, String message) {
    final thread = state.messages?.last.threadId ?? '';
    emit(
      state.copyWith(
        isSendingMessage: isSenndingMessage,
        sentMessage: ChatMessage(
          id: 'sending',
          threadId: thread,
          senderId: state.currentUser.id,
          content: message,
          isRead: false,
          createdAt: DateTime.now(),
          sending: true,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _chatSubscription.cancel();
    _layoutSubscription.cancel();
    return super.close();
  }
}
