import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kctrustedcarpool/cloud_functions/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverProfileUrl; // ✅ Profile Picture

  // ChatScreen({required this.receiverId, required this.receiverName, required this.receiverProfileUrl});
  ChatScreen({required this.receiverId, required this.receiverName, required this.receiverProfileUrl});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String chatId;
  TextEditingController _messageController = TextEditingController();
  ChatService chatService = ChatService();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    chatId = await chatService.startChat(widget.receiverId);
    chatService.markMessagesAsRead(chatId); // ✅ Mark messages as read
    setState(() {}); 
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      chatService.sendMessage(chatId, _messageController.text, widget.receiverId);
      _messageController.clear();

      Future.delayed(Duration(milliseconds: 300), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.receiverName}")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getChatMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;
                return ListView.builder(
  controller: _scrollController,
  itemCount: messages.length,
  itemBuilder: (context, index) {
    var message = messages[index];
    bool isMe = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
    
    // ✅ Fix: Provide default value for `isRead` if missing
    bool isRead = message.data().containsKey('isRead') ? message['isRead'] : false;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          CircleAvatar(
            backgroundImage: widget.receiverProfileUrl.isNotEmpty
                ? NetworkImage(widget.receiverProfileUrl)
                : null,
            child: widget.receiverProfileUrl.isEmpty
                ? Text(widget.receiverName[0].toUpperCase())
                : null,
          ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[300] : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message['text'], style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message['timestamp'] != null
                        ? DateFormat('hh:mm a').format((message['timestamp'] as Timestamp).toDate())
                        : "Sending...",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  if (isMe)
                    Icon(
                      isRead ? Icons.done_all : Icons.check, // ✅ Fix: Use the default `isRead`
                      size: 16,
                      color: isRead ? Colors.blue : Colors.black54,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  },
);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
