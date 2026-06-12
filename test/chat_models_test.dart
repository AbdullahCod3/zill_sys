import 'package:flutter_test/flutter_test.dart';
import 'package:zill_sys/models/chat_message.dart';
import 'package:zill_sys/models/chat_model.dart';

void main() {
  group('Chat models snake_case ⇄ camelCase boundary', () {
    test('ChatModel round-trips storage fields', () {
      final c = ChatModel.fromJson(const {
        'chat_id': 'ch_1',
        'agent_id': 'a_1',
        'customer_id': 'c_1',
        'status': 'active',
        'resolved': false,
        'started_at': '2026-06-12T09:00:00.000Z',
      });
      expect(c.chatId, 'ch_1');
      expect(c.agentId, 'a_1');
      expect(c.customerId, 'c_1');
      expect(c.isActive, isTrue);
      expect(c.startedAt, isNotNull);

      final j = c.toJson();
      expect(j['agent_id'], 'a_1');
      expect(j['customer_id'], 'c_1');
      expect(j['status'], 'active');
      expect(j.containsKey('chat_id'), isFalse); // doc id is the path, not a field
      expect(j.containsKey('language'), isFalse);
    });

    test('ChatModel.copyWith flips status and stamps endedAt', () {
      final base = ChatModel(
        chatId: 'ch_1',
        customerId: 'c_1',
        startedAt: DateTime.utc(2026, 6, 12, 9),
      );
      final ended = base.copyWith(
        status: 'ended',
        resolved: true,
        endedAt: DateTime.utc(2026, 6, 12, 9, 15),
      );
      expect(ended.isEnded, isTrue);
      expect(ended.resolved, isTrue);
      expect(ended.toJson()['ended_at'], '2026-06-12T09:15:00.000Z');
    });

    test('ChatMessage maps sender / text / sent_at', () {
      final m = ChatMessage.fromJson(const {
        'sender': 'customer',
        'text': 'My internet is down',
        'sent_at': '2026-06-12T09:01:00.000Z',
      }, id: 'msg_1');
      expect(m.messageId, 'msg_1');
      expect(m.isCustomer, isTrue);
      expect(m.isAgent, isFalse);
      expect(m.text, 'My internet is down');
      expect(m.sentAt, DateTime.utc(2026, 6, 12, 9, 1));

      final j = m.toJson();
      expect(j['sender'], 'customer');
      expect(j['text'], 'My internet is down');
      expect(j['sent_at'], '2026-06-12T09:01:00.000Z');
      expect(j.containsKey('message_id'), isFalse);
    });
  });
}
