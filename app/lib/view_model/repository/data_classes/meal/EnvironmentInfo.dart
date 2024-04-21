class EnvironmentInfo {
  final int _averageRating;
  final int _co2Rating;
  final int _co2Value;
  final int _waterRating;
  final int _waterValue;
  final int _animalWelfareRating;
  final int _rainforestRating;
  final int _maxRating;

  EnvironmentInfo(
      {required int averageRating,
      required int co2Rating,
      required int co2Value,
      required int waterRating,
      required int waterValue,
      required int animalWelfareRating,
      required int rainforestRating,
      required int maxRating})
      : _averageRating = averageRating,
        _co2Rating = co2Rating,
        _co2Value = co2Value,
        _waterRating = waterRating,
        _waterValue = waterValue,
        _animalWelfareRating = animalWelfareRating,
        _rainforestRating = rainforestRating,
        _maxRating = maxRating;

  EnvironmentInfo.copy(
      {required EnvironmentInfo environmentInfo,
      int? averageRating,
      int? co2Rating,
      int? co2Value,
      int? waterRating,
      int? waterValue,
      int? animalWelfareRating,
      int? rainforestRating,
      int? maxRating})
      : _averageRating = averageRating ?? environmentInfo._averageRating,
        _co2Rating = co2Rating ?? environmentInfo._co2Rating,
        _co2Value = co2Value ?? environmentInfo._co2Value,
        _waterRating = waterRating ?? environmentInfo._waterRating,
        _waterValue = waterValue ?? environmentInfo._waterValue,
        _animalWelfareRating =
            animalWelfareRating ?? environmentInfo._animalWelfareRating,
        _rainforestRating =
            rainforestRating ?? environmentInfo._rainforestRating,
        _maxRating = maxRating ?? environmentInfo._maxRating;

  int get averageRating => _averageRating;

  int get co2Rating => _co2Rating;

  int get co2Value => _co2Value;

  int get waterRating => _waterRating;

  int get waterValue => _waterValue;

  int get animalWelfareRating => _animalWelfareRating;

  int get rainforestRating => _rainforestRating;

  int get maxRating => _maxRating;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentInfo &&
          runtimeType == other.runtimeType &&
          _averageRating == other._averageRating &&
          _co2Rating == other._co2Rating &&
          _co2Value == other._co2Value &&
          _waterRating == other._waterRating &&
          _waterValue == other._waterValue &&
          _animalWelfareRating == other._animalWelfareRating &&
          _rainforestRating == other._rainforestRating &&
          _maxRating == other._maxRating;

  @override
  int get hashCode =>
      _averageRating.hashCode ^
      _co2Rating.hashCode ^
      _co2Value.hashCode ^
      _waterRating.hashCode ^
      _waterValue.hashCode ^
      _animalWelfareRating.hashCode ^
      _rainforestRating.hashCode ^
      _maxRating.hashCode;
}
