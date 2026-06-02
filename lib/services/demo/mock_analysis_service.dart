// Mock analysis service — stands in for the backend OpenAI/Pinecone cycle.

import '../../core/constants/app_constants.dart';
import '../../models/analysis_result.dart';
import '../../models/enums.dart';
import 'demo_script_service.dart';

/// Stands in for the backend analysis cycle (embed → Pinecone retrieve → single
/// OpenAI call). It mirrors that contract — accumulated customer text in, a
/// single [AnalysisResult] out, after a debounce — but returns scripted content
/// so the demo is deterministic and offline (rules #3, #7).
class MockAnalysisService {
  const MockAnalysisService(this._script);

  final DemoScriptService _script;

  Future<AnalysisResult> analyze({
    required Mood mood,
    required bool arabic,
    String transcriptText = '',
    int round = 0,
  }) async {
    // Simulates retrieval + the structured LLM call latency.
    await Future<void>.delayed(AppConfig.analysisDebounce);
    return _script.analysis(mood, arabic, round: round);
  }
}
