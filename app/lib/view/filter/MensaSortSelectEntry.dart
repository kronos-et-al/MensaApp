/// This class represents a single entry in the sort select.
class MensaSortSelectEntry<T> {
  /// The value of the entry.
  final T value;

  /// The label of the entry.
  final String label;

  /// Creates a new sort select entry.
  /// @param value The value of the entry.
  /// @param label The label of the entry.
  /// @returns A new sort select entry.
  const MensaSortSelectEntry({required this.value, required this.label});
}
