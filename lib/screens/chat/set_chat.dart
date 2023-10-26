import 'package:flutter/material.dart';
import '../../model/message.dart';
import '../../model/user_model.dart';
import '../../service/token/TokenProvider.dart';
import '../../service/user_service/user_service.dart';

class MessagingScreen extends StatefulWidget {
  final AppUser user;

  const MessagingScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  late TokenProvider _tokenProvider;
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _tokenProvider = TokenProvider();
    _userService = UserService(_tokenProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.user.firstName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isMe ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                _sendMessage(text, isMe: true);
              },
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _sendMessage(_textController.text, isMe: true);
            },
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text, {bool isMe = false}) async {
    if (text.isNotEmpty) {
      final newMessage = Message(text: text, isMe: isMe);
      final senderId = _tokenProvider.getUserId();
      try {
        await _userService.sendMessage(
          senderId: senderId,
          receiverId: widget.user.id,
          content: text,
        );
        setState(() {
          _messages.add(newMessage);
          _textController.clear();
        });
      } catch (e) {
        print('Failed to send message: $e');
      }
    }
  }
}
