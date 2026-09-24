#import "../report.typ": three-line-table
#set text(font: "Noto Serif SC")

// 数字表头、整数、小数、空单元格与日期。
#three-line-table(
  header: (1, 2, 3),
  0, -2, 3.5,
  "文字", [*强调*], none,
  datetime(year: 2026, month: 9, day: 24), 10, 20,
)

// 长表需要分页，每页都应重复表头。
#three-line-table(
  header: ([序号], [测量值]),
  ..range(100).map(i => (i, i * 2)).flatten(),
)
