# 快速开始

十分钟做出一份能发出去的 PDF。

## 1. 确认环境

需要 TeX Live 2022+ 或 MiKTeX（完整安装，含 ctex、pgfplots、booktabs）。

```powershell
pdflatex --version
xelatex --version     # 中文报告需要
latexmk --version
```

`build.ps1` 会自己找 TeX Live（`D:\texlive\2026`、`C:\texlive\2026` 等常见位置），
找不到时用 `-TeXBin` 指定：

```powershell
.\build.ps1 -TeXBin "D:\texlive\2026\bin\windows"
```

## 2. 构建示例

```powershell
.\build.cmd
```

看到类似输出就成功了：

```
[build] main-en (pdflatex)
[ok] main-en.pdf  155 KB / 8 pages
[build] main-zh (xelatex)
[ok] main-zh.pdf  197 KB / 7 pages
```

中文那份必须用 XeLaTeX。用 pdfLaTeX 编译 `main-zh.tex` 会得到一条明确的报错，
这是故意的：缺字的 PDF 比报错更难发现。

## 3. 换成你自己的内容

复制 `starter/` 到一个新目录，再把 `boogonreport.cls` 一起复制过去：

```
my-report/
├── boogonreport.cls
├── report.tex
├── sections/
│   ├── 01-introduction.tex
│   ├── 02-method.tex
│   └── 03-results.tex
└── refs.bib
```

改三处：

1. `report.tex` 顶部的 `\reportsetup{...}`：标题、作者、编号、版本、日期。
2. `sections/` 里 `\todo{}` 标出的位置。
3. `refs.bib`：加你的参考文献，正文用 `\citep{}` / `\citet{}`。

然后：

```powershell
latexmk -pdf report.tex        # 英文
latexmk -xelatex report.tex    # 中文
```

## 4. 草稿模式

定稿前打开 `draft`，所有 `\todo{}` 与 `\fixme{}` 会显形，并自动加行号：

```latex
\documentclass[logo, draft]{boogonreport}
```

`\todo{}` 是行内红色标记，`\fixme{}` 是页边批注。两者在非 draft 模式下**完全不
输出**——所以定稿前务必在 draft 模式下过一遍，否则它们会静默消失。

## 5. 发布

按 [release-checklist.md](release-checklist.md) 走一遍：数字可复现、产物链接、
License、Limitations、算力披露。CI 会替你验证「换一台机器能编译」，但排版是否好看
仍然需要人眼看。
