import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ceka TV - Chat',
      theme: ThemeData.dark(),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  IO.Socket? socket;
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io("https://your-replit-url.repl.co", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });

    socket!.onConnect((_) {
      setState(() {
        messages.add("Connected to a stranger.");
      });
    });

    socket!.on("message", (data) {
      setState(() {
        messages.add("Stranger: $data");
      });
    });

    socket!.onDisconnect((_) {
      setState(() {
        messages.add("Disconnected.");
      });
    });
  }

  void sendMessage(String msg) {
    if (msg.isNotEmpty) {
      socket!.emit("message", msg);
      setState(() {
        messages.add("You: $msg");
      });
      _controller.clear();
    }
  }

  @override
  void dispose() {
    socket!.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ceka TV")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(8),
              children: messages.map((msg) => Text(msg)).toList(),
            ),
          ),
          Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "Type a message"),
                  onSubmitted: sendMessage,
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => sendMessage(_controller.text),
              ),
            ],
          )
        ],
      ),
    );
  }
}
