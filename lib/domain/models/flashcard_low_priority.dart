import 'package:flashcards/domain/models/category.dart';

import 'fashcard.dart';

/// LowPriorityFlashcard is just like a normal Flashcard but in a state that its strength
/// cannot be increased for a certain duration, so the default behaviour to increase strength
/// is overridden.
class LowPriorityFlashcard extends Flashcard {

  LowPriorityInfo _lowPriorityInfo;

  LowPriorityInfo get lowPriorityInfo => _lowPriorityInfo;

  bool get isStillLowPriority {
    if (_lowPriorityInfo.enterDateTime.isAfter(DateTime.now())) {
      return false;
    }
    return !_lowPriorityInfo.isExpired;
  }

  int _lowPriorityStrength;

  int get lowPriorityStrength => _lowPriorityStrength;

  LowPriorityFlashcard({
    required Flashcard base,
    required LowPriorityInfo lowPriorityInfo,
    required int lowPriorityStrength
  }) : _lowPriorityInfo = lowPriorityInfo , _lowPriorityStrength = lowPriorityStrength, super(
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
      lowPriorityStrength: flashcard.strength,
      lowPriorityInfo: LowPriorityInfo(
        enterDateTime: DateTime.now(),
        duration: lowPriorityDuration
      )
    );
  }

  Flashcard toNonLowPriority() => super.copyWith();

  @override
  void increaseStrength() {
    if (_lowPriorityStrength < 5) {
      _lowPriorityStrength++;
    }
    if (isStillLowPriority) { return; }
    super.increaseStrength();
  }

  @override
  void decreaseStrength() {
    super.decreaseStrength();
    _lowPriorityStrength = strength;
  }

  @override
  Flashcard copyWith({int? id, String? term, String? definition, DateTime? lastSeenAt, int? strength, Category? category, LowPriorityInfo? lowPriorityInfo, int? lowPriorityStrength}) {
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
      lowPriorityStrength: lowPriorityStrength ?? _lowPriorityStrength,
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
