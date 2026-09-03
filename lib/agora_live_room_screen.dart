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
    extends State<AgoraLiveRoomScreen> {
  RtcEngine? _engine;

  int? _remoteUid;

  bool _joined = false;
  bool _cameraEnabled = true;
  bool _micEnabled = true;
  bool _loading = true;
  bool _leaving = false;

  String? _error;

  int _localLikes = 0;

  final TextEditingController _messageController =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

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

    // HOST CAMERA
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

    // VIEWER
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

          publishCameraTrack: newValue,

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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
  // CHAT SEND
  // ============================================================

  Future<void> _sendMessage() async {
    final text =
        _messageController.text.trim();

    if (text.isEmpty) return;

    final user =
        _auth.currentUser;

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
      final userDoc =
          await _firestore
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

      await _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .collection('messages')
          .add({
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
  // CHAT UI
  // ============================================================

  Widget _buildChat() {
    if (widget.roomId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 14,
      right: 14,
      bottom: widget.isHost
          ? 165
          : 85,
      child: SizedBox(
        height: 190,
        child: StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream: _firestore
              .collection('rooms')
              .doc(widget.roomId)
              .collection('messages')
              .orderBy(
                'createdAt',
                descending: true,
              )
              .limit(30)
              .snapshots(),
          builder: (
            context,
            snapshot,
          ) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final messages =
                snapshot.data!.docs;

            return ListView.builder(
              reverse: true,
              itemCount:
                  messages.length,
              itemBuilder: (
                context,
                index,
              ) {
                final data =
                    messages[index]
                        .data();

                final name =
                    (data['senderName'] ??
                            'User')
                        .toString();

                final text =
                    (data['text'] ?? '')
                        .toString();

                final type =
                    (data['type'] ??
                            'text')
                        .toString();

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 6,
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
                        text:
                            TextSpan(
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
                              ),
                            ),
                            TextSpan(
                              text:
                                  text,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                              ),
                            ),
                            if (type ==
                                'gift')
                              const TextSpan(
                                text:
                                    ' 🎁',
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
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 24,
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

                        _confirmGift(
                          gift,
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
                                fontSize: 38,
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
                              height: 4,
                            ),
                            Text(
                              '🪙 ${gift['coins']}',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.amber,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmGift(
    Map<String, dynamic> gift,
  ) async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Send Gift?'),
          content: Text(
            '${gift['emoji']} ${gift['name']}\n\n'
            'Cost: ${gift['coins']} Coins\n'
            'To: ${widget.hostName}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              icon:
                  const Icon(
                Icons.card_giftcard,
              ),
              label:
                  const Text('Send'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _sendGift(gift);
    }
  }

  // ============================================================
  // SEND GIFT
  // ============================================================

  Future<void> _sendGift(
    Map<String, dynamic> gift,
  ) async {
    final sender =
        _auth.currentUser;

    if (sender == null) {
      return;
    }

    if (widget.hostUid.isEmpty ||
        widget.roomId.isEmpty) {
      _showMessage(
        'Host information unavailable.',
      );
      return;
    }

    if (sender.uid ==
        widget.hostUid) {
      _showMessage(
        'You cannot send a gift to yourself.',
      );
      return;
    }

    final coins =
        (gift['coins'] as num).toInt();

    final senderRef =
        _firestore
            .collection('users')
            .doc(sender.uid);

    final hostRef =
        _firestore
            .collection('users')
            .doc(widget.hostUid);

    final roomRef =
        _firestore
            .collection('rooms')
            .doc(widget.roomId);

    try {
      await _firestore
          .runTransaction(
        (transaction) async {
          final senderSnap =
              await transaction.get(
            senderRef,
          );

          final hostSnap =
              await transaction.get(
            hostRef,
          );

          final senderData =
              senderSnap.data() ??
                  {};

          final hostData =
              hostSnap.data() ??
                  {};

          final senderCoins =
              (senderData['coins']
                          as num?)
                      ?.toInt() ??
                  0;

          final hostCoins =
              (hostData['coins']
                          as num?)
                      ?.toInt() ??
                  0;

          if (senderCoins <
              coins) {
            throw Exception(
              'INSUFFICIENT_COINS',
            );
          }

          transaction.update(
            senderRef,
            {
              'coins':
                  senderCoins -
                      coins,
            },
          );

          transaction.update(
            hostRef,
            {
              'coins':
                  hostCoins +
                      coins,
            },
          );

          final giftRef =
              roomRef
                  .collection(
                      'gifts')
                  .doc();

          transaction.set(
            giftRef,
            {
              'senderId':
                  sender.uid,
              'hostUid':
                  widget.hostUid,
              'giftName':
                  gift['name'],
              'giftEmoji':
                  gift['emoji'],
              'coins':
                  coins,
              'createdAt':
                  FieldValue
                      .serverTimestamp(),
            },
          );
        },
      );

      await roomRef
          .collection('messages')
          .add({
        'senderId':
            sender.uid,
        'senderName':
            sender.displayName ??
                'Mchat User',
        'text':
            '${gift['emoji']} Sent ${gift['name']}',
        'type': 'gift',
        'giftName':
            gift['name'],
        'giftEmoji':
            gift['emoji'],
        'coins':
            coins,
        'createdAt':
            FieldValue
                .serverTimestamp(),
      });

      _showMessage(
        '${gift['emoji']} Gift sent successfully!',
      );
    } catch (e) {
      if (e.toString().contains(
            'INSUFFICIENT_COINS',
          )) {
        _showMessage(
          'Not enough Mchat Coins.',
        );
      } else {
        _showMessage(
          'Gift could not be sent.',
        );
      }
    }
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Positioned(
      top: 38,
      left: 12,
      right: 8,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                Colors.pinkAccent,
            child: Text(
              widget.hostName.isNotEmpty
                  ? widget.hostName[0]
                      .toUpperCase()
                  : 'M',
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

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
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const Text(
                  'Mchat Live',
                  style:
                      TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          StreamBuilder<int>(
            stream:
                _viewerCountStream(),
            builder:
                (context, snapshot) {
              final count =
                  snapshot.data ??
                      0;

              return Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.black54,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.visibility,
                      color:
                          Colors.white,
                      size: 17,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '$count',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          IconButton(
            onPressed:
                _leaveRoom,
            icon:
                const Icon(
              Icons.close,
              color:
                  Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIVE BADGE
  // ============================================================

  Widget _buildLiveBadge() {
    return Positioned(
      top: 100,
      left: 16,
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration:
            BoxDecoration(
          color: Colors.red,
          borderRadius:
              BorderRadius.circular(
            22,
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.circle,
              color: Colors.white,
              size: 8,
            ),
            const SizedBox(
              width: 6,
            ),
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
    );
  }

  // ============================================================
  // BOTTOM UI
  // ============================================================

  Widget _buildBottom() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.black54,
                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    child:
                        TextField(
                      controller:
                          _messageController,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),
                      decoration:
                          const InputDecoration(
                        border:
                            InputBorder.none,
                        hintText:
                            'Say something...',
                        hintStyle:
                            TextStyle(
                          color:
                              Colors.white60,
                        ),
                      ),
                      onSubmitted:
                          (_) {
                        _sendMessage();
                      },
                    ),
                  ),
                ),

                const SizedBox(
                  width: 7,
                ),

                _roundButton(
                  Icons.send,
                  _sendMessage,
                ),

                const SizedBox(
                  width: 7,
                ),

                _roundButton(
                  Icons.favorite,
                  () {
                    setState(() {
                      _localLikes++;
                    });
                  },
                ),

                const SizedBox(
                  width: 7,
                ),

                _roundButton(
                  Icons.card_giftcard,
                  _showGiftSheet,
                  color:
                      Colors.pink,
                ),
              ],
            ),

            if (widget.isHost)
              const SizedBox(
                height: 12,
              ),

            if (widget.isHost)
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  _controlButton(
                    _micEnabled
                        ? Icons.mic
                        : Icons.mic_off,
                    _toggleMic,
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  _controlButton(
                    _cameraEnabled
                        ? Icons.videocam
                        : Icons.videocam_off,
                    _toggleCamera,
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  _controlButton(
                    Icons
                        .flip_camera_ios,
                    _flipCamera,
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  _controlButton(
                    Icons.call_end,
                    _leaveRoom,
                    danger: true,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _roundButton(
    IconData icon,
    VoidCallback onPressed, {
    Color color =
        Colors.black54,
  }) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: color,
      child: IconButton(
        onPressed:
            onPressed,
        icon: Icon(
          icon,
          color:
              Colors.white,
        ),
      ),
    );
  }

  Widget _controlButton(
    IconData icon,
    VoidCallback onPressed, {
    bool danger = false,
  }) {
    return CircleAvatar(
      radius: 28,
      backgroundColor:
          danger
              ? Colors.red
              : Colors.black54,
      child: IconButton(
        onPressed:
            onPressed,
        icon: Icon(
          icon,
          color:
              Colors.white,
          size: 27,
        ),
      ),
    );
  }

  // ============================================================
  // LEAVE
  // ============================================================

  Future<void> _leaveRoom() async {
    if (_leaving) return;

    _leaving = true;

    try {
      if (!widget.isHost) {
        await _updateViewerCount(-1);
      }

      if (widget.isHost &&
          widget.roomId.isNotEmpty) {
        await _firestore
            .collection('rooms')
            .doc(widget.roomId)
            .update({
          'status': 'ended',
          'updatedAt':
              FieldValue
                  .serverTimestamp(),
        });
      }

      final engine =
          _engine;

      if (engine != null) {
        await engine.leaveChannel();
        await engine.release();
      }

      _engine = null;
    } catch (_) {}

    if (!mounted) return;

    Navigator.pop(context);
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
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black,
      resizeToAvoidBottomInset:
          true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // FULL SCREEN VIDEO
          _buildVideo(),

          // TOP GRADIENT
          IgnorePointer(
            child: Container(
              decoration:
                  const BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.center,
                  colors: [
                    Colors.black87,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          _buildTopBar(),

          _buildLiveBadge(),

          _buildChat(),

          _buildBottom(),

          // ERROR
          if (_error != null)
            Positioned(
              top: 160,
              left: 18,
              right: 18,
              child: Container(
                padding:
                    const EdgeInsets.all(
                  14,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.red
                      .withOpacity(.88),
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: Text(
                  _error!,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ),

          // LOADING
          if (_loading)
            const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Colors.white,
              ),
            ),
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

    final engine =
        _engine;

    if (engine != null) {
      engine.leaveChannel();
      engine.release();
    }

    super.dispose();
  }
}
