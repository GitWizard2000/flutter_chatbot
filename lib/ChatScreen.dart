import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:project1/ChatService.dart';

import 'ImageScreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var resultText = "Results to be shown here...";
  var imageUrl = "Image url..";
  List<ChatMessage> messages = [];

  ChatUser user = ChatUser(id: '1', firstName: 'Mahesh', lastName: 'Chaudhari');

  ChatUser OpenAIuser = ChatUser(id: '2', firstName: 'Sam', lastName: 'Altman');

  List<Map<String, String>> ChatHistory = [
    {
      "role": "system",
      "content":
          "You are a highly knowledgeable, interactive, and friendly virtual assistant \n"
          "developed by Bosch company, specifically designed to help car and vehicle mechanics \n"
          "working in OEM workshops and garages. You assist users based on Bosch's extensive \n"
          "automotive database, service manuals, diagnostic procedures, and industry standards.\n\n"
          "Your responses are accurate and aligned with Bosch’s norms and service methodologies.\n"
          "You offer guidance grounded in real-world expertise and support from Bosch’s verified data.\n\n"
          "You have in-depth knowledge of:\n"
          "- Automotive systems (engine, transmission, suspension, brakes, HVAC, electrical, etc.)\n"
          "- On-board diagnostics (OBD1, OBD2, CAN protocols)\n"
          "- Diagnostic Trouble Codes (DTCs)\n"
          "- Wiring diagrams, repair manuals, and parts catalogs\n"
          "- Workshop tools, scan tools, meters, and service procedures\n"
          "- Preventive maintenance schedules and service intervals\n"
          "- Common symptoms and their likely causes\n"
          "- All makes and models, including luxury, economy, electric, and hybrid vehicles\n\n"
          "When interacting with the mechanic:\n"
          "- Ask relevant follow-up questions when needed (e.g., vehicle make, model, year, symptoms)\n"
          "- Provide clear, step-by-step troubleshooting instructions based on Bosch's repair flowcharts\n"
          "- Suggest tools or parts needed, referring to Bosch inventory or standards where applicable\n"
          "- Explain concepts in a simple and understandable way, aligned with Bosch service norms\n"
          "- Include warnings or safety precautions as per Bosch safety guidelines\n"
          "- Maintain a professional, helpful, and friendly tone\n\n"
          "You are not limited to a specific region, brand, or language of vehicle. \n"
          "You can handle queries on vehicle modifications, performance upgrades, workshop setup, \n"
          "and the latest trends in automotive technology, such as EVs and ADAS systems — always \n"
          "with reference to Bosch’s best practices and technical knowledge base.\n\n"
          "Never respond with “I don’t know.” Instead, say, “As per Bosch's database, here’s what we can try…” \n"
          "or ask for more details to help narrow down the issue. \n"
          "Simulate expert reasoning where needed to troubleshoot rare or unknown issues.\n\n"
          "You are here to make the mechanic’s job easier, faster, and more confident — all powered \n"
          "by Bosch company’s technology and automotive intelligence.",
    },
  ];

  ChatService chatService = ChatService();
  FlutterTts flutterTts = FlutterTts();
  askChatGPT() async {
    messages.insert(
      0,
      ChatMessage(text: inputCon.text, createdAt: DateTime.now(), user: user),
    );
    setState(() {
      messages;
    });

    ChatHistory.add({"role": "user", "content": inputCon.text});
    inputCon.text = "";
    resultText = await chatService.askChatGPT(ChatHistory);

    if (isTTS == true) {
      flutterTts.speak(resultText);
    }

    ChatHistory.add({"role": "assistant", "content": resultText});
    messages.insert(
      0,
      ChatMessage(
        text: resultText,
        createdAt: DateTime.now(),
        user: OpenAIuser,
      ),
    );
    setState(() {
      resultText;
    });
  }

  generateImages() async {
    messages.insert(
      0,
      ChatMessage(text: inputCon.text, createdAt: DateTime.now(), user: user),
    );
    setState(() {
      messages;
    });

    var prompt = inputCon.text;
    inputCon.text = "";
    imageUrl = await chatService.generateImages(prompt);

    messages.insert(
      0,
      ChatMessage(
        createdAt: DateTime.now(),
        user: OpenAIuser,
        medias: [
          ChatMedia(url: imageUrl, fileName: "image", type: MediaType.image),
        ],
      ),
    );
    setState(() {
      imageUrl;
    });
  }

  TextEditingController inputCon = TextEditingController();
  bool isTTS = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, //Set the background color here
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text('MechanIQ', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              flutterTts.stop();
              if (isTTS == true) {
                isTTS = false;
              } else {
                isTTS = true;
              }
              setState(() {
                isTTS;
              });
            },
            child: Icon(
              isTTS ? Icons.record_voice_over : Icons.voice_over_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: DashChat(
                currentUser: user,
                onSend: (ChatMessage m) {},
                readOnly: true,
                messages: messages,
                messageOptions: MessageOptions(
                  onTapMedia: (item) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageScreen(item.url),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(10),
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: TextField(
                      controller: inputCon,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type your query here",
                        hintStyle: TextStyle(color: Colors.white60),
                        // fillColor: Colors.grey, // Set the background color of the TextField
                        // filled: true, // Fill the background color yes/no
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String userInput = inputCon.text.toString().toLowerCase();

                    // List of keywords you want to check
                    List<String> imageKeywords = [
                      "image",
                      "generate image",
                      "generate an image",
                      "make an image",
                      "create image",
                      "draw image",
                      "picture",
                      "photo",
                      "give me an image",
                      "give me image",
                    ];
                    // Check if any keyword is present
                    final bool shouldGenerateImage = imageKeywords.any(
                      (keyword) => userInput.contains(keyword),
                    );

                    if (shouldGenerateImage) {
                      generateImages(); //Image generation feature
                    } else {
                      askChatGPT(); //Text generation feature
                    }
                  },
                  icon: Icon(Icons.send, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
