import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/models/models.dart';
import '../../shared/services/ai_chat_service.dart';
import '../../shared/state/app_state.dart';
import '../../shared/widgets/widgets.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key, this.service});
  final AiChatService? service;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final messages = <ChatMessage>[];
  bool loading = false;
  AiChatService get service {
    if (widget.service != null) return widget.service!;
    final state = ref.read(appStateProvider);
    return LocalAiChatService(
      profile: state.hasSavedProfile ? state.profile : ElderlyProfile.empty,
      schedule: state.schedule,
      assessment: state.assessment,
      alerts: ref.read(progressAlertsProvider),
      scheduleApproved: state.scheduleApproved,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> send([String? suggestion]) async {
    final text = (suggestion ?? controller.text).trim();
    if (text.isEmpty || loading) return;
    controller.clear();
    setState(() {
      messages.add(ChatMessage(text, fromUser: true));
      loading = true;
    });
    String response;
    try {
      response = await service.send(text);
    } catch (_) {
      response = 'Maaf, jawaban belum dapat diproses. Coba kirim kembali beberapa saat lagi.';
    }
    if (!mounted) return;
    setState(() {
      messages.add(ChatMessage(response, fromUser: false));
      loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final name = state.hasSavedProfile && state.profile.name.trim().isNotEmpty
        ? state.profile.name.trim()
        : 'Bapak/Ibu';
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('NeuroMove AI'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.paleBlue],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'Halo, $name!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Apa yang bisa saya bantu hari ini?',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          const Center(
                            child: SizedBox(
                              width: 150,
                              height: 150,
                              child: RobotAsset(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Mulai bertanya',
                            style: TextStyle(
                              color: AppColors.dark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Suggestion(
                            label: 'Rekomendasi olahraga untukmu',
                            onTap: () => send('Rekomendasi olahraga untukmu'),
                          ),
                          const SizedBox(height: 10),
                          _Suggestion(
                            label: 'Lihat progres latihan saya',
                            onTap: () =>
                                send('Bagaimana progres latihan saya?'),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: messages.length + (loading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final message = messages[index];
                          return Align(
                            alignment: message.fromUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(14),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.sizeOf(context).width * .8,
                              ),
                              decoration: BoxDecoration(
                                color: message.fromUser
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: SelectableText(
                                message.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: message.fromUser
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            textInputAction: TextInputAction.send,
                            maxLength: 500,
                            maxLines: 4,
                            minLines: 1,
                            onSubmitted: (_) => send(),
                            decoration: const InputDecoration(
                              hintText: 'Ketik pertanyaan Anda',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              counterText: '',
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Kirim pertanyaan',
                          onPressed: loading ? null : send,
                          icon: const AssetView(
                            AppAssets.send,
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .8),
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 1,
            color: Color(0xFF053537),
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    ),
  );
}
