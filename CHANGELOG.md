# 更新日志

版本号同时出现在三处：本文件、`\reportsetup{version}`、git tag。改版时一起改。

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
