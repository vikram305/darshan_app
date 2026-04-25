import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/fetcher/fetcher_state.dart';
import '../../../../core/fetcher/fetcher_event.dart';
import '../../../../core/constants/app_routes.dart';
import '../../domain/entities/room_entity.dart';
import '../bloc/call_fetcher_bloc.dart';
import '../bloc/call_fetcher_filter.dart';
import '../cubit/call_ui_cubit.dart';
import '../utils/call_strings.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallFetcherBloc, FetcherState<RoomEntity>>(
      listener: (context, state) {
        if (state is FetcherSuccess<RoomEntity>) {
          context.read<CallUiCubit>().initializeData(state.data);
          context.read<CallUiCubit>().initLocalMedia();
          context.go(AppRoutes.room);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    CallStrings.featureName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildTextField(
                    controller: _nameController,
                    label: CallStrings.yourDisplayName,
                  ),
                  const SizedBox(height: 24),
                  _buildPrimaryButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        context.read<CallFetcherBloc>().add(FetchData(
                              filter: CreateRoomFilter(displayName: _nameController.text),
                            ));
                      }
                    },
                    label: CallStrings.createRoom,
                  ),
                  const SizedBox(height: 32),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("OR", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _roomController,
                    label: CallStrings.enterRoomId,
                  ),
                  const SizedBox(height: 16),
                  _buildSecondaryButton(
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
                    label: CallStrings.joinRoom,
                  ),
                  
                  // Show loading indicator if Bloc is in loading state
                  BlocBuilder<CallFetcherBloc, FetcherState<RoomEntity>>(
                    builder: (context, state) {
                      if (state is FetcherLoading<RoomEntity>) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: CircularProgressIndicator(color: Colors.blueAccent),
                        );
                      }
                      if (state is FetcherFailure<RoomEntity>) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.indigoAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 64),
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }
}
