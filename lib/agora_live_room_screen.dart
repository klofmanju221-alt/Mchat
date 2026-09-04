import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'agora_config.dart';

class AgoraLiveRoomScreen extends StatefulWidget {
  final String roomName;
  final bool isHost;
  final String roomId;
  final String hostUid;
  final String hostName;

  const AgoraLiveRoomScreen({
    super.key,
    this.roomName = 'Mchat Live',
    required this.isHost,
    this.roomId = '',
    this.hostUid = '',
    this.hostName = 'Mchat User',
  });

  @override
  State<AgoraLiveRoomScreen> createState() =>
      _AgoraLiveRoomScreenState();
}

class _AgoraLiveRoomScreenState
    extends State<AgoraLiveRoomScreen>
    with TickerProviderStateMixin {
  RtcEngine? _engine;

  int? _remoteUid;

  bool _joined = false;
  bool _cameraEnabled = true;
  bool _micEnabled = true;
  bool _loading = true;
  bool _leaving = false;

  String? _error;

  int _localLikes = 0;
  int _likeAnimationId = 0;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _chatScrollController =
      ScrollController();

  final List<Map<String, dynamic>> _gifts = [
    {
      'name': 'Rose',
      'emoji': '🌹',
      'coins': 10,
    },
    {
      'name': 'Heart',
      'emoji': '❤️',
      'coins': 49,
    },
    {
      'name': 'Lollipop',
      'emoji': '🍭',
      'coins': 99,
    },
    {
      'name': 'Coffee',
      'emoji': '☕',
      'coins': 199,
    },
    {
      'name': 'Teddy',
      'emoji': '🧸',
      'coins': 299,
    },
    {
      'name': 'Diamond',
      'emoji': '💎',
      'coins': 499,
    },
    {
      'name': 'Car',
      'emoji': '🚗',
      'coins': 999,
    },
    {
      'name': 'Castle',
      'emoji': '🏰',
      'coins': 1999,
    },
    {
      'name': 'Lion',
      'emoji': '🦁',
      'coins': 2999,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  // ============================================================
  // FIRESTORE REFERENCES
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _roomMessages {
    return _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .collection('messages');
  }

  // ============================================================
  // AGORA INITIALIZATION
  // ============================================================

  Future<void> _initializeAgora() async {
    try {
      if (AgoraConfig.appId.isEmpty) {
        throw Exception(
          'Agora App ID is missing.',
        );
      }

      if (AgoraConfig.tempToken.isEmpty) {
        throw Exception(
          'Agora Temporary Token is missing from build.',
        );
      }

      if (widget.isHost) {
        final permissions = await [
          Permission.camera,
          Permission.microphone,
        ].request();

        final cameraGranted =
            permissions[Permission.camera]?.isGranted ??
                false;

        final microphoneGranted =
            permissions[Permission.microphone]?.isGranted ??
                false;

        if (!cameraGranted ||
            !microphoneGranted) {
          throw Exception(
            'Camera and Microphone permission required.',
          );
        }
      }

      final engine = createAgoraRtcEngine();

      await engine.initialize(
        RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile:
              ChannelProfileType
                  .channelProfileLiveBroadcasting,
        ),
      );

      _engine = engine;

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess:
              (
                RtcConnection connection,
                int elapsed,
              ) {
            if (!mounted) return;

            setState(() {
              _joined = true;
              _loading = false;
            });

            if (!widget.isHost) {
              _updateViewerCount(1);
            }
          },

          onUserJoined:
              (
                RtcConnection connection,
                int remoteUid,
                int elapsed,
              ) {
            if (!mounted) return;

            setState(() {
              _remoteUid = remoteUid;
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
              });
            }
          },

          onError:
              (
                ErrorCodeType error,
                String message,
              ) {
            if (!mounted) return;

            setState(() {
              _loading = false;
              _error =
                  'Agora error:\n$error\n$message';
            });
          },

          onTokenPrivilegeWillExpire:
              (
                RtcConnection connection,
                String token,
              ) {
            debugPrint(
              'Agora temporary token is expiring.',
            );
          },
        ),
      );

      if (widget.isHost) {
        await engine.setClientRole(
          role:
              ClientRoleType
                  .clientRoleBroadcaster,
        );

        await engine.enableVideo();
        await engine.enableAudio();
        await engine.startPreview();
      } else {
        await engine.setClientRole(
          role:
              ClientRoleType
                  .clientRoleAudience,
        );

        await engine.enableVideo();
      }

      final options = ChannelMediaOptions(
        channelProfile:
            ChannelProfileType
                .channelProfileLiveBroadcasting,

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
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // VIDEO
  // ============================================================

  Widget _buildVideo() {
    final engine = _engine;

    if (engine == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (widget.isHost) {
      if (!_cameraEnabled) {
        return const Center(
          child: Icon(
            Icons.videocam_off,
            color: Colors.white70,
            size: 80,
          ),
        );
      }

      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine,
          canvas: const VideoCanvas(
            uid: 0,
          ),
        ),
      );
    }

    if (_remoteUid == null) {
      return const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.live_tv,
              color: Colors.white54,
              size: 75,
            ),
            SizedBox(height: 15),
            Text(
              'Waiting for host...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: engine,
        canvas: VideoCanvas(
          uid: _remoteUid!,
        ),
        connection: const RtcConnection(
          channelId: AgoraConfig.testChannel,
        ),
      ),
    );
  }

  // ============================================================
  // CAMERA
  // ============================================================

  Future<void> _toggleCamera() async {
    if (!widget.isHost ||
        _engine == null) {
      return;
    }

    try {
      final newValue = !_cameraEnabled;

      await _engine!.enableLocalVideo(
        newValue,
      );

      await _engine!
          .updateChannelMediaOptions(
        ChannelMediaOptions(
          channelProfile:
              ChannelProfileType
                  .channelProfileLiveBroadcasting,

          clientRoleType:
              ClientRoleType.clientRoleBroadcaster,

          publishCameraTrack:
              newValue,

          publishMicrophoneTrack:
              _micEnabled,

          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );

      if (!mounted) return;

      setState(() {
        _cameraEnabled = newValue;
      });
    } catch (_) {
      _showMessage(
        'Camera could not be changed.',
      );
    }
  }

  // ============================================================
  // MICROPHONE
  // ============================================================

  Future<void> _toggleMic() async {
    if (!widget.isHost ||
        _engine == null) {
      return;
    }

    try {
      final newValue = !_micEnabled;

      await _engine!.enableLocalAudio(
        newValue,
      );

      await _engine!
          .updateChannelMediaOptions(
        ChannelMediaOptions(
          channelProfile:
              ChannelProfileType
                  .channelProfileLiveBroadcasting,

          clientRoleType:
              ClientRoleType.clientRoleBroadcaster,

          publishCameraTrack:
              _cameraEnabled,

          publishMicrophoneTrack:
              newValue,

          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );

      if (!mounted) return;

      setState(() {
        _micEnabled = newValue;
      });
    } catch (_) {
      _showMessage(
        'Microphone could not be changed.',
      );
    }
  }

  // ============================================================
  // FLIP CAMERA
  // ============================================================

  Future<void> _flipCamera() async {
    try {
      await _engine?.switchCamera();
    } catch (_) {
      _showMessage(
        'Could not switch camera.',
      );
    }
  }

  // ============================================================
  // VIEWER COUNT
  // ============================================================

  Future<void> _updateViewerCount(
    int change,
  ) async {
    if (widget.roomId.isEmpty) {
      return;
    }

    try {
      await _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .update({
        'viewerCount':
            FieldValue.increment(change),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Stream<int> _viewerCountStream() {
    if (widget.roomId.isEmpty) {
      return Stream.value(
        _remoteUid == null ? 0 : 1,
      );
    }

    return _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();

      final count =
          (data?['viewerCount'] as num?)
                  ?.toInt() ??
              0;

      return count < 0 ? 0 : count;
    });
  }

  // ============================================================
  // ❤️ LIKE SYSTEM
  // ============================================================

  Future<void> _sendLike() async {
    final user = _auth.currentUser;

    if (user == null ||
        widget.roomId.isEmpty) {
      return;
    }

    final currentAnimation =
        ++_likeAnimationId;

    if (mounted) {
      setState(() {
        _localLikes++;
      });
    }

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final data =
          userDoc.data() ?? {};

      final name =
          (data['name'] ??
                  user.displayName ??
                  'Mchat User')
              .toString();

      await _roomMessages.add({
        'senderId': user.uid,
        'senderName': name,
        'text': '❤️',
        'type': 'like',
        'createdAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_localLikes > 0) {
            _localLikes--;
          }
        });
      }

      _showMessage(
        'Like could not be sent.',
      );
      return;
    }

    Future.delayed(
      const Duration(
        milliseconds: 900,
      ),
      () {
        if (!mounted) return;

        if (currentAnimation ==
            _likeAnimationId) {
          setState(() {});
        }
      },
    );
  }

  Stream<int> _likeCountStream() {
    if (widget.roomId.isEmpty) {
      return Stream.value(0);
    }

    return _roomMessages
        .where(
          'type',
          isEqualTo: 'like',
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.size,
        );
  }

  // ============================================================
  // LIVE CHAT SEND
  // ============================================================

  Future<void> _sendMessage() async {
    final text =
        _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    if (text.length > 500) {
      _showMessage(
        'Message cannot exceed 500 characters.',
      );
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    if (widget.roomId.isEmpty) {
      _showMessage(
        'Chat is unavailable.',
      );
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final data =
          userDoc.data() ?? {};

      final name =
          (data['name'] ??
                  user.displayName ??
                  'Mchat User')
              .toString();

      await _roomMessages.add({
        'senderId': user.uid,
        'senderName': name,
        'text': text,
        'type': 'text',
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (_) {
      _showMessage(
        'Message could not be sent.',
      );
    }
  }

  // ============================================================
  // LIVE CHAT
  // ============================================================

  Widget _buildChat() {
    if (widget.roomId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 12,
      right: 80,
      bottom: widget.isHost
          ? 150
          : 88,
      child: SizedBox(
        height: 185,
        child: StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream: _roomMessages
              .orderBy(
                'createdAt',
                descending: true,
              )
              .limit(40)
              .snapshots(),

          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.hasError) {
              return const SizedBox.shrink();
            }

            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final messages =
                snapshot.data!.docs
                    .where((doc) {
              final data = doc.data();

              return data['type'] !=
                  'like';
            }).toList();

            if (messages.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.builder(
              controller:
                  _chatScrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (
                context,
                index,
              ) {
                final data =
                    messages[index].data();

                final name =
                    (data['senderName'] ??
                            'User')
                        .toString();

                final text =
                    (data['text'] ?? '')
                        .toString();

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 7,
                  ),
                  child: Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.black54,
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '$name  ',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.amber,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: text,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CHAT INPUT
  // ============================================================

  Widget _buildChatInput() {
    return Positioned(
      left: 12,
      right: widget.isHost ? 12 : 78,
      bottom: 18,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withValues(
                    alpha: .55,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    25,
                  ),
                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),
                child: TextField(
                  controller:
                      _messageController,
                  maxLength: 500,
                  minLines: 1,
                  maxLines: 3,
                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),
                  decoration:
                      const InputDecoration(
                    hintText:
                        'Say something...',
                    hintStyle:
                        TextStyle(
                      color:
                          Colors.white70,
                    ),
                    border:
                        InputBorder.none,
                    counterText: '',
                    contentPadding:
                        EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted:
                      (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              decoration:
                  const BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.deepPurple,
              ),
              child: IconButton(
                onPressed:
                    _sendMessage,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ❤️ FLOATING HEARTS
  // ============================================================

  Widget _buildFloatingHearts() {
    if (_localLikes == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 22,
      bottom: 150,
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration:
              const Duration(
            milliseconds: 250,
          ),
          child: Column(
            key: ValueKey(
              _localLikes,
            ),
            children: [
              const Text(
                '❤️',
                style: TextStyle(
                  fontSize: 38,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _localLikes > 999
                    ? '${(_localLikes / 1000).toStringAsFixed(1)}K'
                    : '$_localLikes',
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 13,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GIFT SHEET
  // ============================================================

  Future<void> _showGiftSheet() async {
    if (widget.isHost) {
      _showMessage(
        'You cannot send a gift to yourself.',
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor:
          const Color(0xFF17121E),
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color: Colors.white30,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                const Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color:
                          Colors.pinkAccent,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Send Gift',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 23,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      _gifts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: .9,
                  ),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final gift =
                        _gifts[index];

                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                        );

                        _showMessage(
                          '${gift['name']} gift requires verified coin payment.',
                        );
                      },
                      child: Container(
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white10,
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              gift['emoji']
                                  .toString(),
                              style:
                                  const TextStyle(
                                fontSize: 34,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              gift['name']
                                  .toString(),
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              '${gift['coins']} coins',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.amber,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'Gifts are credited only after secure payment verification.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            0,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    Colors.white24,
                child: Text(
                  widget.hostName.isNotEmpty
                      ? widget.hostName[0]
                          .toUpperCase()
                      : 'M',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hostName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.roomName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 7,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style:
                          TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 7),

              StreamBuilder<int>(
                stream:
                    _viewerCountStream(),
                builder: (
                  context,
                  snapshot,
                ) {
                  final count =
                      snapshot.data ?? 0;

                  return Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.black54,
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .visibility,
                          color:
                              Colors.white,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '$count',
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(width: 5),

              IconButton(
                onPressed:
                    _leaveRoom,
                icon:
                    const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM CONTROLS
  // ============================================================

  Widget _buildControls() {
    return Positioned(
      right: 10,
      bottom: 78,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            StreamBuilder<int>(
              stream: _likeCountStream(),
              builder: (
                context,
                snapshot,
              ) {
                final likes =
                    snapshot.data ?? 0;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: _sendLike,
                      child: Container(
                        width: 53,
                        height: 53,
                        decoration:
                            BoxDecoration(
                          color: Colors.black
                              .withValues(
                            alpha: .55,
                          ),
                          shape:
                              BoxShape.circle,
                          border:
                              Border.all(
                            color:
                                Colors.white24,
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color:
                              Colors.pinkAccent,
                          size: 29,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      likes > 999
                          ? '${(likes / 1000).toStringAsFixed(1)}K'
                          : '$likes',
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 13),

            GestureDetector(
              onTap: _showGiftSheet,
              child: Container(
                width: 53,
                height: 53,
                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withValues(
                    alpha: .55,
                  ),
                  shape:
                      BoxShape.circle,
                  border:
                      Border.all(
                    color:
                        Colors.white24,
                  ),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.amber,
                  size: 27,
                ),
              ),
            ),

            if (widget.isHost) ...[
              const SizedBox(
                height: 13,
              ),

              GestureDetector(
                onTap: _toggleMic,
                child: _controlButton(
                  _micEnabled
                      ? Icons.mic
                      : Icons.mic_off,
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              GestureDetector(
                onTap:
                    _toggleCamera,
                child: _controlButton(
                  _cameraEnabled
                      ? Icons.videocam
                      : Icons.videocam_off,
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              GestureDetector(
                onTap: _flipCamera,
                child: _controlButton(
                  Icons.flip_camera_ios,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _controlButton(
    IconData icon,
  ) {
    return Container(
      width: 53,
      height: 53,
      decoration:
          BoxDecoration(
        color: Colors.black
            .withValues(
          alpha: .55,
        ),
        shape: BoxShape.circle,
        border:
            Border.all(
          color: Colors.white24,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 25,
      ),
    );
  }

  // ============================================================
  // ERROR SCREEN
  // ============================================================

  Widget _buildError() {
    if (_error == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        margin:
            const EdgeInsets.all(25),
        padding:
            const EdgeInsets.all(20),
        decoration:
            BoxDecoration(
          color: Colors.black87,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 55,
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'Live connection error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              _error!,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            ElevatedButton(
              onPressed:
                  _leaveRoom,
              child:
                  const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // LEAVE ROOM
  // ============================================================

  Future<void> _leaveRoom() async {
    if (_leaving) {
      return;
    }

    _leaving = true;

    try {
      if (!widget.isHost &&
          _joined) {
        await _updateViewerCount(-1);
      }

      if (widget.isHost &&
          widget.roomId.isNotEmpty) {
        try {
          await _firestore
              .collection('rooms')
              .doc(widget.roomId)
              .update({
            'status': 'ended',
            'updatedAt':
                FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      }

      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // CAMERA / VIDEO
          _buildVideo(),

          // DARK GRADIENT
          IgnorePointer(
            child: Container(
              decoration:
                  const BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.black87,
                  ],
                  stops: [
                    0.0,
                    0.45,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          // TOP
          _buildTopBar(),

          // CHAT
          _buildChat(),

          // FLOATING HEARTS
          _buildFloatingHearts(),

          // CONTROLS
          _buildControls(),

          // INPUT
          _buildChatInput(),

          // LOADING
          if (_loading)
            const Center(
              child:
                  CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

          // ERROR
          if (_error != null)
            _buildError(),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    _engine?.release();
    super.dispose();
  }
}
