import 'dart:convert';

import 'package:http/http.dart';

class ChatService {
  askChatGPT(List<Map<String, String>> ChatHistory) async {
    try {
      final response = await post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
          'Bearer',
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": ChatHistory,
          "max_tokens": 150,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['choices'][0]['message']['content'];
      } else {
        print('Failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return "There is an error!";
      }
    }catch (e){
      print('Exception during HTTP call: $e');
      return "Network Error!";
    }
  }

  generateImages(String prompt) async {
    try {
      final response = await post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
          'Bearer',
        },
        body: jsonEncode({
          "model": "dall-e-3",
          "prompt": prompt,
          "quality": "standard", // or "hd" for higher quality
          "response_format": "url",
          "size": "1024x1024"
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'][0]['url'];
      } else {
        print('Failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return "There is an error!";
      }
    }catch (e){
      print('Exception during HTTP call: $e');
      return "Network Error!";
    }
  }
}
