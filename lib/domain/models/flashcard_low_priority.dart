import 'package:flashcards/domain/models/category.dart';

import 'fashcard.dart';

class LowPriorityFlashcard extends Flashcard {
  LowPriorityInfo _lowPriorityInfo;
  LowPriorityInfo get lowPriorityInfo => _lowPriorityInfo;
  bool get isStillLowPriority {
    if (_lowPriorityInfo.enterDateTime.isAfter(DateTime.now())) {
      return false;
    }
    return !_lowPriorityInfo.isExpired;
  }

  LowPriorityFlashcard({
    required Flashcard base,
    required LowPriorityInfo lowPriorityInfo
  }) : _lowPriorityInfo = lowPriorityInfo , super(
    definition: base.definition,
    lastSeenAt: base.lastSeenAt,
    strength: base.strength,
    term: base.term,
    category: base.category,
    id: base.id,
  );
  
  factory LowPriorityFlashcard.fromFlashcard(Flashcard flashcard, Duration lowPriorityDuration) {
    return LowPriorityFlashcard(
      base: flashcard,
      lowPriorityInfo: LowPriorityInfo(
        enterDateTime: DateTime.now(),
        duration: lowPriorityDuration
      )
    );
  }

  Flashcard toNonLowPriority() => super.copyWith();

  @override
  void increaseStrength() {
    if (isStillLowPriority) { return; }
    super.increaseStrength();
  }

  @override
  Flashcard copyWith({int? id, String? term, String? definition, DateTime? lastSeenAt, int? strength, Category? category, LowPriorityInfo? lowPriorityInfo}) {
    final base =  super.copyWith(
      id: id,
      term: term,
      definition: definition,
      lastSeenAt: lastSeenAt,
      strength: strength,
      category: category,
    );
    return LowPriorityFlashcard(
      base: base,
      lowPriorityInfo: lowPriorityInfo ?? _lowPriorityInfo
    );
  }
}

class LowPriorityInfo {
  DateTime _enterDateTime;
  Duration _duration;

  DateTime get enterDateTime => _enterDateTime;
  Duration get duration => _duration;

  LowPriorityInfo({
    required DateTime enterDateTime,
    required Duration duration,
  }) : _enterDateTime = enterDateTime, _duration = duration;

  bool get isExpired => expiresAt.isBefore(DateTime.now());
  DateTime get expiresAt => _enterDateTime.add(duration);
}
