part of modern_form_date_range;

class DateRange {
  static const String _value = "value";
  static const String _type = "type";
  static const int _numberOfDaysOfTheWeek = 7;
  static DateTimeRange get _dateTimeRangeDefault {
    DateTime now = DateTime.now();
    DateTime start = now.subtract(const Duration(days: 30));
    return DateTimeRange(start: start, end: now);
  }

  DateRangeType? type;
  dynamic value;

  DateTimeRange get dateTimeRange {
    DateTime now = DateTime.now();

    switch (type) {
      case DateRangeType.dateTimeRange:
        return value ?? _dateTimeRangeDefault;
      case DateRangeType.days:
        DateTime start = now.subtract(Duration(days: value ?? 0));
        return DateTimeRange(start: start, end: now);
      case DateRangeType.weeks:
        final int nowWeekday = now.weekday;

        //days that must be subtracted to get to the 1st of the week (sunday)
        final int daysForSubtractForWeekday1 =
            nowWeekday == 7 ? 0 : (nowWeekday);
        DateTime nowWithWeekday1 =
            now.subtract(Duration(days: daysForSubtractForWeekday1));

        final int _value = ((value as int?) ?? 1);
        final int daysForSubtract =
            (_value == 0 ? 0 : (_value - 1)) * _numberOfDaysOfTheWeek;
        DateTime start =
            nowWithWeekday1.subtract(Duration(days: daysForSubtract));

        return DateTimeRange(start: start, end: now);
      case DateRangeType.months:
        final int _value = ((value as int?) ?? 1);
        int newMonth =
            (_value == 0 || _value == 1) ? now.month : now.month - (_value - 1);

        DateTime start = DateTime(now.year, newMonth, 1);
        return DateTimeRange(start: start, end: now);
      default:
        return _dateTimeRangeDefault;
    }
  }

  DateRange({
    this.value,
    this.type,
  });

  DateRange copyWith({
    DateRangeType? type,
    dynamic value,
  }) {
    return DateRange(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  DateRange copyWithRemoveValue() => DateRange(type: type, value: null);

  Map<String, dynamic> toMap() {
    return {
      _type: type?.toValueString,
      _value: value is DateTimeRange ? (value as DateTimeRange).toMap() : value,
    };
  }

  DateRange.fromMap(Map<String, dynamic> map) {
    type = map[_type].toString().toDateRangeType;

    try {
      dynamic mapValue = map[_value];
      if (mapValue != null) {
        if (type == DateRangeType.dateTimeRange) {
          value = ModernFormDateTimeRangeExtension.fromMap(mapValue);
        } else if (mapValue is num) {
          value = mapValue.toInt();
        }
      } else if (type.isDurationType) {
        value = 1;
      }
    } catch (e, s) {
      developer.log(
        "ERROR DateRange.fromMap($map) --> $e",
        error: e,
        stackTrace: s,
      );
    }
  }

  String toJson() => json.encode(toMap());

  factory DateRange.fromJson(String source) =>
      DateRange.fromMap(json.decode(source));

  @override
  String toString() => 'DateRange(type: $type, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DateRange && other.value == value && other.type == type;
  }

  @override
  int get hashCode => value.hashCode ^ type.hashCode;
}
