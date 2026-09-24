# sdu-co-report

山东大学计算机组成原理课程实验报告的非官方 Typst 模板。支持中文字体、可跨页分节、节内标题编号和三线表，无第三方 Typst 包依赖。

- 版本：`0.1.0`
- Typst：`0.15.0` 或更高；已在 `0.15.0` 验证
- 许可证：[MIT](LICENSE)
- 排版示例：[example.pdf](examples/example.pdf) · [example.typ](examples/example.typ)

## 方式一：手动放入本地包目录

将整个仓库复制到下列版本目录，确保 `typst.toml` 直接位于 `0.1.0` 内，不要多套一层仓库名：

| 系统 | 目录 |
| --- | --- |
| Windows | `%APPDATA%/typst/packages/local/sdu-co-report/0.1.0/` |
| macOS | `~/Library/Application Support/typst/packages/local/sdu-co-report/0.1.0/` |
| Linux | `~/.local/share/typst/packages/local/sdu-co-report/0.1.0/` |

Linux 设置了 `XDG_DATA_HOME` 时，用它替代 `~/.local/share`。本地目录规则见 [Typst 官方包说明](https://github.com/typst/packages#local-packages)。

复制后，在报告中导入：

```typst
#import "@local/sdu-co-report:0.1.0": *
```

也可以初始化一个新项目：

```sh
typst init @local/sdu-co-report:0.1.0 my-report
typst watch my-report/main.typ
```

## 方式二：直接导入文件

把 `report.typ` 复制到报告文件旁边，不需要安装包，也不需要 `typst.toml`：

```text
my-report/
├── report.typ
└── main.typ
```

在 `main.typ` 中使用：

```typst
#import "report.typ": *
```

也可把 `examples/example.typ`、`examples/assets/` 和根目录的 `report.typ` 复制到自己的报告目录，将示例第一行改为 `#import "report.typ": *`。分发模板副本时请一并保留 `LICENSE`。

## 编写报告

### 1. 新建 `main.typ`，复制下面的完整内容

下面是一份包含五个栏目、子标题、列表、公式和三线表的完整报告。把 `report.typ` 放在同一目录，安装所选中文字体后即可编译，不需要准备额外图片。

如果采用本地包方式，只把第一行改为 `#import "@local/sdu-co-report:0.1.0": *`，其余代码完全相同。

```typst
#import "report.typ": *

// 整篇报告只写一次：填写页头和信息栏，设置全局字体。
#show: experiment-report.with(
  college: "计算机科学与技术",
  course: "计算机组成原理",
  student-id: "2025...",
  name: "张三",
  class: "计科2025级1班",
  title: "移位电路实验",
  hours: 2,
  date: "2026-09-23",
  title-font: "Noto Sans SC",
  body-font: "Noto Serif SC",
  body-size: 12pt,
)

// section 的圆括号里是栏目名，方括号里是这一栏的全部正文。
#section("实验目的")[
  + 理解逻辑左移和逻辑右移的工作原理。
  + 掌握移位电路的设计与验证方法。
]

#section("实验软件和硬件环境")[
  *软件环境：*

  Vivado 软件、FPGA 实验平台。

  *硬件环境：*

  + 实验室台式机
  + PYNQ-Z2 开发板
]

#section("实验原理和方法（含有实验示意图）")[
  逻辑左移时最低位补零，逻辑右移时最高位补零。

  对无符号整数，逻辑右移一位的结果为：

  $ Q = floor(D / 2) $

  // 准备好图片后，取消下一行的注释，并替换图片路径。
  // #align(center)[#image("images/circuit.png", width: 60%)]
]

#section("实验步骤")[
  = 原理图输入

  建立工程，连接输入数据、控制信号和输出端口。

  这是另一个段落。段落之间留一个空行即可。

  = 仿真与验证

  + 设置输入数据和移位方向。
  + 运行仿真并记录结果。

  以下仅为预期结果示例，请补充实际测量结果：

  #three-line-table(
    header: ([操作], [输入], [预期输出]),
    columns: (1.2fr, 1fr, 1fr),
    [逻辑左移一位], [0010 1101], [0101 1010],
    [逻辑右移一位], [0010 1101], [0001 0110],
  )
]

#section("结论分析与体会")[
  = 结果分析

  在此填写实测结果与理论结果的比较。

  = 实验体会

  在此填写遇到的问题、解决方法及体会。
]
```

### 2. 修改自己的信息与正文

- `#import` 导入模板函数；`#show: experiment-report.with(...)` 启用整篇报告的样式。两者放在文件最前面。
- `college`、`course`、`student-id` 等填写报告信息。字符串用双引号包围，参数之间用英文逗号分隔。
- 每个 `#section("栏目名")[ ... ]` 生成一个有边框的栏目。直接在方括号内写正文，不需要给正文加引号；可以增删栏目、改变顺序。
- `= 原理图输入` 是栏目内部的子标题，必须单独占一行。它显示为 **1. 原理图输入**，下一项显示 **2. 仿真与验证**；进入“结论分析与体会”后重新从 **1. 结果分析** 开始。
- 图片、表格、列表都写在对应 section 的方括号内。内容增长时自动跨页，不需要手动拆成多个 section。
- 以 `//` 开头的内容是注释，不会出现在报告里。示例中的图片调用被注释，所以没有图片文件也能编译。

### 3. 编译或实时预览

在 `main.typ` 所在目录打开终端：

```sh
# 生成同目录下的 main.pdf
typst compile main.typ main.pdf

# 修改 main.typ 后自动更新 main.pdf（按 Ctrl+C 停止）
typst watch main.typ main.pdf
```

## 字体与配置

请先安装 [Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC) 和 [Noto Serif SC](https://fonts.google.com/noto/specimen/Noto+Serif+SC)，或传入本机已有的中文字体。使用 `typst fonts` 查看可用字体族名称。字体不随本仓库分发。

| 参数 | 默认值 | 用途 |
| --- | --- | --- |
| `university` | `"山东大学"` | 页头学校名称 |
| `college`, `course` | `""` | 学院、课程 |
| `student-id`, `name`, `class` | `""` | 学号、姓名、班级 |
| `title`, `hours`, `date` | `""` | 实验题目、学时、日期 |
| `title-font` | `"Noto Sans SC"` | 页头、信息栏标签、section 标题、原生 heading |
| `body-font` | `"Noto Serif SC"` | section 正文和信息栏填写值 |
| `body-size` | `12pt` | 正文与节内子标题字号 |

信息字段可留空或传 `none`；学时支持数字（包括 `0`），日期支持字符串或 `datetime(year: 2026, month: 9, day: 23)`。学号请传字符串以保留前导零。代码使用等宽字体，公式使用数学字体，图片内的文字不受字体参数影响。

## 分节与分页

`#section("名称")[正文]` 自动补一个中文冒号。正文支持段落、列表、公式、图片和表格，可连续跨多页，每页边框闭合。空节合法。

- `= 子标题` 自动显示 `1.`、`2.` 等编号；每个 section 从 `1.` 重新开始，同一节跨页继续递增。字号不放大，只加粗并使用标题字体。
- `+ 项目` 是自动编号列表；`1. 项目` 是普通文字。段落间留空行，粗体用 `*文字*`。
- A4、四边 20 mm 页边距、15 pt 双行页头、0.5 pt 分节边框，不添加页码。
- 长信息字段自动换行；连续长英文数字可插入零宽断行机会，复制 PDF 时可能带有零宽空格。
- 图片按指定宽度显示；超出栏宽或高于 230 mm 时等比缩小。图片自身不分页，居中可用 `align(center)`，图注可用 `figure`。
- 超长代码行、超宽公式、用户指定的不可分页容器仍需自行断行或缩放。不要用不可分页的容器包住整节，也不要在 section 内使用 `pagebreak()`。

## 三线表

只保留顶线、表头下横线和底线，无竖线与数据行分隔线。表头加粗、字体继承正文，跨页重复表头及其上下横线，底线只出现在全表末尾。

```typst
#three-line-table(
  header: ([操作], [输入], [预期输出]),
  columns: (1.2fr, 1fr, 1fr),
  [逻辑左移一位], [0010 1101], [0101 1010],
  [逻辑右移一位], [0010 1101], [0001 0110],
)
```

表头和正文支持内容块、字符串、数字、`none` 和日期。省略 `columns` 时按表头数量等宽分列；正文单元格按行传入，数量须为列数的整数倍。不支持跨行、跨列单元格。

可选参数：`align: center`、`inset: (x: 6pt, y: 5pt)`、`outer-stroke: 0.8pt`、`inner-stroke: 0.4pt`。

## 仓库结构与开发

```text
typst.toml             包信息与初始化模板声明
report.typ             包入口与排版函数
template/
└── main.typ           typst init 的起始报告
examples/
├── example.typ        完整示例源码
├── example.pdf        示例预览
└── assets/
    └── shift.svg      示例插图
tests/                 回归样例与验证脚本
```

在仓库根目录执行下面的命令，无需先安装包。`--root .` 允许示例导入上一层的 `report.typ`：

```sh
typst compile --root . examples/example.typ examples/example.pdf
```

开发验证需要 Python 3.11+ 与上述中文字体：

```sh
python -m pip install typst==0.15.0 PyMuPDF==1.28.2
python tests/verify.py
```

验证涵盖手动复制后的本地包导入、直接文件导入、初始化模板、长内容分页、节内编号、三线表数字单元格与重复表头。检查输出放在 `.qa/`，不提交到 Git。更新样式后还应逐页查看生成的 PDF / PNG。

版本升级时同步修改 `typst.toml`、`template/main.typ` 和 README 中的包版本，并记录在 [CHANGELOG.md](CHANGELOG.md)。