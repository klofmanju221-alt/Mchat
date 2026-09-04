import 'package:flutter/material.dart';

import 'family_room_screen.dart';

/// Broad Room entry screen.
///
/// The complete premium Mchat Room UI is shared with Family Room
/// so both room types have the same locked UI/features.
class BroadRoomScreen extends StatelessWidget {
  const BroadRoomScreen({
    super.key,
    this.roomName = 'Mchat Broad Room',
    this.hostName = 'Mchat Host',
    this.hostMchatId = '11111111',
  });

  final String roomName;
  final String hostName;
  final String hostMchatId;

  @override
  Widget build(BuildContext context) {
    return MchatRoomScreen(
      roomType: MchatRoomType.broad,
      roomName: roomName,
      hostName: hostName,
      hostMchatId: hostMchatId,
    );
  }
}
