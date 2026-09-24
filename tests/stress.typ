#import "../report.typ": *
#show: experiment-report.with(
  college: "计算机科学与技术与人工智能交叉学科学院（长名称换行测试）",
  course: "计算机组成原理与可编程逻辑器件综合设计实验（长课程名称测试）",
  student-id: "20250923012345678901234567890123456789",
  name: "用于验证换行的较长姓名",
  class: "计算机科学与技术专业2025级实验教学班（长班级名称）",
  title: "移位电路、控制逻辑与数据通路的设计及验证——这是用于检查信息栏自动增高的超长实验题目",
  hours: 0,
  date: datetime(year: 2026, month: 9, day: 23),
)

#section("空内容")[]
#section("已经有冒号：")[短内容。]
#section("跨页长段落")[
  #([这是一个不分段的长段落，用于检查中文标点、行距和自动分页。逻辑左移最低位补零，逻辑右移最高位补零。] * 60)
]
#section("图片与跨页列表")[
  #image("../examples/assets/shift.svg", width: 60%)

  #enum(..range(30).map(i => [第 #(i + 1) 项：检查输入数据、控制信号、输出波形与预期结果，并记录分析。]))
]
#section("嵌套表格与公式")[
  $ Q = floor(D / 2) $

  #table(
    columns: (1fr, 2fr),
    table.header([序号], [测量记录]),
    ..range(45).map(i => ([#i], [数据记录：验证跨页表格中的边框与重复表头。])).flatten(),
  )
]
#section("末尾检查")[全文结束标记。]
