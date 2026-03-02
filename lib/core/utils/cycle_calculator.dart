import '../../models/cycle_model.dart';

class CycleCalculator {
  /// Default average cycle length is 28 days
  static const int defaultCycleLength = 28;

  /// Default luteal phase length (ovulation predictor) is usually 14 days
  static const int lutealPhaseLength = 14;

  /// Calculate average cycle length dynamically from stored cycles.
  static int calculateAverageCycleLength(List<CycleModel> cycles) {
    if (cycles.length < 2) return defaultCycleLength;

    var sortedCycles = List<CycleModel>.from(cycles);
    sortedCycles.sort((a, b) => a.startDate.compareTo(b.startDate));

    int totalDays = 0;
    for (int i = 0; i < sortedCycles.length - 1; i++) {
      totalDays += sortedCycles[i + 1].startDate
          .difference(sortedCycles[i].startDate)
          .inDays;
    }
    return (totalDays / (sortedCycles.length - 1)).round();
  }

  /// Predict the next period start date
  static DateTime predictNextPeriod(
    DateTime lastPeriodStart, {
    int? cycleLength,
  }) {
    return lastPeriodStart.add(
      Duration(days: cycleLength ?? defaultCycleLength),
    );
  }

  /// Predict the day of ovulation
  /// Typically happens 14 days BEFORE the next period starts
  static DateTime predictOvulation(DateTime periodStartDate, int cycleLength) {
    return periodStartDate.add(Duration(days: cycleLength - lutealPhaseLength));
  }

  /// Calculate the fertility window (typically 2 days before ovulation + 2 days after)
  static Map<String, DateTime> getFertilityWindow(DateTime ovulationDate) {
    return {
      'start': ovulationDate.subtract(const Duration(days: 2)),
      'end': ovulationDate.add(const Duration(days: 2)),
    };
  }
}
