import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flet/flet.dart';
import 'package:memospring/services/ai_service.dart';
import 'package:memospring/ffi/llama_ffi.dart';

class MockLlamaFFI extends Mock implements LlamaFFI {}

void main() {
  group('AIService', () {
    late AIService aiService;
    late MockLlamaFFI mockLlamaFFI;

    setUp(() {
      mockLlamaFFI = MockLlamaFFI();
      aiService = AIService(mockLlamaFFI);
    });

    test('sendMessage returns a non-null response when the model responds', () async {
      when(mockLlamaFFI.sendMessage(any)).thenAnswer((_) async => 'Hello');
      final response = await aiService.sendMessage('Hi');
      expect(response, isNotNull);
      expect(response, 'Hello');
    });

    test('sendMessage returns a non-null response when the model returns null', () async {
      when(mockLlamaFFI.sendMessage(any)).thenAnswer((_) async => null);
      final response = await aiService.sendMessage('Hi');
      expect(response, isNotNull);
      expect(response, 'Error: No response from model');
    });
  });
}
