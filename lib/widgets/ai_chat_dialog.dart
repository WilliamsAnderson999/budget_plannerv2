import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budget_manager/services/ai_service.dart';
import 'package:budget_manager/services/transaction_service.dart';
import 'package:budget_manager/services/firestore_service.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/models/goal.dart';
import 'package:budget_manager/theme/app_theme.dart';
import 'package:budget_manager/theme/auth_palette.dart';

class AIChatDialog extends StatefulWidget {
  const AIChatDialog({super.key});

  @override
  State<AIChatDialog> createState() => _AIChatDialogState();
}

class _AIChatDialogState extends State<AIChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_ChatMsg> _messages = [];
  final AIService _aiService = AIService();

  bool _isLoading = false;
  List<Goal> _goals = [];

  Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoals());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    final user = authService.currentUser;
    if (user == null) return;

    try {
      final goals = await firestoreService.getGoals(user.uid);
      if (!mounted) return;
      setState(() => _goals = goals);
    } catch (_) {
      // silent: goals optional
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      _ChatMsg.ai(
        "Bonjour ! Je suis ton assistant financier IA.\n"
        "Dis-moi ce que tu veux analyser : dépenses, objectifs, budget…",
      ),
    );
  }

  void _scrollToBottom() {
    // list is NOT reversed, so bottom is maxScrollExtent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg.user(text));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    final transactionService = Provider.of<TransactionService>(context, listen: false);
    final transactions = transactionService.transactions;

    try {
      final response = await _aiService.chatWithAI(text, transactions, _goals);
      if (!mounted) return;
      setState(() => _messages.add(_ChatMsg.ai(response)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add(_ChatMsg.ai("Désolé, une erreur s'est produite.")));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _quickAsk(String text) => _sendMessage(text);

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _a(AuthPalette.lavender, 0.35),
                    _a(AuthPalette.peach, 0.28),
                    _a(AuthPalette.lemon, 0.22),
                    _a(Colors.white, 0.72),
                  ],
                ),
                border: Border.all(color: _a(Colors.white, 0.55)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.80,
                  child: Column(
                    children: [
                      _Header(
                        onClose: () => Navigator.of(context).pop(),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: _QuickActionsRow(
                          onTap: _quickAsk,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Divider(color: Colors.black.withOpacity(0.06), height: 1),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                          child: _ChatList(
                            controller: _scroll,
                            messages: _messages,
                          ),
                        ),
                      ),

                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _TypingIndicator(),
                        ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                        child: _Composer(
                          controller: _messageController,
                          onSend: () => _sendMessage(_messageController.text),
                          onSubmit: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------- UI Parts -------------------- */

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
      child: Row(
        children: [
          const _AiBlobIcon(size: 26),
          const SizedBox(width: 10),
          Text(
            "Assistant IA Financier",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AuthPalette.ink,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: AuthPalette.ink,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final void Function(String) onTap;
  const _QuickActionsRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = <_QuickAction>[
      _QuickAction(
        label: "Prédiction dépenses",
        icon: Icons.auto_graph_rounded,
        prompt:
            "Fais-moi une prédiction sur mes dépenses du mois prochain basée sur mes dépenses actuelles.",
      ),
      _QuickAction(
        label: "Atteindre objectifs",
        icon: Icons.flag_rounded,
        prompt: "Aide-moi à atteindre mes objectifs financiers.",
      ),
      _QuickAction(
        label: "Conseils investissement",
        icon: Icons.trending_up_rounded,
        prompt: "Donne-moi des conseils pour investir.",
      ),
      _QuickAction(
        label: "Analyser dépenses",
        icon: Icons.pie_chart_rounded,
        prompt: "Analyse mes habitudes de dépenses et dis-moi quoi améliorer.",
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((it) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ActionChip(
              onPressed: () => onTap(it.prompt),
              avatar: Icon(it.icon, size: 18, color: AuthPalette.ink),
              label: Text(
                it.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AuthPalette.ink,
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.70),
              side: BorderSide(color: Colors.white.withOpacity(0.60)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final ScrollController controller;
  final List<_ChatMsg> messages;

  const _ChatList({
    required this.controller,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final m = messages[i];
        final isUser = m.sender == _Sender.user;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AuthPalette.tangerine.withOpacity(0.95),
                            AuthPalette.peach.withOpacity(0.92),
                          ],
                        )
                      : null,
                  color: isUser ? null : Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 6),
                    bottomRight: Radius.circular(isUser ? 6 : 16),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.60)),
                ),
                child: Text(
                  m.text,
                  style: TextStyle(
                    color: isUser ? Colors.white : AuthPalette.ink,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final void Function(String) onSubmit;

  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                border: Border.all(color: Colors.white.withOpacity(0.60)),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: onSubmit,
                textInputAction: TextInputAction.send,
                style: const TextStyle(
                  color: AuthPalette.ink,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: "Tapez votre message…",
                  hintStyle: TextStyle(
                    color: AuthPalette.inkSoft.withOpacity(0.75),
                    fontWeight: FontWeight.w700,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onSend,
          child: const _SendBlobButton(),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.60)),
          ),
          child: Text(
            "L’IA écrit…",
            style: TextStyle(
              color: AuthPalette.inkSoft,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/* -------------------- Blob Widgets -------------------- */

class _AiBlobIcon extends StatelessWidget {
  final double size;
  const _AiBlobIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AuthPalette.lavender.withOpacity(0.85),
                  AuthPalette.peach.withOpacity(0.85),
                  AuthPalette.lemon.withOpacity(0.75),
                  AuthPalette.mint.withOpacity(0.70),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.65)),
            ),
          ),
          // cute tiny face
          Positioned(
            top: size * 0.38,
            left: size * 0.30,
            child: _dot(size * 0.12),
          ),
          Positioned(
            top: size * 0.38,
            right: size * 0.30,
            child: _dot(size * 0.12),
          ),
        ],
      ),
    );
  }

  Widget _dot(double d) {
    return Container(
      width: d,
      height: d,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SendBlobButton extends StatelessWidget {
  const _SendBlobButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AuthPalette.ink,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.send_rounded, color: Colors.white),
      ),
    );
  }
}

/* -------------------- Models -------------------- */

enum _Sender { user, ai }

class _ChatMsg {
  final _Sender sender;
  final String text;

  _ChatMsg(this.sender, this.text);

  factory _ChatMsg.user(String t) => _ChatMsg(_Sender.user, t);
  factory _ChatMsg.ai(String t) => _ChatMsg(_Sender.ai, t);
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String prompt;

  _QuickAction({
    required this.label,
    required this.icon,
    required this.prompt,
  });
}
