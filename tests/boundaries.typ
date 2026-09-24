#import "../report.typ": *
#show: experiment-report.with(title: "分页边界检查", name: none)

#section("第一节")[
  // 留下只能容纳下一节标题、无法容纳标题及正文的空间。
  #block(height: 201mm)[页底边界前的内容。]
]
#section("不得落单的标题")[
  标题后的第一段应与标题出现在同一页。
]
#section("超高图片")[
  #image(bytes("<svg xmlns='http://www.w3.org/2000/svg' width='100' height='1600'><rect x='2' y='2' width='96' height='1596' fill='white' stroke='black' stroke-width='4'/><path d='M2 2L98 1598M98 2L2 1598' stroke='black'/></svg>"), format: "svg", width: 60%)

  超高图片后的内容应完整保留。
]
#section("富文本标题与代码")[
  ```verilog
  assign q = dir ? (d >> 1) : (d << 1);
  ```

  $ Q = D times 2 $
]
#section([*强调*标题])[
  最终边界标记。
]

