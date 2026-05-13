import 'package:flutter/material.dart';
import '../../../core/typography/app_text_styles.dart';


class PostCreationBox extends StatefulWidget {
  final VoidCallback? onCreatePost;
  final VoidCallback? onAttachImage;

  const PostCreationBox({super.key, this.onCreatePost, this.onAttachImage});

  @override
  State<PostCreationBox> createState() => _PostCreationBoxState();
}

class _PostCreationBoxState extends State<PostCreationBox> {
  late TextEditingController _textController;
  int _attachedImageCount = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleAttachImage() {
    if (_attachedImageCount < 4) {
      widget.onAttachImage?.call();
      setState(() => _attachedImageCount++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 4 images per post')),
      );
    }
  }

  void _handleCreatePost() {
    if (_textController.text.isNotEmpty || _attachedImageCount > 0) {
      widget.onCreatePost?.call();
      _textController.clear();
      setState(() => _attachedImageCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: AppTextStyles.body(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: AppTextStyles.body(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _handleAttachImage,
                    icon: const Icon(Icons.image),
                    tooltip: 'Attach image',
                  ),
                  if (_attachedImageCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_attachedImageCount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              // Post button
              ElevatedButton(
                onPressed: _handleCreatePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Post',
                  style: AppTextStyles.subheading(
                    context,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
