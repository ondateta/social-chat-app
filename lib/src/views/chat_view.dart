import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.chatId});
  
  final String chatId;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMessages() async {
    // Simulate loading messages
    await Future.delayed(const Duration(seconds: 1));
    
    final List<Message> messages = List.generate(
      15,
      (index) => Message(
        id: 'msg_${15 - index}',
        text: 'This is message ${15 - index} for chat ${widget.chatId}',
        senderId: (15 - index) % 2 == 0 ? 'current_user' : 'other_user',
        senderName: (15 - index) % 2 == 0 ? 'You' : 'User ${widget.chatId}',
        timestamp: DateTime.now().subtract(Duration(minutes: (15 - index) * 5)),
        messageType: MessageType.text,
      ),
    );
    
    // Add a sample image message
    messages.insert(2, Message(
      id: 'img_1',
      text: '',
      imageUrl: 'https://source.unsplash.com/random/300x200?sig=1',
      senderId: 'other_user',
      senderName: 'User ${widget.chatId}',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      messageType: MessageType.image,
    ));
    
    if (mounted) {
      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });
    }
  }
  
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }
  
  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }
  
  void _sendMessage() {
    final text = _messageController.text.trim();
    final hasText = text.isNotEmpty;
    final hasImage = _selectedImage != null;
    
    if (!hasText && !hasImage) return;
    
    if (hasImage) {
      _sendImageMessage(_selectedImage!, text);
    } else if (hasText) {
      _sendTextMessage(text);
    }
    
    _messageController.clear();
    _clearSelectedImage();
  }
  
  void _sendTextMessage(String text) {
    setState(() {
      _messages.insert(0, Message(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        senderId: 'current_user',
        senderName: 'You',
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      ));
    });
  }
  
  void _sendImageMessage(File image, String caption) {
    setState(() {
      _messages.insert(0, Message(
        id: 'new_img_${DateTime.now().millisecondsSinceEpoch}',
        text: caption,
        imageFile: image,
        senderId: 'current_user',
        senderName: 'You',
        timestamp: DateTime.now(),
        messageType: MessageType.image,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Text('U${widget.chatId}'),
            ),
            const Gap(12),
            GestureDetector(
              onTap: () {
                context.push('/profile/${widget.chatId}');
              },
              child: Text('User ${widget.chatId}'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator()
          else if (_messages.isEmpty)
            Expanded(
              child: Center(
                child: Text('No messages yet. Start a conversation!'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser = message.senderId == 'current_user';
                  
                  return Align(
                    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: message.messageType == MessageType.image 
                          ? const EdgeInsets.all(4)
                          : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCurrentUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.messageType == MessageType.image) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: message.imageFile != null
                                  ? Image.file(
                                      message.imageFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : message.imageUrl != null
                                      ? Image.network(
                                          message.imageUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              height: 150,
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / 
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 150,
                                              width: double.infinity,
                                              color: Colors.grey.shade300,
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.broken_image),
                                            );
                                          },
                                        )
                                      : Container(),
                            ),
                            if (message.text.isNotEmpty) ...[
                              const Gap(4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  message.text,
                                  style: TextStyle(
                                    color: isCurrentUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isCurrentUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                          const Gap(4),
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrentUser 
                                ? theme.colorScheme.onPrimary.withOpacity(0.7) 
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, size: 20),
                          onPressed: _clearSelectedImage,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'Image selected',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum MessageType {
  text,
  image,
}

class Message {
  final String id;
  final String text;
  final String? imageUrl;
  final File? imageFile;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final MessageType messageType;
  
  Message({
    required this.id,
    required this.text,
    this.imageUrl,
    this.imageFile,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.messageType,
  });
}