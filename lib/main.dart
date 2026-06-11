import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

const streamUrl =
    'https://jireh-1-hls-audio-br-isp.dps.live/hls-audio/4e252a65837b69e349d5d8c1033152b4/hztear/gotardisz/livestream1.m3u8';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.fmhorizonte.radio.channel.audio',
    androidNotificationChannelName: 'FM Horizonte Radio',
    androidNotificationOngoing: true,
  );
  runApp(const RadioApp());
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FM Horizonte 94.3/101.9',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const RadioPlayerPage(),
    );
  }
}

class RadioPlayerPage extends StatefulWidget {
  const RadioPlayerPage({super.key});

  @override
  State<RadioPlayerPage> createState() => _RadioPlayerPageState();
}

class _RadioPlayerPageState extends State<RadioPlayerPage> {
  final _player = AudioPlayer();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  Future<void> _setupPlayer() async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          tag: const MediaItem(
            id: '1',
            album: 'Radio en vivo',
            title: 'FM Horizonte 94.3/101.9',
            artUri: null,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error loading stream: $e');
    }
  }

  Future<void> _togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      setState(() => _isLoading = true);
      try {
        // Reload source to get a fresh session/token on each play
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(streamUrl),
            tag: const MediaItem(
              id: '1',
              album: 'Radio en vivo',
              title: 'FM Horizonte 94.3/101.9',
              artUri: null,
            ),
          ),
        );
        await _player.play();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al conectar: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/logo.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.radio,
                    size: 220,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'FM Horizonte 94.3/101.9',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  final processingState = snapshot.data?.processingState;
                  final loading = _isLoading ||
                      processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering;

                  return GestureDetector(
                    onTap: loading ? null : _togglePlay,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: loading
                          ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  final processingState = snapshot.data?.processingState;
                  String label = 'Toca play para escuchar';
                  if (_isLoading || processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                    label = 'Conectando...';
                  } else if (playing) {
                    label = 'En vivo';
                  }
                  return Text(label, style: const TextStyle(fontSize: 16));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
