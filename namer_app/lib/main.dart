// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:io';

Future<String> processPrompt(String prompt) async {
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
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
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
        child: TextField(
          controller: myController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await processPrompt(myController.text);
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(result),
              );
            },
          );
        },
        tooltip: 'Execute',
        child: const Icon(Icons.text_fields),
      ),
    );
  }
}
