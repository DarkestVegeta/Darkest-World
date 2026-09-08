import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/chat_scope.dart';
import '../widgets/living_world_scene.dart';
import 'chat_world_page.dart';
import 'content_browser_page.dart';

class GuestModePage extends StatelessWidget {
  const GuestModePage({super.key});

  void _openGames(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ContentBrowserPage(
          title: 'Games',
          contentType: 'game',
        ),
      ),
    );
  }

  void _openFilms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ContentBrowserPage(
          title: 'Films',
          contentType: 'movie',
        ),
      ),
    );
  }

  void _openChatbox(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatWorldPage(
          guestMode: true,
          context: ChatContext(scope: ChatScope.chatbox),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LivingWorldScene(child: SizedBox.expand()),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.8, sigmaY: 2.8),
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.28),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  color: Colors.black.withValues(alpha: 0.72),
                  elevation: 18,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'DarkestWorld',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Je kunt de Galaxy zien, maar als Guest kun je er nog niet doorheen bewegen.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        _GuestButton(
                          icon: Icons.sports_esports,
                          label: 'Games',
                          onPressed: () => _openGames(context),
                        ),
                        const SizedBox(height: 12),
                        _GuestButton(
                          icon: Icons.movie,
                          label: 'Films',
                          onPressed: () => _openFilms(context),
                        ),
                        const SizedBox(height: 12),
                        _GuestButton(
                          icon: Icons.chat_bubble_outline,
                          label: 'Chatbox',
                          onPressed: () => _openChatbox(context),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Log in om de Galaxy te betreden.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GuestButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
