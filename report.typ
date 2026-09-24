// 山东大学计算机组成原理课程实验报告。无需第三方 Typst 包。
// Word 参考：A4、20 mm 页边距、15 pt 抬头、12 pt 黑体、0.5 pt 表格线。

// 在报告调用处统一配置；context 按 section 所在位置读取当前报告的字体。
#let report-fonts = state("experiment-report-fonts", (
  title: "Noto Sans SC", body: "Noto Serif SC",
))

#let field-value(value) = {
  if value == none { [] }
  else if type(value) == datetime { value.display("[year]-[month]-[day]") }
  else if type(value) == str or type(value) == content { value }
  else { str(value) }
}

// 三线表：顶线、表头下横线、底线；无竖线和数据行分隔线。
// header 是单行表头数组，后面的单元格按行传入；长表自动重复表头。
#let three-line-table(
  header: (), columns: auto,
  align: center, inset: (x: 6pt, y: 5pt),
  outer-stroke: 0.8pt, inner-stroke: 0.4pt,
  ..cells,
) = {
  assert(header.len() > 0, message: "three-line-table 的 header 不能为空")
  let columns = if columns == auto { (1fr,) * header.len() } else { columns }
  let count = if type(columns) == int { columns } else { columns.len() }
  assert(count == header.len(), message: "列数必须与 header 的单元格数一致")
  assert(cells.named().len() == 0, message: "three-line-table 收到了未知参数")
  assert(calc.rem(cells.pos().len(), count) == 0,
    message: "正文单元格数量必须是列数的整数倍")
  set par(first-line-indent: 0pt, justify: false)
  table(
    columns: columns, align: align, inset: inset, stroke: none,
    table.header(
      repeat: true,
      table.hline(stroke: outer-stroke),
      ..header.map(cell => strong(field-value(cell))),
      table.hline(stroke: inner-stroke),
    ),
    ..cells.pos().map(field-value),
    table.hline(stroke: outer-stroke),
  )
}

// 只在信息栏为长英文标识符提供断行机会，不改动正文/代码的内容。
#let field(label, value) = context{
  let fonts = report-fonts.get()
  set par(first-line-indent: 0pt, justify: false)
  show regex("[A-Za-z0-9_./-]{18,}"): it => it.text.clusters().join("\u{200b}")
  [#set text(font:fonts.title)
    *#label*
  #set text(font:fonts.body)
  #field-value(value)]
}

// 每节是可分页的带边框块；零段间距让相邻边框重合为一条细线。
// sticky 仅用于标题，绝不把整节锁在一页内。
#let section(title, body) = context {
  let fonts = report-fonts.get()
  block(
  width: 100%, breakable: true, above: 0pt, below: 0pt,
  stroke: 0.5pt + black,
  inset: (x: 10pt, y: 10pt),
)[
  #block(sticky: true, above: 0pt, below: 7pt)[
    #set text(font: fonts.title)
    #set par(first-line-indent: 0pt)
    #if type(title) == str {
      text(
        weight: "bold",
        title.trim(regex("[：: ]+$")) + "：")
    } else { [*#title：*] }
  ]
  #counter(heading).update(0)
  #text(font: fonts.body, body)
]
}

#let experiment-report(
  college: "计算机科学与技术", course: "计算机组成原理", student-id: "", name: "", class: "",
  title: "", hours: "", date: "",
  university: "山东大学",
  title-font: "Noto Sans SC",
  body-font: "Noto Serif SC",
  body-size: 12pt,
  body,
) = {
  set document(
    title: if type(title) == str { title } else { none },
    author: if type(name) == str { name } else { () },
  )
  set page(paper: "a4", margin: 20mm, numbering: none)
  report-fonts.update((title: title-font, body: body-font))
  set text(font: title-font, size: body-size, lang: "zh", region: "CN", fill: black,
    top-edge: 0.88em, bottom-edge: 0.12em)
  set par(justify: true, first-line-indent: 0pt, leading: 5.4pt, spacing: 10pt)
  set list(indent: 0pt, body-indent: 0.5em, spacing: 5.4pt)
  set enum(indent: 0pt, body-indent: 0.5em, spacing: 5.4pt)
  set heading(numbering: "1.")
  show heading: set text(font: title-font, size: body-size, weight: "bold")
  show raw: set text(font: ("Consolas",) + if type(body-font) == str { (body-font,) } else { body-font }, size: 10pt)
  // 单张图不能分页：按当前栏宽及一页可用高度等比缩小，避免超高图溢出。
  // 图片作为独立块排版；仍可在外层用 align 控制对齐。
  show image: it => layout(size => {
    let extent = measure(it, width: size.width, height: 100000pt)
    let ratio = calc.min(1, size.width / extent.width, 230mm / extent.height)
    // 固定测量时的容器宽度，避免相对宽度在缩放布局中再次解析。
    scale(x: ratio * 100%, y: ratio * 100%, reflow: true,
      box(width: size.width, height: extent.height, it))
  })

  // 栏宽随抬头宽度分配，长学院名称可增高而不挤压“学院”二字。
  block(width: 100%, above: 0pt, below: 15.6pt, breakable: false)[
    #set text(size: 15pt)
    #set par(justify: false, leading: 4pt, spacing: 4pt)
    #align(center)[
      #block(width: 80%, above: 0pt, below: 0pt)[#grid(
        columns: (auto, 1fr, auto), align: center + top,
        [#field-value(university)],
        block(width: 100%, inset: (x: 6pt, bottom: 3pt), stroke: (bottom: 0.5pt))[
          #field-value(college)
        ],
        [学院],
      )]
      #v(4pt)
      #underline(stroke: 0.5pt, offset: 3pt)[#field-value(course)#h(0.5em)]#box[课程实验报告]
    ]
  ]

  // 使用参考 DOCX 的四列网格以及原合并关系。
  block(width: 100%, above: 0pt, below: 0pt, breakable: true)[
    #set par(leading: 3.6pt, spacing: 0pt)
    #table(
      columns: (2698fr, 1500fr, 1271fr, 4159fr),
      inset: (x: 5pt, y: 5pt), stroke: 0.5pt,
      align: left + top,
      table.cell(field("学号：", student-id)),
      table.cell(colspan: 2, field("姓名：", name)),
      table.cell(field("班级：", class)),
      table.cell(colspan: 4, field("实验题目：", title)),
      table.cell(colspan: 2, field("实验学时：", hours)),
      table.cell(colspan: 2, field("实验日期：", date)),
    )
  ]
  body
}
