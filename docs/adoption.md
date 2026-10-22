# 迁移与改造

## 1. 搬进已有项目

### 方式 A：只搬类文件（最省事，推荐）

```
my-project/
├── report.tex              ← 从 starter/report.tex 抄
├── boogonreport.cls        ← 复制这一个文件
├── sections/
├── figures/
└── refs.bib
```

`report.tex` 里 `\documentclass[logo]{boogonreport}` 即可，其余照常。

### 方式 B：整个工具包放进子目录

```
my-project/
├── techreport/
│   ├── boogonreport.cls
│   └── ...
└── report.tex
```

```latex
\documentclass{techreport/boogonreport}
\input{techreport/sections/01-introduction}
```

`\documentclass` 与 `\input` 都接受相对路径。已在本机与 CI 上验证。

### 方式 C：环境变量

不想改任何路径时：

```powershell
$env:TEXINPUTS = ".\techreport;" + $env:TEXINPUTS
```

然后 `\documentclass{boogonreport}` 就能找到类文件。

## 2. 换颜色与字体

**强调色**：类里用 `bgbrand` / `bgbranddeep`（默认取自 Boogon 站点的品牌蓝）。
在导言区覆盖即可：

```latex
\definecolor{bgbrand}{HTML}{0F766E}
\definecolor{bgbranddeep}{HTML}{115E59}
```

颜色定义在类之后加载也没问题，`\hypersetup` 会在 `\begin{document}` 时重新读取。

**Times 字体**：

```latex
\documentclass[logo, times]{boogonreport}
```

**换其他字体**：在导言区覆盖 `\setmainfont`（XeLaTeX）或 `\rmdefault`（pdfLaTeX）。
注意数学字体是 `mathpazo` / `newtxmath`，换正文时最好一起换，否则数学与正文会不一致。

## 3. 加定理环境

类里没有内置定理环境，按需加载：

```latex
\usepackage{amsthm}
\newtheorem{proposition}{命题}
```

算法伪代码：

```latex
\usepackage{algorithm}
\usepackage{algpseudocode}
```

## 4. 改成会议模板

投稿 NeurIPS / ICLR / ACL 时，用官方 `.sty`，正文几乎不用改：
`\section`、`table`、`figure`、`\citep` 语法全部通用。会丢掉的：品牌带、竖线图注、
页脚报告编号、`\reportsetup`。把需要保留的定义拷进新导言区即可。

**不要**把官方 `.sty` 打包进本工具包再发布：再分发涉及许可问题。

## 5. 常见改造

**加封面页**：在 `\maketitle` 前插一页 `\thispagestyle{empty}` 的 `titlepage`。

**去掉目录**：删掉 `\tableofcontents` 与它前后的 `\newpage`。

**图注改冒号**：`\captionsetup{labelsep=colon}`。

**表格跨页**：`\usepackage{longtable}`，用 `longtable` 环境替代 `table`。

**缩进式段落**（中文论文常见）：导言区

```latex
\setlength{\parindent}{2em}
\setlength{\parskip}{0pt}
```

**中文段落间距太大**：`\setlength{\parskip}{0.3\baselineskip}`。

## 6. 排错

| 现象 | 原因 | 处理 |
|---|---|---|
| `File 'boogonreport.cls' not found` | 类文件不在搜索路径 | 用方式 A/B/C 之一 |
| `Chinese reports must be compiled with XeLaTeX` | 中文用了 pdfLaTeX | 改用 `xelatex` |
| `Missing character: There is no ≥` | 字体不含该字符 | 用 `$\geq$`，或换 `fandol` 以外的字体集 |
| `File 'ctex-fontset-xxx.def' not found` | 字体集不可用 | 改 `fandol`（最稳） |
| 中文 PDF 里文字不能复制 | Fandol 字体集无 ToUnicode | 改 `winfonts` / `macfonts` |
| 参考文献显示 `?` | 没跑 bibtex，或 `.bbl` 缺失 | 用 `build.ps1` 重跑；arXiv 记得传 `.bbl` |
