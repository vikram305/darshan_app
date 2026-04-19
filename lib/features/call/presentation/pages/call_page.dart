import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../../../core/fetcher/fetcher_state.dart';
import '../../../../core/fetcher/fetcher_event.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/media_kind.dart';
import '../bloc/call_fetcher_bloc.dart';
import '../bloc/call_fetcher_filter.dart';
import '../cubit/call_ui_cubit.dart';
import '../cubit/call_ui_state.dart';
import '../utils/call_strings.dart';
import '../widgets/video_renderer_widget.dart';


class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CallFetcherBloc, FetcherState<RoomEntity>>(
        listener: (context, state) {
          if (state is FetcherSuccess<RoomEntity>) {
            context.read<CallUiCubit>().initializeData(state.data);
            context.read<CallUiCubit>().initLocalMedia();
          }
        },
        builder: (context, state) {
          if (state is FetcherInitial) {
            return const _HomeView();
          } else if (state is FetcherLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (state is FetcherSuccess<RoomEntity>) {
            return const _CallView();
          } else if (state is FetcherFailure<RoomEntity>) {
            return _ErrorView(message: state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            CallStrings.featureName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: CallStrings.yourDisplayName,
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                context.read<CallFetcherBloc>().add(FetchData(
                      filter: CreateRoomFilter(displayName: _nameController.text),
                    ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(CallStrings.createRoom, style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 32),
          TextField(
            controller: _roomController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: CallStrings.enterRoomId,
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _roomController.text.isNotEmpty) {
                context.read<CallFetcherBloc>().add(FetchData(
                      filter: JoinRoomFilter(
                        roomId: _roomController.text,
                        displayName: _nameController.text,
                      ),
                    ));
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(CallStrings.joinRoom, style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class _CallView extends StatelessWidget {
  const _CallView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallUiCubit, CallUiState>(
      builder: (context, state) {
        final peers = state.viewData?.peers ?? [];
        return Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: peers.length + 1,
              itemBuilder: (context, index) {
                final isLocal = index == 0;
                final peer = isLocal ? null : peers[index - 1];
                final stream = isLocal 
                    ? state.localMedia?.localStream 
                    : peer?.consumers.firstWhereOrNull((c) => c.kind == MediaKind.video)?.stream;
                
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundButton(
                    icon: state.localMedia?.isMicEnabled ?? true ? Icons.mic : Icons.mic_off,
                    onPressed: () => context.read<CallUiCubit>().toggleMic(),
                  ),
                  const SizedBox(width: 24),
                  _RoundButton(
                    icon: state.localMedia?.isCameraEnabled ?? true ? Icons.videocam : Icons.videocam_off,
                    onPressed: () => context.read<CallUiCubit>().toggleCamera(),
                  ),
                  const SizedBox(width: 24),
                  _RoundButton(
                    icon: Icons.cameraswitch,
                    onPressed: () => context.read<CallUiCubit>().switchCamera(),
                  ),
                  const SizedBox(width: 24),
                  _RoundButton(
                    icon: Icons.call_end,
                    backgroundColor: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigation or reset
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
