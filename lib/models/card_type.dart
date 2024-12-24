enum CardType {
  Table,
  Chart,
  Metrics,
  Form,
  Custom,
  Placeholder,
}

extension CardTypeExtension on CardType {
  String toJson() => toString().split('.').last;
  String toLowerCase() => toJson().toLowerCase();
}
