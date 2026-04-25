import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/media_kind.dart';
import '../cubit/call_ui_cubit.dart';
import '../cubit/call_ui_state.dart';
import '../widgets/video_renderer_widget.dart';

class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldLeave = await _showEndCallDialog(context);
        if (shouldLeave == true) {
          if (context.mounted) {
            await context.read<CallUiCubit>().leaveRoom();
            if (context.mounted) {
              context.go('/');
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<CallUiCubit, CallUiState>(
          builder: (context, state) {
            final peers = state.viewData?.peers ?? [];
            final myId = state.viewData?.myPeerId;
            final remotePeers = peers.where((p) => p.id != myId).toList();

            return Stack(
              children: [
                if (remotePeers.isEmpty)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white24),
                        SizedBox(height: 24),
                        Text(
                          'Waiting for others to join...',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: remotePeers.length + 1,
                  itemBuilder: (context, index) {
                    final isLocal = index == 0;
                    final peer = isLocal ? null : remotePeers[index - 1];
                    final stream = isLocal 
                        ? state.localMedia?.localStream 
                        : peer?.consumers.firstWhereOrNull((c) => c.kind == MediaKind.video)?.stream;
                    
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        color: Colors.grey[900],
                        child: VideoRendererWidget(
                          stream: stream,
                          isLocal: isLocal,
                        ),
                      ),
                    );
                  },
                ),
                
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _RoundButton(
                          icon: state.localMedia?.isMicEnabled ?? true ? Icons.mic : Icons.mic_off,
                          onPressed: () => context.read<CallUiCubit>().toggleMic(),
                        ),
                        _RoundButton(
                          icon: state.localMedia?.isCameraEnabled ?? true ? Icons.videocam : Icons.videocam_off,
                          onPressed: () => context.read<CallUiCubit>().toggleCamera(),
                        ),
                        _RoundButton(
                          icon: Icons.cameraswitch,
                          onPressed: () => context.read<CallUiCubit>().switchCamera(),
                        ),
                        _RoundButton(
                          icon: Icons.call_end,
                          backgroundColor: Colors.redAccent,
                          onPressed: () async {
                             final shouldLeave = await _showEndCallDialog(context);
                             if (shouldLeave == true) {
                               if (context.mounted) {
                                 await context.read<CallUiCubit>().leaveRoom();
                                 if (context.mounted) {
                                   context.go('/');
                                 }
                               }
                             }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _showEndCallDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'End Call?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to disconnect from this session?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('END CALL', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const _RoundButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.white12,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: backgroundColor,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}
