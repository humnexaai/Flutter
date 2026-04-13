enum SheetType {
  fourBySix(
    label: "4x6 inch",
    copiesPerPage: 8,
    widthInch: 6,
    heightInch: 4,
  ),
  a4(
    label: "A4",
    copiesPerPage: 32,
    widthInch: 8.27,
    heightInch: 11.69,
  );

  const SheetType({
    required this.label,
    required this.copiesPerPage,
    required this.widthInch,
    required this.heightInch,
  });

  final String label;
  final int copiesPerPage;
  final double widthInch;
  final double heightInch;

  int get columns => this == SheetType.a4 ? 4 : 2;
  int get rows => copiesPerPage ~/ columns;
}
