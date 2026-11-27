import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/chat_message_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:material_ui/material_ui.dart';

class ChatBubbleDriver extends StatefulWidget {
  final ChatMessage message;
  final AppAuthUser author;
  final double? cornerRadius;
  final double? bottomMargin;
  final double? nearHorizontalPadding;
  final double? farHorizontalPadding;
  final EdgeInsets? contentPadding;
  final double? textFontSize;
  final double? timestampFontSize;
  const ChatBubbleDriver({
    super.key,
    required this.message,
    required this.author,
    this.cornerRadius,
    this.bottomMargin,
    this.nearHorizontalPadding,
    this.farHorizontalPadding,
    this.contentPadding,
    this.textFontSize,
    this.timestampFontSize,
  });

  @override
  State<ChatBubbleDriver> createState() => _ChatBubbleDriverState();
}

class _ChatBubbleDriverState extends State<ChatBubbleDriver> {
  @override
  Widget build(BuildContext context) {
    return MaterialChatBubble(
      content: widget.message.content,
      isMe: widget.message.senderId == widget.author.id,
      createdAt: widget.message.createdAt,
      sending: widget.message.sending ?? false,
      cornerRadius: widget.cornerRadius,
      bottomMargin: widget.bottomMargin,
      nearHorizontalPadding: widget.nearHorizontalPadding,
      farHorizontalPadding: widget.farHorizontalPadding,
      contentPadding: widget.contentPadding,
      textFontSize: widget.textFontSize,
      timestampFontSize: widget.timestampFontSize,
    );
  }
}

class MaterialChatBubble extends StatelessWidget {
  final bool isMe;
  final String content;
  final DateTime createdAt;
  final bool sending;
  final double? cornerRadius;
  final double? bottomMargin;
  final double? nearHorizontalPadding;
  final double? farHorizontalPadding;
  final EdgeInsets? contentPadding;
  final double? textFontSize;
  final double? timestampFontSize;
  const MaterialChatBubble({
    super.key,
    required this.isMe,
    required this.content,
    required this.createdAt,
    required this.sending,
    this.cornerRadius,
    this.bottomMargin,
    this.nearHorizontalPadding,
    this.farHorizontalPadding,
    this.contentPadding,
    this.textFontSize,
    this.timestampFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomMargin ?? 4.0,
        right: isMe ? (nearHorizontalPadding ?? 8) : (farHorizontalPadding ?? 64),
        left: isMe ? (farHorizontalPadding ?? 64) : (nearHorizontalPadding ?? 8),
      ),
      child: Align(
        alignment: isMe ? AlignmentGeometry.centerRight : AlignmentGeometry.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isMe ? context.appColorScheme.primary : context.appColorScheme.secondary,
            borderRadius: .circular(cornerRadius ?? 24),
          ),
          child: Padding(
            padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
            child: Wrap(
              alignment: .end,
              crossAxisAlignment: .end,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  content,
                  textAlign: .left,
                  style: TextStyle(
                    fontSize: textFontSize ?? 16,
                    color: isMe ? context.appColorScheme.onPrimary : context.appColorScheme.onSecondary,
                  ),
                ),
                Text(
                  '${createdAt.hour}:${createdAt.minute}',
                  style: TextStyle(
                    color: context.appColorScheme.onPrimary,
                    fontSize: timestampFontSize ?? 10,
                  ),
                ),
                if (sending)
                  Text(
                    '◴',
                    style: TextStyle(
                      color: context.appColorScheme.onPrimary,
                      fontSize: 13,
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
