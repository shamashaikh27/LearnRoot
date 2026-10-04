import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/topic.dart';
import '../models/learning_resource.dart';
import '../services/module4_api.dart';

class VideoResourcesScreen extends StatefulWidget {
  final Module4Topic topic;

  const VideoResourcesScreen({
    super.key,
    required this.topic,
  });

  @override
  State<VideoResourcesScreen> createState() =>
      _VideoResourcesScreenState();
}

class _VideoResourcesScreenState extends State<VideoResourcesScreen> {
  bool loading = true;
  String? error;
  List<LearningResource> videos = [];

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      final data =
          await Module4Api.getVideos(widget.topic.topicId);

      if (!mounted) return;

      setState(() {
        videos = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> openVideo(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the video link.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Resources'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : videos.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        return _videoCard(context, videos[index]);
                      },
                    ),
    );
  }

  Widget _videoCard(
    BuildContext context,
    LearningResource video,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF593AB9),
                    Color(0xFF7B61D1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VIDEO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: video.link.isEmpty
                        ? null
                        : () => openVideo(video.link),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Watch Video'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.ondemand_video_outlined,
              size: 58,
            ),
            const SizedBox(height: 12),
            const Text(
              'No Videos Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Video resources for this topic are not available yet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: loadVideos,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
