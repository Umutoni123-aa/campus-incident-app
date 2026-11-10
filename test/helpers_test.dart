import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/utils/helpers.dart';
import 'package:flutter_application_1/utils/validators.dart';

void main() {
  test('validates ALU email domains', () {
    expect(isAluEmail('student@alustudent.com'), isTrue);
    expect(isAluEmail('staff@alueducation.com'), isTrue);
    expect(isAluEmail('person@example.com'), isFalse);
  });

  test('displays Pending as Submitted', () {
    expect(displayStatus('Pending'), 'Submitted');
    expect(displayStatus('Resolved'), 'Resolved');
  });

  test('formats time ago', () {
    final now = DateTime(2026, 11, 10, 12);
    expect(timeAgo(null, now: now), 'Just now');
    expect(timeAgo(DateTime(2026, 11, 10, 10), now: now), '2 hours ago');
  });

  test('extracts first name and initials', () {
    expect(firstName('  Ada Lovelace '), 'Ada');
    expect(initials('Ada Lovelace'), 'AL');
    expect(initials(''), '');
  });
}
