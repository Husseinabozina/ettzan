import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/chat_composer.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/chat_message_bubble.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coach_chat_header.dart';

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  late Future<CoachChatThread> _future;
  final _messageController = TextEditingController();

  StreamSubscription<List<ChatMessageItem>>? _messagesSubscription;
  String? _watchedConversationId;
  List<ChatMessageItem>? _messages;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _future = _loadThread();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<CoachChatThread> _loadThread() async {
    final thread = await getIt<EtzanBackendRepository>().getOrCreateCoachChat();
    _watchMessages(thread);
    return thread;
  }

  void _watchMessages(CoachChatThread thread) {
    if (_watchedConversationId == thread.conversationId) return;

    _watchedConversationId = thread.conversationId;
    _messages = thread.messages;
    _messagesSubscription?.cancel();

    _messagesSubscription = getIt<EtzanBackendRepository>()
        .watchChatMessages(thread.conversationId)
        .listen((messages) {
      if (!mounted) return;

      setState(() {
        final pendingMessages =
            (_messages ?? const <ChatMessageItem>[]).where((message) {
          return message.isPending &&
              !messages.any(
                (saved) => saved.isMine && saved.body == message.body,
              );
        });

        _messages = [...messages, ...pendingMessages];
      });
    });
  }

  void _reload() {
    _messagesSubscription?.cancel();

    setState(() {
      _messages = null;
      _watchedConversationId = null;
      _future = _loadThread();
    });
  }

  Future<void> _send(CoachChatThread thread) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    final pendingMessage = ChatMessageItem(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: thread.conversationId,
      senderId: '',
      body: text,
      createdAt: DateTime.now(),
      isMine: true,
      isPending: true,
    );

    setState(() {
      _sending = true;
      _messageController.clear();
      _messages = [
        ...(_messages ?? thread.messages),
        pendingMessage,
      ];
    });

    try {
      final savedMessage =
          await getIt<EtzanBackendRepository>().sendChatMessage(
        conversationId: thread.conversationId,
        body: text,
      );

      if (!mounted) return;
      setState(() {
        _messages = (_messages ?? thread.messages)
            .map(
              (message) =>
                  message.id == pendingMessage.id ? savedMessage : message,
            )
            .toList(growable: false);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _messages = (_messages ?? thread.messages)
            .where((message) => message.id != pendingMessage.id)
            .toList(growable: false);
        _messageController.text = text;
        _messageController.selection = TextSelection.collapsed(
          offset: _messageController.text.length,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.chatSendError.tr(context: context),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.coachChat.tr(context: context),
      child: FutureBuilder<CoachChatThread>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              children: const [
                EtzanLoadingCard(height: 72),
                SizedBox(height: AppSpacing.sm),
                EtzanLoadingCard(height: 320),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.chatLoadError.tr(context: context),
                  body: LocaleKeys.chatLoadErrorDescription.tr(
                    context: context,
                  ),
                  action: EtzanPrimaryButton(
                    label: LocaleKeys.retry.tr(context: context),
                    onPressed: _reload,
                  ),
                ),
              ],
            );
          }

          final thread = snapshot.data!;
          final messages = _messages ?? thread.messages;

          return Column(
            children: [
              CoachChatHeader(
                coachName: thread.coach.name,
                specialties: thread.coach.specialties,
                imageUrl: thread.coach.avatarUrl,
                onRefresh: _reload,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: messages.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 90),
                          EtzanEmptyState(
                            title: LocaleKeys.startConversation.tr(
                              context: context,
                            ),
                            body: LocaleKeys.startConversationDescription.tr(
                              context: context,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.md,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              messages[messages.length - index - 1];
                          return ChatMessageBubble(message: message);
                        },
                      ),
              ),
              ChatComposer(
                controller: _messageController,
                sending: _sending,
                onSend: () => _send(thread),
              ),
            ],
          );
        },
      ),
    );
  }
}
