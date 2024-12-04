import 'dart:math';

import 'package:board_datetime_picker/src/utils/board_enum.dart';
import 'package:board_datetime_picker/src/utils/datetime_util.dart';

import '../ui/parts/focus_node.dart';
import 'board_item_option.dart';

/// Options for customizing the items displayed in the picker.
/// Create at each date and time.
class BoardPickerCustomItemOption extends BoardPickerItemOption {
  BoardPickerCustomItemOption(
      {required super.type,
      required this.customList,
      required super.focusNode,
      required super.map,
      required super.selectedIndex,
      required super.minimumDate,
      required super.maximumDate,
      required super.subTitle,
      required super.withSecond,
      required super.withEvery15Minutes});

  final List<int> customList;

  factory BoardPickerCustomItemOption.init(
    DateType type,
    List<int> customList,
    DateTime date,
    DateTime? minimum,
    DateTime? maximum,
    String? subTitle, {
    bool withSecond = false,
    bool withEvery15Minutes = false,
  }) {
    Map<int, int> map = {};
    int selected;

    // Define specified minimum and maximum dates
    final mi = minimum ?? DateTimeUtil.defaultMinDate;
    final ma = maximum ?? DateTimeUtil.defaultMaxDate;

    if (type == DateType.year) {
      final list =
          customList.where((x) => x >= mi.year && x <= ma.year).toList();
      for (var i = 0; i < list.length; i++) {
        map[i] = list[i];
      }
    } else {
      final m = BoardPickerItemOption.minmaxList(type, date, mi, ma);
      final values = m.values.toList();
      int count = 0;
      for (var i = 0; i < values.length; i++) {
        final val = values[i];
        for (var start in customList) {
          // Define the end of the interval
          int end = start + 15;

          // Check if valu falls within the current interval
          if (val >= start && val < end && !map.values.contains(end)) {
            if (val >= 45 && val < 60) {
              map[count] =
                  customList[0]; // Assign value to the map at index count
            } else {
              map[count] = end; // Assign value to the map at index count
            }
            count++; // Increment the count
            break; // Exit the loop as we found the value
          }
        }
      }
    }

    switch (type) {
      case DateType.year:
        final minY = minimum?.year ?? DateTimeUtil.minimumYear;
        selected = BoardPickerItemOption.indexFromValue(
          max(date.year, minY),
          map,
        );
        break;
      case DateType.month:
        selected = BoardPickerItemOption.indexFromValue(date.month, map);
        break;
      case DateType.day:
        selected = BoardPickerItemOption.indexFromValue(date.day, map);
        break;
      case DateType.hour:
        selected = BoardPickerItemOption.indexFromValue(date.hour, map);
        break;
      case DateType.minute:
        selected = BoardPickerItemOption.indexFromValue(date.minute, map);
        break;
      case DateType.second:
        selected = BoardPickerItemOption.indexFromValue(date.second, map);
        break;
    }

    return BoardPickerCustomItemOption(
        type: type,
        focusNode: PickerItemFocusNode(),
        map: map,
        selectedIndex: selected,
        minimumDate: mi,
        maximumDate: ma,
        customList: customList,
        subTitle: subTitle,
        withSecond: withSecond,
        withEvery15Minutes: withEvery15Minutes);
  }

  @override
  void updateList(DateTime date) {
    //  Retrieve existing values
    final tmp = value;
    // Generate new maps
    final m = BoardPickerItemOption.minmaxList(
      type,
      date,
      minimumDate,
      maximumDate,
    );
    final values = m.values.toList();

    Map<int, int> newMap = {};

    int count = 0;
    for (var i = 0; i < values.length; i++) {
      final val = values[i];
      for (var start in customList) {
        // Define the end of the interval
        int end = start + 15;

        // Check if valu falls within the current interval
        if (val >= start && val < end && !newMap.values.contains(start)) {
          newMap[count] = start; // Assign valu to the map at index count
          count++; // Increment the count
          break; // Exit the loop as we found the value
        }
      }
    }
    map = newMap;
    updateState(tmp, date);
  }

  @override
  void updateDayMap(int maxDay, DateTime newDate) {
    int minDay = 1;
    int maxDay = 31;
    if (newDate.isMinimum(minimumDate, DateType.month)) {
      minDay = minimumDate.day;
    }
    if (newDate.isMaximum(maximumDate, DateType.month)) {
      maxDay = min(maxDay, maximumDate.day);
    } else {
      // 指定の月の中で最大の日付を設定する
      int year = newDate.year;
      int month = newDate.month;
      if (month == 12) {
        year += 1;
        month = 1;
      } else {
        month += 1;
      }
      maxDay = DateTime(year, month, 1).add(const Duration(days: -1)).day;
    }

    //  Retrieve existing values
    final tmp = value;

    Map<int, int> newMap = {};
    int index = 0;
    for (var i = minDay; i <= maxDay; i++) {
      for (var start in customList) {
        // Define the end of the interval
        int end = start + 15;

        // Check if valu falls within the current interval
        if (i >= start && i < end && !newMap.values.contains(start)) {
          newMap[index] = start; // Assign valu to the map at index count
          index++; // Increment the count
          break; // Exit the loop as we found the value
        }
      }
    }
    map = newMap;
    updateState(tmp, newDate);
  }
}
