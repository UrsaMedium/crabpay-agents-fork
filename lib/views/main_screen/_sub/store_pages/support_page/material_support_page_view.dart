import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/chat_message_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/chat_bubble.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/support_page/driver/support_page_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaterialSupportPageView extends StatelessWidget {
  final VoidCallback onSendPressed;
  final VoidCallback onDonwArrowPressed;
  final VoidCallback onStartChatPressed;
  const MaterialSupportPageView({
    super.key,
    required this.onSendPressed,
    required this.onDonwArrowPressed,
    required this.onStartChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.select<SupportPageCubit, SupportPageLayout>(
      (cubit) => cubit.state.layout,
    );
    final messages = context.select<SupportPageCubit, List<ChatMessage>>(
      (cubit) => cubit.state.messages ?? [],
    );
    final isChatStarted = context.select<SupportPageCubit, bool>(
      (cubit) => cubit.state.isSubscribed,
    );
    final showDownArrow = context.select<SupportPageCubit, bool>(
      (cubit) => cubit.state.showDownScrollArrow,
    );
    final isGettingThread = context.select<SupportPageCubit, bool>(
      (cubit) => cubit.state.isGettingThread,
    );
    return Center(
      child: SizedBox(
        width: layout.pageWidth,
        child: Scaffold(
          body: Padding(
            padding: layout.pageHorizontalPadding,
            child: Stack(
              children: [
                ListView.builder(
                  controller: context.read<SupportPageCubit>().state.scrollController,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  // addAutomaticKeepAlives: true,
                  reverse: true,
                  itemCount: messages.length,
                  padding: layout.messagesListPadding,
                  itemBuilder: (context, index) {
                    return ChatBubbleDriver(
                      message: messages[messages.length - 1 - index],
                      author: context.read<SupportPageCubit>().state.currentUser,
                      cornerRadius: layout.bubbleCornerRadius,
                      bottomMargin: layout.bubbleBottomMargin,
                      nearHorizontalPadding: layout.bubbleNearHorizontalPadding,
                      farHorizontalPadding: layout.bubbleFarHorizontalPadding,
                      contentPadding: layout.bubbleContentPadding,
                      textFontSize: layout.bubbleTextFontSize,
                      timestampFontSize: layout.bubbleTimestampFontSize,
                    );
                  },
                ),
                if (!isChatStarted && !isGettingThread)
                  Center(
                    child: TextButton(
                      onPressed: () => onStartChatPressed(),
                      child: Text(
                        context.l10n.startTheChat,
                        style: TextStyle(fontSize: layout.bannerFontSize),
                      ),
                    ),
                  ),
                if (isGettingThread) Center(child: CircularProgressIndicator()),
                Positioned(
                  top: layout.bannerTopOffset,
                  right: layout.bannerHorizontalInset,
                  left: layout.bannerHorizontalInset,
                  child: Stack(
                    children: [
                      Builder(
                        builder: (context) {
                          final highGraphics = context.select<GlobalGraphicBloc, bool>(
                            (bloc) => bloc.state.highGraphics,
                          );
                          return Material(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: .circular(layout.bannerCornerRadius),
                            ),
                            clipBehavior: .antiAlias,
                            child: BackdropFilter(
                              enabled: highGraphics,
                              filter: .blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                color: context.appColorScheme.surfaceContainer.withValues(
                                  alpha: highGraphics ? .5 : .97,
                                ),
                                constraints: BoxConstraints(minHeight: layout.bannerMinHeight),
                                child: Padding(
                                  padding: layout.bannerContentPadding,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.support_agent_rounded,
                                          size: layout.bannerIconSize,
                                        ),
                                        Text(
                                          context.l10n.contctOurSupportTeamFoAssistance,
                                          textAlign: .center,
                                          style: TextStyle(
                                            fontSize: layout.bannerFontSize,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: .topCenter,
                              end: .bottomCenter,
                              colors: [
                                context.appColorScheme.outline.withValues(alpha: .2),
                                context.appColorScheme.outline.withValues(alpha: .1),
                                Colors.transparent,
                                Colors.transparent,
                                context.appColorScheme.outline.withValues(alpha: .1),
                              ],
                            ).createShader(bounds),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: .circular(layout.bannerCornerRadius),
                                border: .all(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showDownArrow)
                  Positioned(
                    bottom: layout.downArrowBottomOffset,
                    right: layout.downArrowRightInset,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.appColorScheme.surface,
                        borderRadius: .circular(layout.downArrowCornerRadius),
                      ),
                      child: Badge(
                        isLabelVisible: true,
                        smallSize: layout.downArrowBadgeSize,
                        child: IconButton(
                          onPressed: onDonwArrowPressed,
                          iconSize: layout.actionIconSize,
                          icon: Icon(Icons.arrow_downward_rounded),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: layout.inputBarBottomOffset,
                  right: layout.inputBarHorizontalInset,
                  left: layout.inputBarHorizontalInset,
                  child: Stack(
                    children: [
                      Builder(
                        builder: (context) {
                          final highGraphics = context.select<GlobalGraphicBloc, bool>(
                            (bloc) => bloc.state.highGraphics,
                          );
                          return Material(
                            color: Colors.transparent,
                            borderRadius: .circular(layout.inputBarCornerRadius),
                            clipBehavior: .antiAlias,
                            child: BackdropFilter(
                              enabled: highGraphics,
                              filter: .blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                color: context.appColorScheme.primaryContainer.withValues(
                                  alpha: highGraphics ? .4 : .97,
                                ),
                                constraints: BoxConstraints(minHeight: layout.inputBarMinHeight),
                                child: Row(
                                  crossAxisAlignment: .end,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        enabled: isChatStarted,
                                        controller: context.read<SupportPageCubit>().state.messageInputController,
                                        style: TextStyle(fontSize: layout.inputFontSize),
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 4,
                                        minLines: 1,
                                        decoration: InputDecoration(
                                          fillColor: Colors.transparent,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hint: Text(
                                            context.l10n.typeYourQuestion,
                                            style: TextStyle(fontSize: layout.inputFontSize),
                                          ),
                                          filled: true,
                                        ),
                                      ),
                                    ),
                                    Builder(
                                      builder: (context) {
                                        final isSendingMessage = context.select<SupportPageCubit, bool>(
                                          (cubit) => cubit.state.isSenndingMessage,
                                        );
                                        return IconButton(
                                          onPressed: !isChatStarted
                                              ? null
                                              : isSendingMessage
                                              ? null
                                              : onSendPressed,
                                          icon: isSendingMessage
                                              ? CircularProgressIndicator()
                                              : Icon(Icons.send, size: layout.actionIconSize),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: .topCenter,
                              end: .bottomCenter,
                              colors: [
                                context.appColorScheme.outline.withValues(alpha: .2),
                                context.appColorScheme.outline.withValues(alpha: .1),
                                Colors.transparent,
                                Colors.transparent,
                                context.appColorScheme.outline.withValues(alpha: .1),
                              ],
                            ).createShader(bounds),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: .circular(layout.inputBarCornerRadius),
                                border: .all(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
