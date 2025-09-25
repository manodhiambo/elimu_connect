// packages/app/lib/src/features/communication/video_calls/presentation/pages/video_call_page.dart
class VideoCallPage extends ConsumerWidget {
  final String callId;
  
  const VideoCallPage({Key? key, required this.callId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(videoCallProvider(callId));
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video view
          Positioned.fill(
            child: callState.remoteVideoRenderer != null
                ? RTCVideoView(callState.remoteVideoRenderer!)
                : const Center(
                    child: Text(
                      'Waiting for participants...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          
          // Local video view (picture-in-picture)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: callState.localVideoRenderer != null
                    ? RTCVideoView(callState.localVideoRenderer!)
                    : Container(color: Colors.grey),
              ),
            ),
          ),
          
          // Call controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CallControlButton(
                  icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                  onPressed: () => _toggleMute(ref, callId),
                  backgroundColor: callState.isMuted ? Colors.red : Colors.white24,
                ),
                CallControlButton(
                  icon: Icons.call_end,
                  onPressed: () => _endCall(ref, callId),
                  backgroundColor: Colors.red,
                ),
                CallControlButton(
                  icon: callState.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  onPressed: () => _toggleVideo(ref, callId),
                  backgroundColor: callState.isVideoEnabled ? Colors.white24 : Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
