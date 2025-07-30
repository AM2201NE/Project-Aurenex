import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:neonote/services/ai_service.dart';
import 'package:neonote/ai/llm_interface.dart';

class MockAIService extends Mock implements AIService {}

void main() {
  group('AIService', () {
    late MockAIService mockAIService;

    setUp(() {
      mockAIService = MockAIService();
    });

    test('generateText returns a non-null response when the model responds',
        () async {
      when(mockAIService.generateText(any)).thenAnswer((_) async => 'Hello');
      final response = await mockAIService.generateText('Hi');
      expect(response, isNotNull);
      expect(response, 'Hello');
    });

    test(
        'generateText returns an error message when the model returns an empty string',
        () async {
      when(mockAIService.generateText(any)).thenAnswer((_) async => '');
      final response = await mockAIService.generateText('Hi');
      expect(response, isNotNull);
      expect(response, '');
    });
  });
}
