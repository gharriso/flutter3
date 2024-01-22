// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';

Future<String> processPromptOpenAiApi(String prompt) async {
  // Set the OpenAI API key from the .env file.
  OpenAI.apiKey = Platform.environment['OPENAI_KEY'].toString();

  // Start using!
  final completion = await OpenAI.instance.completion.create(
    model: "gpt-3.5-turbo-instruct",
    prompt: prompt,
    maxTokens: 256,
  );

  // Printing the output to the console
  var output = completion.choices[0].text;
  print(output);
  return (output);
}

Future<String> processPromptGoogleAi(String prompt) async {
  final apiKey = Platform.environment['GOOGLE_AI_KEY'].toString();
  final url =
      "https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=$apiKey";
  final uri = Uri.parse(url);

  Map<String, dynamic> request = {
    "prompt": {
      "messages": [
        {"content": prompt}
      ]
    },
    "temperature": 0.25,
    "candidateCount": 1,
    "topP": 1,
    "topK": 1
  };

  final response = await http.post(uri, body: jsonEncode(request));
  final answer = json.decode(response.body)["candidates"][0]["content"];

  return (answer);
}

Future<String> processOpenAIPromptHttp(String prompt) async {
  var url = Uri.parse('https://api.openai.com/v1/completions');
  // Combine two strings
  var openAIKey = Platform.environment['OPENAI_KEY'];
  var authKey = 'Bearer $openAIKey';
  print('prompt: $prompt');
  var headers = {'Content-Type': 'application/json', 'Authorization': authKey};
  var body = convert.jsonEncode(
      {'prompt': prompt, "model": "gpt-3.5-turbo-instruct", 'max_tokens': 128});

  var response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);

    var promptResponse = jsonResponse['choices'][0]['text'];
    print('Response: $promptResponse');
    return promptResponse;
  } else {
    print('Request failed with status: ${response.statusCode}.');
    print(convert.json.decode(response.body));
    return response.statusCode.toString();
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AI Helper',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final promptController =
      TextEditingController(text: 'Enter your question here');
  final outputController1 =
      TextEditingController(text: 'The result of your question will go here');
  final outputController2 =
      TextEditingController(text: 'The result of your question will go here');
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    promptController.dispose();
    outputController1.dispose();
    outputController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: promptController,
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller:
                          outputController1, // use a different controller for this text field
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller:
                          outputController2, // use a different controller for this text field
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result2 = await processPromptGoogleAi(promptController.text);
          outputController2.text = result2;
          String result = await processPromptOpenAiApi(promptController.text);
          outputController1.text = result;
          /*showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(result),
              );
            },
          );
        */
        },
        tooltip: 'Execute',
        child: const Icon(Icons.text_fields),
      ),
    );
  }
}
