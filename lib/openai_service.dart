import 'dart:convert';

import 'package:allen/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService{
  final List<Map<String, String>> messages=[];
  Future<String> isArtPromptAPI(String prompt) async {
    try{
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type':'application/json',
          'Authorization':'Bearer $openAIAPIKey'
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages":[
            {
            'roll':'user',
            'content':'Does this message want to generate and AI picture, image, art, or anything similar? $prompt . Simply answer with a yes or no!',
            }
          ]
        }),
      );
      print(response.body);
      if(response.statusCode==200){
        String content = jsonDecode(response.body)['choices'][0]['message']['content'];
        content=content.trim();

        switch(content)
        {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final response=await dallEAPI(prompt);
            return response;
          default:
            final response=await chatGPTAPI(prompt);
            return response;
        }
      }
      return 'An internal error occurred';
    }catch(e)
    {
      return e.toString();
    }
  }
  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role':'user',
      'content':prompt,
    });
    try{
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type':'application/json',
          'Authorization':'Bearer $openAIAPIKey'
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages":messages,
        }),
      );
      
      if(response.statusCode==200){
        String content = jsonDecode(response.body)['choices'][0]['message']['content'];
        content=content.trim();

        messages.add({
          'role':'assistant',
          'content':content,
        });
        return content;
      }
      return 'An internal error occurred';
    }catch(e)
    {
      return e.toString();
    }
    // return 'CHATGPT';
  }
  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role':'user',
      'content': prompt,
    });
    try{
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type':'application/json',
          'Authorization':'Bearer $openAIAPIKey'
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );
      
      if(response.statusCode==200){
        String imageURL = jsonDecode(response.body)['data'][0]['url'];
        imageURL=imageURL.trim();

        messages.add({
          'role':'assistant',
          'content':imageURL,
        });
        return imageURL;
      }
      return 'An internal error occurred';
    }catch(e)
    {
      return e.toString();
    }
    // return 'CHATGPT';
  }
}