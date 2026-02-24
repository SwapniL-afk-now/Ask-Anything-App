import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/five_w_model.dart';
import 'api_interface.dart';

class GeminiApiService implements ApiInterface {
  final String _apiKey = 'AIzaSyCi2ENTgbxsV03OaBuI6WaY8VPyYMogJs4';
  
  String _buildSystemInstruction(String profession) {
    return '''<role>
You are an expert research assistant that explains topics using the 5W1H framework (What, Why, Who, Where, When, How).
Your explanations must adapt to the user's profession ($profession) and the complexity of the topic.
</role>

<instructions>
1. First, analyze the topic and determine its complexity level (Basic, Intermediate, or Advanced).
2. Structure your response using the 5W1H framework with clear headings.
3. Adapt the depth, terminology, and examples to suit a $profession's perspective.
4. Use grounded, up-to-date information.
5. Be concise for simple topics and more detailed for complex topics.
6. Maintain professional tone appropriate for the user's background.
</instructions>

<output_format>
You MUST respond with a valid JSON object in exactly this format:
{
    "complexity": "Basic|Intermediate|Advanced",
    "answers": {
        "what": "Clear definition and description of the topic",
        "why": "Reasons, motivations, and significance",
        "who": "Key people, organizations, or entities involved",
        "where": "Locations, contexts, and scope",
        "when": "Timeline, history, and temporal aspects",
        "how": "Methods, processes, and implementation details"
    }
}
</output_format>

<constraints>
- Respond ONLY with valid JSON, no markdown formatting or code blocks
- Each field should contain substantive information (at least 2-3 sentences)
- Use terminology appropriate for a $profession
</constraints>''';
  }

  String _buildUserPrompt(String topic) {
    return '''<context>
The user wants to understand the following topic using the 5W1H framework.
</context>

<task>
Analyze this topic: $topic

Provide a comprehensive 5W1H analysis with:
1. First determine the complexity level
2. Answer What, Why, Who, Where, When, and How
3. Adapt language and depth to the profession

Return ONLY valid JSON.
</task>''';
  }

  @override
  Future<AnalyzeResponse> analyzeTopic(String profession, String topic) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\$_apiKey');
    
    final requestBody = jsonEncode({
      "system_instruction": {
        "parts": {
          "text": _buildSystemInstruction(profession)
        }
      },
      "contents": [
        {
          "parts": [
            {"text": _buildUserPrompt(topic)}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 1.0,
        "maxOutputTokens": 4096,
         "responseMimeType": "application/json"
      }
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      // Extract the text part
      final candidates = jsonResponse['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content']['parts'][0]['text'] as String;
        
        try {
          final parsedJson = jsonDecode(content);
          return AnalyzeResponse.fromJson(parsedJson);
        } catch (e) {
          throw Exception("Failed to parse Gemini JSON: \$content");
        }
      }
      throw Exception('Empty response from Gemini');
    } else {
      throw Exception('Failed to load analysis from Gemini: \${response.statusCode} - \${response.body}');
    }
  }
}
