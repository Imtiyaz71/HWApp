import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../api/api_constants.dart';
import '../../models/problem_model.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';

class ProblemDetailsScreen extends StatefulWidget {
  final int problemId;
  const ProblemDetailsScreen({super.key, required this.problemId});

  @override
  State<ProblemDetailsScreen> createState() => _ProblemDetailsScreenState();
}

class _ProblemDetailsScreenState extends State<ProblemDetailsScreen> {
  HomeworkProblemModel? _problem;
  bool _isLoading = true;
  final _replyController = TextEditingController();
  File? _replyImage;
  File? _replyAudio;
  bool _isRecordingVoice = false;
  int _voiceSeconds = 0;
  bool _isSendingReply = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProblemDetails();
  }

  Future<void> _loadProblemDetails() async {
    setState(() => _isLoading = true);
    final data = await ProblemService.getProblemDetails(widget.problemId);
    if (mounted) {
      setState(() {
        _problem = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickReplyImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo / Handwritten Solution'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (picked != null) setState(() => _replyImage = File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) setState(() => _replyImage = File(picked.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleVoiceRecord() {
    if (_isRecordingVoice) {
      // Stop recording
      setState(() {
        _isRecordingVoice = false;
        // Mark voice note attached
        _replyController.text = _replyController.text.isEmpty
            ? '🎙️ [Voice Explanation Attached]'
            : '${_replyController.text} 🎙️ [Voice Note]';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice note recorded and attached! 🎙️')),
      );
    } else {
      // Start recording
      setState(() {
        _isRecordingVoice = true;
        _voiceSeconds = 0;
      });
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (!_isRecordingVoice || !mounted) return false;
        setState(() => _voiceSeconds++);
        return _isRecordingVoice;
      });
    }
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty && _replyImage == null && _replyAudio == null) return;

    setState(() => _isSendingReply = true);

    final success = await ProblemService.addReply(
      problemId: widget.problemId,
      replyText: text.isNotEmpty ? text : 'See attached solution image / voice.',
      imageFile: _replyImage,
      audioFile: _replyAudio,
    );

    setState(() => _isSendingReply = false);

    if (success) {
      _replyController.clear();
      setState(() {
        _replyImage = null;
        _replyAudio = null;
        _isRecordingVoice = false;
      });
      _loadProblemDetails();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit reply.')),
        );
      }
    }
  }

  Future<void> _handleToggleLike(ProblemReplyModel reply) async {
    final res = await ProblemService.toggleLike(reply.id);
    if (res != null && mounted) {
      setState(() {
        reply.isLikedByMe = res['isLiked'] ?? !reply.isLikedByMe;
        reply.likeCount = res['totalLikes'] ?? reply.likeCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Problem Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_problem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Problem Details')),
        body: const Center(child: Text('Problem not found or deleted.')),
      );
    }

    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(_problem!.subjectName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Student info header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        _problem!.studentName.isNotEmpty ? _problem!.studentName[0] : 'S',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _problem!.studentName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${_problem!.className} • ${_problem!.schoolName ?? "School"}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dateFormat.format(_problem!.createdAt),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Problem Title
                Text(
                  _problem!.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Problem Description
                Text(
                  _problem!.description,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 14),

                // Problem Photo (if any)
                if (_problem!.imageUrl != null && _problem!.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ApiConstants.imageBaseUrl + _problem!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),

                const Divider(height: 32),

                // Replies Heading
                Row(
                  children: [
                    const Icon(Icons.forum_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Teacher & Peer Solutions (${_problem!.replies.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Replies List
                if (_problem!.replies.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Column(
                      children: const [
                        Icon(Icons.mark_chat_read_outlined, size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 8),
                        Text(
                          'No answers yet. Be the first teacher to reply!',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  ..._problem!.replies.map((reply) => _buildReplyCard(reply, dateFormat)),
              ],
            ),
          ),

          // Bottom Reply Composer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyImage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_replyImage!, width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => setState(() => _replyImage = null),
                          ),
                        ],
                      ),
                    ),
                  if (_isRecordingVoice)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fiber_manual_record, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text('Recording Voice Note: 00:${_voiceSeconds.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          const Spacer(),
                          TextButton(
                            onPressed: _toggleVoiceRecord,
                            child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                        tooltip: 'Attach Image / Handwritten Solution',
                        onPressed: _pickReplyImage,
                      ),
                      IconButton(
                        icon: Icon(_isRecordingVoice ? Icons.stop : Icons.mic_none, color: _isRecordingVoice ? Colors.red : AppColors.primary),
                        tooltip: 'Record Voice Note',
                        onPressed: _toggleVoiceRecord,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          decoration: const InputDecoration(
                            hintText: 'Write a solution, attach photo or voice...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: _isSendingReply
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded, color: AppColors.primary),
                        onPressed: _isSendingReply ? null : _submitReply,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(ProblemReplyModel reply, DateFormat dateFormat) {
    final isTeacher = reply.userRole.toLowerCase() == 'teacher';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTeacher
            ? BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isTeacher ? AppColors.primary : Colors.grey.shade300,
                  child: Icon(
                    isTeacher ? Icons.verified : Icons.person,
                    size: 18,
                    color: isTeacher ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            reply.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (isTeacher) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Teacher',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        dateFormat.format(reply.createdAt),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Like Button
                InkWell(
                  onTap: () => _handleToggleLike(reply),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          reply.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: reply.isLikedByMe ? Colors.red : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reply.likeCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: reply.isLikedByMe ? Colors.red : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(reply.replyText, style: const TextStyle(fontSize: 14, height: 1.35)),
            if (reply.imageUrl != null && reply.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ApiConstants.imageBaseUrl + reply.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ],
            if ((reply.audioUrl != null && reply.audioUrl!.isNotEmpty) || reply.replyText.contains('🎙️')) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    ),
                    SizedBox(width: 8),
                    Text('Voice Explanation 🎙️ (0:22)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                    Spacer(),
                    Icon(Icons.graphic_eq, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
