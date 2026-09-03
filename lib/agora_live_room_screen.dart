import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'agora_config.dart';

class AgoraLiveRoomScreen extends StatefulWidget {
  final String roomName;
  final bool isHost;

  const AgoraLiveRoomScreen({
    super.key,
    this.roomName = 'Mchat Live',
    required this.isHost,
  });

  @override
  State<AgoraLiveRoomScreen> createState() =>
      _AgoraLiveRoomScreenState();
}

class _AgoraLiveRoomScreenState
    extends State<AgoraLiveRoomScreen> {
  RtcEngine? _engine;

  int? _remoteUid;

  bool _joined = false;
  bool _cameraEnabled = true;
  bool _micEnabled = true;
  bool _initializing = true;
  bool _leaving = false;

  String _status = 'Connecting...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    try {
      if (AgoraConfig.appId.isEmpty) {
        throw Exception('Agora App ID is missing.');
      }

      if (AgoraConfig.tempToken.isEmpty) {
        throw Exception(
          'Agora Temporary Token is missing from build.',
        );
      }

      // Host needs camera + microphone permission.
      if (widget.isHost) {
        final permissions = await [
          Permission.camera,
          Permission.microphone,
        ].request();

        final cameraGranted =
            permissions[Permission.camera]?.isGranted ?? false;

        final microphoneGranted =
            permissions[Permission.microphone]?.isGranted ?? false;

        if (!cameraGranted || !microphoneGranted) {
          throw Exception(
            'Camera and Microphone permissions are required '
            'for Live Streaming.',
          );
        }
      }

      final engine = createAgoraRtcEngine();

      await engine.initialize(
        RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile:
              ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      _engine = engine;

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess:
              (RtcConnection connection, int elapsed) {
            if (!mounted) return;

            setState(() {
              _joined = true;
              _initializing = false;
              _status = widget.isHost
                  ? 'You are LIVE'
                  : 'Connected to Live';
            });
          },

          onUserJoined:
              (RtcConnection connection, int remoteUid, int elapsed) {
            if (!mounted) return;

            setState(() {
              _remoteUid = remoteUid;
              _status = 'Host is LIVE';
            });
          },

          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
            if (!mounted) return;

            if (_remoteUid == remoteUid) {
              setState(() {
                _remoteUid = null;
                _status = 'Host has left the Live';
              });
            }
          },

          onError:
              (ErrorCodeType err, String msg) {
            debugPrint(
              'Agora error: $err - $msg',
            );

            if (!mounted) return;

            setState(() {
              _errorMessage =
                  'Agora error: $err\n$msg';
              _initializing = false;
              _status = 'Connection error';
            });
          },

          onConnectionStateChanged:
              (
                RtcConnection connection,
                ConnectionStateType state,
                ConnectionChangedReasonType reason,
              ) {
            debugPrint(
              'Agora connection: $state / $reason',
            );
          },

          onTokenPrivilegeWillExpire:
              (RtcConnection connection, String token) {
            debugPrint(
              'Agora temporary token is about to expire.',
            );
          },
        ),
      );

      if (widget.isHost) {
        await engine.setClientRole(
          role: ClientRoleType.clientRoleBroadcaster,
        );

        await engine.enableVideo();

        await engine.enableAudio();

        await engine.startPreview();
      } else {
        await engine.setClientRole(
          role: ClientRoleType.clientRoleAudience,
        );
      }

      final options = ChannelMediaOptions(
        channelProfile:
            ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: widget.isHost
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,

        publishCameraTrack:
            widget.isHost && _cameraEnabled,

        publishMicrophoneTrack:
            widget.isHost && _micEnabled,

        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
      );

      await engine.joinChannel(
        token: AgoraConfig.tempToken,
        channelId: AgoraConfig.testChannel,
        uid: 0,
        options: options,
      );
    } catch (e) {
      debugPrint(
        'Agora initialization failed: $e',
      );

      if (!mounted) return;

      setState(() {
        _initializing = false;
        _status = 'Unable to connect';
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleCamera() async {
    final engine = _engine;

    if (engine == null || !widget.isHost) {
      return;
    }

    try {
      final newValue = !_cameraEnabled;

      await engine.enableLocalVideo(newValue);

      await engine.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishCameraTrack: newValue,
          publishMicrophoneTrack: _micEnabled,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          clientRoleType:
              ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (!mounted) return;

      setState(() {
        _cameraEnabled = newValue;
      });
    } catch (e) {
      _showMessage(
        'Camera change failed.',
      );
    }
  }

  Future<void> _toggleMicrophone() async {
    final engine = _engine;

    if (engine == null || !widget.isHost) {
      return;
    }

    try {
      final newValue = !_micEnabled;

      await engine.enableLocalAudio(newValue);

      await engine.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishCameraTrack: _cameraEnabled,
          publishMicrophoneTrack: newValue,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          clientRoleType:
              ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (!mounted) return;

      setState(() {
        _micEnabled = newValue;
      });
    } catch (e) {
      _showMessage(
        'Microphone change failed.',
      );
    }
  }

  Future<void> _switchCamera() async {
    final engine = _engine;

    if (engine == null || !widget.isHost) {
      return;
    }

    try {
      await engine.switchCamera();
    } catch (e) {
      _showMessage(
        'Could not switch camera.',
      );
    }
  }

  Future<void> _leaveRoom() async {
    if (_leaving) return;

    _leaving = true;

    try {
      final engine = _engine;

      if (engine != null) {
        await engine.leaveChannel();
        await engine.release();
      }
    } catch (e) {
      debugPrint(
        'Agora leave error: $e',
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildLocalVideo() {
    final engine = _engine;

    if (engine == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!widget.isHost) {
      return const SizedBox.shrink();
    }

    if (!_joined) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_cameraEnabled) {
      return const Center(
        child: Icon(
          Icons.videocam_off,
          color: Colors.white70,
          size: 80,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine,
          canvas: const VideoCanvas(
            uid: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    final engine = _engine;

    if (engine == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_remoteUid == null) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              color: Colors.white54,
              size: 70,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isHost
                  ? 'Waiting for viewers...'
                  : 'Waiting for host...',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 17,
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(
            uid: _remoteUid!,
          ),
          connection: const RtcConnection(
            channelId: AgoraConfig.testChannel,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.isHost
                  ? _buildLocalVideo()
                  : _buildRemoteVideo(),
            ),

            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 9,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _joined
                          ? 'LIVE'
                          : 'CONNECTING',
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Text(
                  widget.isHost
                      ? 'You • Host'
                      : 'Mchat Live',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),

            if (!widget.isHost &&
                _remoteUid != null)
              Positioned(
                right: 14,
                bottom: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'HOST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostControls() {
    if (!widget.isHost) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          4,
          20,
          18,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
          children: [
            _controlButton(
              icon: _micEnabled
                  ? Icons.mic
                  : Icons.mic_off,
              label: _micEnabled
                  ? 'Mic'
                  : 'Muted',
              onPressed:
                  _toggleMicrophone,
              active: _micEnabled,
            ),

            _controlButton(
              icon: _cameraEnabled
                  ? Icons.videocam
                  : Icons.videocam_off,
              label: _cameraEnabled
                  ? 'Camera'
                  : 'Off',
              onPressed:
                  _toggleCamera,
              active: _cameraEnabled,
            ),

            _controlButton(
              icon:
                  Icons.flip_camera_ios,
              label: 'Flip',
              onPressed:
                  _switchCamera,
              active: true,
            ),

            _controlButton(
              icon: Icons.call_end,
              label: 'End',
              onPressed: _leaveRoom,
              active: false,
              danger: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool active,
    bool danger = false,
  }) {
    return Column(
      children: [
        Material(
          color: danger
              ? Colors.red
              : active
                  ? Colors.white12
                  : Colors.red.withOpacity(.25),
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: Colors.white,
              size: 27,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.12),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withOpacity(.35),
        ),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.roomName,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(
              widget.isHost
                  ? 'Host • Live Streaming'
                  : 'Viewer • Live Streaming',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        actions: [
          if (!widget.isHost)
            IconButton(
              onPressed: _leaveRoom,
              icon:
                  const Icon(Icons.close),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildVideoArea(),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 4,
            ),
            child: Row(
              children: [
                Icon(
                  widget.isHost
                      ? Icons.videocam
                      : Icons.visibility,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _status,
                    style:
                        const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _buildError(),

          _buildHostControls(),

          if (!widget.isHost)
            SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  18,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _leaveRoom,
                    icon: const Icon(
                      Icons.exit_to_app,
                    ),
                    label: const Text(
                      'Leave Live',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposeAgora();
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    try {
      final engine = _engine;

      if (engine != null) {
        await engine.leaveChannel();
        await engine.release();
      }
    } catch (e) {
      debugPrint(
        'Agora dispose error: $e',
      );
    }
  }
}
