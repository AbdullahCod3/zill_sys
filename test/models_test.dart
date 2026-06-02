import 'package:flutter_test/flutter_test.dart';
import 'package:zill_sys/models/analysis_result.dart';
import 'package:zill_sys/models/customer_model.dart';
import 'package:zill_sys/models/enums.dart';

void main() {
  group('snake_case ⇄ camelCase boundary', () {
    test('CustomerModel maps snake_case storage to camelCase fields', () {
      final c = CustomerModel.fromJson(const {
        'customer_id': 'c1',
        'name': 'Layla',
        'account_number': 'ZL-447',
        'language_preference': 'ar',
        'recent_issues': ['billing'],
      });
      expect(c.customerId, 'c1');
      expect(c.accountNumber, 'ZL-447');
      expect(c.languagePreference, 'ar');
      expect(c.recentIssues, ['billing']);
      // Round-trips back to snake_case for storage.
      expect(c.toJson()['account_number'], 'ZL-447');
    });

    test('AnalysisResult parses the PRD §11 JSON shape', () {
      final r = AnalysisResult.fromJson(const {
        'language': 'en',
        'problem_summary': 'Internet down',
        'suggested_answer': 'Sorry about that',
        'citations': [
          {'document_id': 'KB-114', 'title': 'Outage Policy'},
        ],
        'anger_score': 8,
        'escalation_requested': false,
        'confidence': 'high',
      });
      expect(r.problemSummary, 'Internet down');
      expect(r.angerScore, 8);
      expect(r.confidence, Confidence.high);
      expect(r.citations.single.documentId, 'KB-114');
    });
  });
}
