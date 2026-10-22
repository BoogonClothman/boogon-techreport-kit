# 更新日志

版本号同时出现在三处：本文件、`\reportsetup{version}`、git tag。改版时一起改。

## v1.0.1 — 2026-10-22

修掉三个会在真实报告里悄悄出错的默认值，并让构建脚本接受任意报告名。用这套类
写完一篇 15 页报告后逐条发现的，都附了最小复现。

**类文件 `boogonreport.cls`**

- 交叉引用：补上 `subsection` / `subsubsection` / `equation` 的中文名。此前
  `\cref` 引用小节得到「节 1.1」（语序反），引用公式得到英文「eq. (1)」——不报错，
  只是文字错了。按节引用仍用 `\secref`，`\cref` 现在只负责图、表与式。
- 等宽字体：为 `Latin Modern Mono` 声明粗体别名。代码块里被高亮成加粗的关键字
  （bash 的 `cd`、`echo`）此前会触发 `Font shape .../b/n undefined`。
- 目录：默认 `tocdepth=2`。三级标题进目录会把 8--20 页报告的目录顶到第二页、
  末尾孤零零剩一行；需要更深时在导言区写 `\setcounter{tocdepth}{3}` 覆盖。
- 标题：中文三级标题不再叠加 `\itshape`。SimSun 没有粗斜体，此前每个
  `\subsubsection` 都会触发 `Font shape .../b/it undefined` 并静默退化成粗体正体；
  英文仍保留斜体以示层级。

**工程**

- `build.ps1`：`-Job` 不再限定 `all` / `main-en` / `main-zh` / `starter` 四个
  名字，任意 `<name>.tex` 都能构建（如 `-Job report`）。
- `build.ps1`：引擎改为读报告自己的 `\documentclass[...]` 选项（含 `zh` 即
  XeLaTeX），不再按文件名猜。中文报告改了名也不会误用 pdfLaTeX，也不会因为文件名
  带 `zh` 而被判成中文。

## v1.0.0 — 2026-10-22

首个版本。

**类文件 `boogonreport.cls`**

- 版式：A4 单栏、Palatino、首屏品牌带、`图 1 | ...` 竖线图注、三线表、代码块。
- 双语：`zh` 选项一次性切换字体管线（ctex + TeX Gyre Pagella）与本地化文案。
- 元信息：`\reportsetup{...}` 一处定义，自动同步页眉页脚与 PDF 属性。
- 交叉引用：`\secref` / `\cref` / `\appref`，中英语序各自正确且可点击。
- 不会静默失败：`\keywords` 立即排版；`\appendix` 自动换页并改写引用类型；
  中文用 pdfLaTeX 编译直接报错。
- 字符兜底：pdfLaTeX 下为 `≥ ≤ ≠ ≈ ∞` 补数学映射，避免静默丢字。
- 选项：`logo`/`nologo`、`times`、`numeric`、`nonumbering`、`leftalign`、
  `draft`、`fandol`、`winfonts`、`macfonts`。

**示例与骨架**

- `main-zh.tex`（XeLaTeX，7 页）与 `main-en.tex`（pdfLaTeX，8 页），主题即本模板的
  设计说明，所有数字均可核对。
- `starter/`：三章空白骨架，带 `\todo{}` 占位。

**工程**

- `build.ps1` / `build.cmd` / `Makefile`：自动按语言选引擎，支持 `-Job`、`-Clean`、`-Watch`。
- GitHub Actions：双语言并行编译、PDF 作为 artifact、打 tag 自动发 Release。
- 文档：快速开始、写作规范、发布清单、迁移改造、设计说明。

**已知限制**

- 单栏版式适合 8--20 页；学位论文请用学校模板。
- 中文默认需 XeLaTeX；Fandol 字体集的 PDF 中文字符不可复制。
