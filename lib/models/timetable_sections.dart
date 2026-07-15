class TimetableSectionDefinition {
  const TimetableSectionDefinition({
    required this.order,
    required this.id,
    required this.shortLabel,
    required this.startTime,
    required this.endTime,
  });

  final int order;
  final String id;
  final String shortLabel;
  final String startTime;
  final String endTime;

  int get startMinutes => _parseClockMinutes(startTime);
  int get endMinutes => _parseClockMinutes(endTime);
}

class TimetableSections {
  const TimetableSections._();

  static const all = <TimetableSectionDefinition>[
    TimetableSectionDefinition(
      order: 0,
      id: '第1节',
      shortLabel: '1',
      startTime: '08:30',
      endTime: '09:15',
    ),
    TimetableSectionDefinition(
      order: 1,
      id: '第2节',
      shortLabel: '2',
      startTime: '09:25',
      endTime: '10:10',
    ),
    TimetableSectionDefinition(
      order: 2,
      id: '第3节',
      shortLabel: '3',
      startTime: '10:30',
      endTime: '11:15',
    ),
    TimetableSectionDefinition(
      order: 3,
      id: '第4节',
      shortLabel: '4',
      startTime: '11:25',
      endTime: '12:10',
    ),
    TimetableSectionDefinition(
      order: 4,
      id: '中午1节',
      shortLabel: '午1',
      startTime: '12:20',
      endTime: '13:15',
    ),
    TimetableSectionDefinition(
      order: 5,
      id: '中午2节',
      shortLabel: '午2',
      startTime: '13:25',
      endTime: '14:20',
    ),
    TimetableSectionDefinition(
      order: 6,
      id: '第5节',
      shortLabel: '5',
      startTime: '14:30',
      endTime: '15:15',
    ),
    TimetableSectionDefinition(
      order: 7,
      id: '第6节',
      shortLabel: '6',
      startTime: '15:25',
      endTime: '16:10',
    ),
    TimetableSectionDefinition(
      order: 8,
      id: '第7节',
      shortLabel: '7',
      startTime: '16:30',
      endTime: '17:15',
    ),
    TimetableSectionDefinition(
      order: 9,
      id: '第8节',
      shortLabel: '8',
      startTime: '17:25',
      endTime: '18:10',
    ),
    TimetableSectionDefinition(
      order: 10,
      id: '第9节',
      shortLabel: '9',
      startTime: '19:00',
      endTime: '19:45',
    ),
    TimetableSectionDefinition(
      order: 11,
      id: '第10节',
      shortLabel: '10',
      startTime: '19:55',
      endTime: '20:40',
    ),
    TimetableSectionDefinition(
      order: 12,
      id: '第11节',
      shortLabel: '11',
      startTime: '20:50',
      endTime: '21:35',
    ),
    TimetableSectionDefinition(
      order: 13,
      id: '第12节',
      shortLabel: '12',
      startTime: '21:45',
      endTime: '22:30',
    ),
  ];

  static TimetableSectionDefinition byOrder(int order) {
    if (order < 0 || order >= all.length) {
      throw RangeError.range(order, 0, all.length - 1, 'order');
    }
    return all[order];
  }

  static TimetableSectionDefinition byId(String id) =>
      all.firstWhere((section) => section.id == id);

  static int orderOf(String id) => byId(id).order;

  static List<String> idsInRange(int start, int end) => [
    for (var order = start; order <= end; order++) byOrder(order).id,
  ];
}

int _parseClockMinutes(String value) {
  final parts = value.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
