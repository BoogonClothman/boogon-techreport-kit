# starter：空白骨架

复制这个目录到你的项目里，再把仓库根目录的 `boogonreport.cls` 一起复制过去，
就可以只关心内容了。

```
your-project/
├── boogonreport.cls      ← 从仓库根目录复制
├── report.tex            ← 这个目录的 report.tex
├── sections/             ← 这个目录的 sections/
├── refs.bib
└── figures/
```

改三处就能开工：

1. `report.tex` 顶部的 `\reportsetup{...}`：标题、作者、编号、版本、日期。
2. `sections/` 里的三个文件：`\todo{}` 标出的位置都要填。
3. `refs.bib`：把你的参考文献加进去。

构建：

```powershell
.\build.ps1 -Job starter     # 在本仓库里直接编（借用根目录的类文件）
latexmk -pdf report.tex      # 复制出去之后
```

`draft` 选项会让 `\todo{}` 与 `\fixme{}` 显示出来，定稿前用它查漏：

```powershell
xelatex "\documentclass[logo,draft]{boogonreport}\input{report.tex}"
```
