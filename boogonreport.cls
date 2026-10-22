%% ============================================================================
%%  boogonreport.cls -- Boogon 技术报告文档类
%%
%%  设计目标
%%    * 一个类文件搞定：A4 宽单栏、Palatino、首屏品牌带、竖线图注、
%%      三线表与最优值标记、代码块、draft 模式。
%%    * 中英双语一次切换：zh 选项同时切换字体管线、题注、交叉引用、
%%      目录与参考文献标题，不再让使用者手写一堆 \renewcommand。
%%    * 元信息只有一处：\reportsetup{...}，PDF 元数据自动同步。
%%    * 不制造静默失败：\keywords 立即排版、\appendix 自动换页且
%%      交叉引用自动输出「附录 A」。
%%
%%  许可：MIT（见 LICENSE）
%%  依赖：TeX Live 2022+ / MiKTeX，完整安装即可，无需额外字体。
%%  编译：英文 pdflatex，中文 xelatex（类里会检查并报错提示）。
%% ============================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{boogonreport}[2026/10/22 v1.0.0 Boogon technical report]

%% ------------------------------ 选项 ---------------------------------------
\newif\ifbg@zh
\newif\ifbg@logo      \bg@logotrue
\newif\ifbg@numbered  \bg@numberedtrue
\newif\ifbg@centered  \bg@centeredtrue
\newif\ifbg@numeric
\newif\ifbg@draft
\newif\ifbg@times
\newif\ifbg@fandol
\newif\ifbg@winfonts
\newif\ifbg@macfonts
\def\bg@ctexfontset{}

\DeclareOption{zh}{\bg@zhtrue}
\DeclareOption{en}{\bg@zhfalse}
\DeclareOption{logo}{\bg@logotrue}
\DeclareOption{nologo}{\bg@logofalse}
\DeclareOption{numbered}{\bg@numberedtrue}
\DeclareOption{nonumbering}{\bg@numberedfalse}
\DeclareOption{centered}{\bg@centeredtrue}
\DeclareOption{leftalign}{\bg@centeredfalse}
\DeclareOption{numeric}{\bg@numerictrue}
\DeclareOption{draft}{\bg@drafttrue}
\DeclareOption{times}{\bg@timestrue}
\DeclareOption{fandol}{\bg@fandoltrue}
\DeclareOption{winfonts}{\bg@winfontstrue}
\DeclareOption{macfonts}{\bg@macfontstrue}
\DeclareOption*{\ClassWarning{boogonreport}{Unknown option '\CurrentOption' ignored}}
\ProcessOptions\relax

\LoadClass[11pt,a4paper]{article}
\RequirePackage{iftex}
\RequirePackage{etoolbox}

%% ------------------------------ 中文管线 -----------------------------------
%% ctex 必须在字体设置之前加载；scheme=plain 表示只加中文支持，不覆盖本类的
%% 标题、题注、表格样式。
\ifbg@zh
  \ifPDFTeX
    \ClassError{boogonreport}%
      {Chinese reports must be compiled with XeLaTeX or LuaLaTeX}%
      {Run: xelatex main-zh.tex}%
  \fi
  \ifbg@fandol  \PassOptionsToPackage{fontset=fandol}{ctex}\fi
  \ifbg@winfonts\PassOptionsToPackage{fontset=windows}{ctex}\fi
  \ifbg@macfonts\PassOptionsToPackage{fontset=mac}{ctex}\fi
  \RequirePackage[UTF8,scheme=plain]{ctex}
\fi

%% ------------------------------ 本地化字符串 -------------------------------
\ifbg@zh
  \renewcommand{\abstractname}{摘要}
  \newcommand{\keywordname}{关键词}
  \renewcommand{\contentsname}{目录}
  \renewcommand{\figurename}{图}
  \renewcommand{\tablename}{表}
  \renewcommand{\refname}{参考文献}
  \renewcommand{\appendixname}{附录}
  \newcommand{\listingname}{代码}
  \newcommand{\versionname}{版本}
  \newcommand{\bg@kwsep}{：}
\else
  \newcommand{\keywordname}{Keywords}
  \newcommand{\listingname}{Listing}
  \newcommand{\versionname}{Version}
  \newcommand{\bg@kwsep}{:\ }
  \renewcommand{\figurename}{Figure}
  \renewcommand{\tablename}{Table}
  \renewcommand{\refname}{References}
  \renewcommand{\appendixname}{Appendix}
\fi

%% ------------------------------ 字体 ---------------------------------------
%% 两个引擎共用一套观感：正文与数学都走 Palatino 家族；XeLaTeX/LuaLaTeX 下
%% 文本用 OpenType 的 TeX Gyre Pagella，这样 → ≥ µ 这类字符不会被吞掉。
\RequirePackage{amsmath}
\RequirePackage{amssymb}

\ifPDFTeX
  \RequirePackage[T1]{fontenc}
  \RequirePackage[utf8]{inputenc}
  \ifbg@times
    \RequirePackage{newtxtext}
    \RequirePackage{newtxmath}
  \else
    \RequirePackage{mathpazo}
  \fi
  \RequirePackage[scaled=0.88]{helvet}
  %% 等宽字体统一用 Latin Modern Mono：两个引擎都有，矢量、可缩放，
  %% 不会出现 9.5pt 被替换成 9pt 的警告。
  \renewcommand{\ttdefault}{lmtt}
  %% pdfLaTeX 的 T1 编码对下面这几个字符没有定义，会「静默丢字」；
  %% 箭头与 ×÷±µ° 由 inputenc/textcomp 自带，无需重复声明。
  \RequirePackage{newunicodechar}
  \newunicodechar{≥}{\ensuremath{\geq}}
  \newunicodechar{≤}{\ensuremath{\leq}}
  \newunicodechar{≠}{\ensuremath{\neq}}
  \newunicodechar{≈}{\ensuremath{\approx}}
  \newunicodechar{∞}{\ensuremath{\infty}}
\else
  \ifbg@times
    \RequirePackage{newtxmath}
  \else
    \RequirePackage{mathpazo}
  \fi
  \RequirePackage{fontspec}
  \ifbg@times
    \setmainfont{TeX Gyre Termes}
  \else
    \setmainfont{TeX Gyre Pagella}
  \fi
  \setsansfont{TeX Gyre Heros}[Scale=0.88]
  \setmonofont{Latin Modern Mono}[Scale=0.92]
\fi

%% ------------------------------ 版面 ---------------------------------------
\RequirePackage[left=2.5cm,right=2.5cm,top=3.0cm,bottom=3.2cm,
                headheight=40pt,headsep=20pt,a4paper]{geometry}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0.5\baselineskip plus 1pt minus 1pt}
\setlength{\footskip}{1.1cm}
\setlength{\abovedisplayskip}{0.6em plus 2pt minus 2pt}
\setlength{\belowdisplayskip}{0.6em plus 2pt minus 2pt}
%% 中英混排时偶尔会出现无法断行的长串；给它一点伸缩余量，避免文字挤出版心。
\setlength{\emergencystretch}{1.5em}

%% ------------------------------ 颜色 ---------------------------------------
%% 品牌色取自 Boogon 站点设计变量（--ds-color-brand / --ds-color-brand-deep），
%% 链接用深一档，保证打印后仍然读得清。
\RequirePackage{xcolor}
\definecolor{bgbrand}{HTML}{4D6BFE}
\definecolor{bgbranddeep}{HTML}{3A65C2}
\definecolor{bgink}{HTML}{1E232C}
\definecolor{bggray}{HTML}{6B7280}
\definecolor{bgrule}{HTML}{B4BCC8}
\definecolor{bgcodebg}{HTML}{F6F7F9}

%% ------------------------------ 宏包 ---------------------------------------
\RequirePackage{graphicx}
\RequirePackage{booktabs}
\RequirePackage{tabularx}
\RequirePackage{multirow}
\RequirePackage{array}
\RequirePackage{enumitem}
\RequirePackage{caption}
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}
\RequirePackage[explicit]{titlesec}
\RequirePackage{listings}
\RequirePackage[authoryear,sort&compress,round]{natbib}
\RequirePackage{keyval}
\RequirePackage{microtype}
\ifbg@draft
  \RequirePackage[switch]{lineno}
\fi

%% ------------------------------ 元信息 -------------------------------------
%% 所有对外信息集中在一处；\reportsetup 之外不要再定义第二份。
\def\bg@title{}
\def\bg@subtitle{}
\def\bg@author{}
\def\bg@affiliation{}
\def\bg@email{}
\def\bg@link{}
\def\bg@linktext{}
\def\bg@number{}
\def\bg@version{}
\def\bg@date{\today}
\def\bg@wordmark{BoogonClothman}
\def\bg@logo{}
\def\bg@shorttitle{}
\def\bg@metakeywords{}
\def\bg@license{}

\define@key{bg}{title}{\def\bg@title{#1}}
\define@key{bg}{subtitle}{\def\bg@subtitle{#1}}
\define@key{bg}{author}{\def\bg@author{#1}}
\define@key{bg}{affiliation}{\def\bg@affiliation{#1}}
\define@key{bg}{email}{\def\bg@email{#1}}
\define@key{bg}{link}{\def\bg@link{#1}}
\define@key{bg}{linktext}{\def\bg@linktext{#1}}
\define@key{bg}{number}{\def\bg@number{#1}}
\define@key{bg}{version}{\def\bg@version{#1}}
\define@key{bg}{date}{\def\bg@date{#1}}
\define@key{bg}{wordmark}{\def\bg@wordmark{#1}}
\define@key{bg}{logo}{\def\bg@logo{#1}}
\define@key{bg}{shorttitle}{\def\bg@shorttitle{#1}}
\define@key{bg}{keywords}{\def\bg@metakeywords{#1}}
\define@key{bg}{license}{\def\bg@license{#1}}
\newcommand{\reportsetup}[1]{\setkeys{bg}{#1}}

%% ------------------------------ 字号 ---------------------------------------
\newcommand{\bg@titlefont}{\normalfont\bfseries\fontsize{17}{21}\selectfont}
\newcommand{\bg@subtitlefont}{\normalfont\fontsize{12.5}{16}\selectfont}
\newcommand{\bg@authorfont}{\normalfont\fontsize{12}{15}\selectfont}
\newcommand{\bg@affilfont}{\normalfont\itshape\fontsize{9.5}{12.5}\selectfont}
\newcommand{\bg@metafont}{\normalfont\fontsize{9.5}{12.5}\selectfont}
\newcommand{\bg@absfont}{\fontsize{10.5}{14.5}\selectfont}
\newcommand{\bg@headfont}{\normalfont\sffamily\fontsize{8}{10}\selectfont}
\newcommand{\bg@footfont}{\normalfont\fontsize{9}{11}\selectfont}

%% ------------------------------ 首屏 ---------------------------------------
%% 品牌带在页眉里（左）；标题块在正文里，因此摘要、目录、首图都能接在同一页。
\newcommand{\bg@brandmark}{%
  \ifbg@logo
    \ifdefvoid{\bg@logo}{%
      {\sffamily\bfseries\large\bg@wordmark}%
    }{%
      \IfFileExists{\bg@logo}%
        {\includegraphics[height=24pt]{\bg@logo}}%
        {{\sffamily\bfseries\large\bg@wordmark}}%
    }%
  \fi}

\fancypagestyle{bgfirst}{%
  \fancyhf{}%
  \fancyhead[L]{\bg@brandmark}%
  \fancyhead[R]{\bg@headfont\bg@date}%
  \fancyfoot[L]{\bg@footfont
    \ifdefvoid{\bg@email}{}{\textcolor{bggray}{*\,}\bg@email}}%
  \fancyfoot[C]{\bg@footfont\thepage}%
  \fancyfoot[R]{\bg@footfont
    \ifdefvoid{\bg@number}%
      {\ifdefvoid{\bg@version}{}{\textcolor{bggray}{\versionname\,\bg@version}}}%
      {\sffamily\textcolor{bggray}{\bg@number}}}%
  \renewcommand{\headrulewidth}{0.8pt}%
  \renewcommand{\footrulewidth}{0.8pt}%
  \renewcommand{\headrule}{\color{bgrule}\hrule width\headwidth height\headrulewidth}%
  \renewcommand{\footrule}{\color{bgrule}\hrule width\headwidth height\footrulewidth}}

\pagestyle{fancy}
\fancyhf{}
\fancyhead[C]{\bg@headfont\textcolor{bggray}{%
  \ifdefvoid{\bg@shorttitle}{\bg@title}{\bg@shorttitle}}}
\fancyfoot[C]{\bg@footfont\thepage}
\fancyfoot[R]{\bg@footfont\sffamily\footnotesize\textcolor{bggray}{%
  \ifdefvoid{\bg@number}{\ifdefvoid{\bg@version}{}{\versionname\,\bg@version}}%
    {\bg@number}}}
\renewcommand{\headrulewidth}{0.4pt}
\renewcommand{\footrulewidth}{0pt}
\renewcommand{\headrule}{\color{bgrule}\hrule width\headwidth height\headrulewidth}

\ifbg@numbered\else\setcounter{secnumdepth}{0}\fi

\renewcommand{\maketitle}{%
  \begingroup
  \thispagestyle{bgfirst}%
  \vspace*{4pt}%
  \ifbg@centered\centering\fi
  {\bg@titlefont\color{bgink}\bg@title\par}%
  \ifdefvoid{\bg@subtitle}{}{\vspace{4pt}{\bg@subtitlefont\color{bggray}\bg@subtitle\par}}%
  \vspace{14pt}%
  {\bg@authorfont\bg@author\par}%
  \ifdefvoid{\bg@affiliation}{}{\vspace{5pt}{\bg@affilfont\bg@affiliation\par}}%
  \ifdefvoid{\bg@email}{}{\vspace{2pt}{\bg@metafont\href{mailto:\bg@email}{\bg@email}\par}}%
  \ifdefvoid{\bg@link}%
    {}%
    {\vspace{2pt}{\bg@metafont\href{\bg@link}{%
       \ifdefvoid{\bg@linktext}{\nolinkurl{\bg@link}}{\nolinkurl{\bg@linktext}}}\par}}%
  \ifdefvoid{\bg@version}{}{\vspace{2pt}{\bg@metafont\textcolor{bggray}{\versionname\,\bg@version}\par}}%
  \par
  \endgroup}

%% ------------------------------ 摘要与关键词 -------------------------------
%% \keywords 立即排版：放在 abstract 里还是外面都能出现，不存在「写错位置就丢」。
\renewenvironment{abstract}{%
  \par\addvspace{1.2em}%
  {\centering{\bfseries\large\color{bgink}\abstractname}\par}%
  \addvspace{0.4em}%
  \begingroup\bg@absfont\noindent\ignorespaces}%
  {\par\endgroup\addvspace{0.4em}}

\newcommand{\keywords}[1]{%
  \par\addvspace{0.6em}%
  \noindent{\bfseries\color{bgink}\keywordname\bg@kwsep}#1%
  \par\addvspace{0.6em}}

%% ------------------------------ 题注 ---------------------------------------
%% Figure 1 | ... 的竖线分隔；表题在表上方。
\DeclareCaptionLabelSeparator{bgpipe}{\hspace{0.55em}$\vert$\hspace{0.55em}}
\captionsetup{labelfont=normalfont,labelsep=bgpipe,font=small,
              singlelinecheck=true,skip=6pt}
\captionsetup[table]{position=top,skip=4pt}

%% ------------------------------ 章节 ---------------------------------------
\titleformat{\section}{\large\bfseries\color{bgink}}{\thesection.}{0.55em}{#1}
\titleformat{name=\section,numberless}{\large\bfseries\color{bgink}}{}{0em}{#1}
\titleformat{\subsection}{\bfseries\color{bgink}}{\thesubsection.}{0.5em}{#1}
\titleformat{\subsubsection}{\bfseries\itshape}{\thesubsubsection.}{0.5em}{#1}
\titlespacing*{\section}{0pt}{2.4ex plus 4pt minus 3pt}{5pt}
\titlespacing*{\subsection}{0pt}{2.0ex plus 3pt minus 2pt}{2pt}
\titlespacing*{\subsubsection}{0pt}{1.8ex plus 2pt minus 1.5pt}{2pt}

%% ------------------------------ 目录 ---------------------------------------
\let\bg@oldtableofcontents\tableofcontents
\renewcommand{\tableofcontents}{%
  {\setlength{\parskip}{0pt}\linespread{1.12}\selectfont\bg@oldtableofcontents}}

%% ------------------------------ 列表 ---------------------------------------
\setlist[itemize]{noitemsep,topsep=3pt,leftmargin=1.5em}
\setlist[enumerate]{noitemsep,topsep=3pt,leftmargin=1.7em}

%% 贡献点列表：比 itemize 更紧凑，适合放在引言
\newenvironment{contributions}{%
  \begin{itemize}[leftmargin=1.6em,itemsep=3pt,topsep=4pt,label=\textbullet]%
}{\end{itemize}}

%% ------------------------------ 表格与数字 --------------------------------
\newcolumntype{L}{>{\raggedright\arraybackslash}X}
\newcolumntype{C}{>{\centering\arraybackslash}X}
\newcolumntype{R}{>{\raggedleft\arraybackslash}X}
\newcommand{\best}[1]{\textbf{#1}}       % 自家最优
\newcommand{\second}[1]{\underline{#1}}  % 次优

%% ------------------------------ 代码 ---------------------------------------
\lstdefinestyle{boogon}{
  basicstyle=\ttfamily\small,
  keywordstyle=\color{bgbranddeep}\bfseries,
  commentstyle=\color{bggray},
  stringstyle=\color{bgbrand},
  numbers=left,
  numberstyle=\tiny\color{bggray},
  numbersep=8pt,
  frame=single,
  rulecolor=\color{bgrule},
  backgroundcolor=\color{bgcodebg},
  breaklines=true,
  showstringspaces=false,
  tabsize=2,
  captionpos=b,
  aboveskip=0.8em,
  belowskip=0.4em,
  xleftmargin=1.6em,
  framexleftmargin=1.2em,
}
\lstset{style=boogon}

%% listings 不自带 YAML 方言；示例里的 CI 片段要用，这里补一个最小定义
\lstdefinelanguage{yaml}{
  keywords={true,false,null,yes,no,on,off},
  sensitive=false,
  comment=[l]{\#},
  morestring=[b]',
  morestring=[b]",
}

%% ------------------------------ 草稿标记 -----------------------------------
\newcommand{\todo}[1]{\ifbg@draft{\textbf{\color{red}[TODO: #1]}}\fi}
\newcommand{\fixme}[1]{\ifbg@draft{\marginpar{\raggedright\tiny\color{red}#1}}\fi}

%% ------------------------------ 参考文献 -----------------------------------
\ifbg@numeric
  \bibliographystyle{plainnat}
  \setcitestyle{numbers,sort&compress,super=false,open={[},close={]}}
\else
  \bibliographystyle{abbrvnat}
\fi
\setlength{\bibsep}{0.25em}
\renewcommand{\bibfont}{\small}

%% ------------------------------ 附录 ---------------------------------------
%% 附录自动换页；标签类型改为 appendix，因此正文里早先写的 \cref 也会输出
%% 「附录 A / appendix A」，而不是含糊的「section A」。
\let\bg@oldappendix\appendix
\renewcommand{\appendix}{%
  \clearpage
  \bg@oldappendix
  \crefalias{section}{appendix}%
}

%% ------------------------------ 交叉引用 -----------------------------------
\RequirePackage[colorlinks=true,
                allcolors=bgbranddeep,
                linktoc=all,
                breaklinks=true]{hyperref}
\RequirePackage{xurl}
\hypersetup{bookmarksnumbered=true,bookmarksopen=true}
\RequirePackage{cleveref}

\ifbg@zh
  \crefname{figure}{图}{图}
  \Crefname{figure}{图}{图}
  \crefname{table}{表}{表}
  \Crefname{table}{表}{表}
  \crefname{section}{节}{节}
  \Crefname{section}{节}{节}
  \crefname{appendix}{附录}{附录}
  \Crefname{appendix}{附录}{附录}
  %% 中文习惯是「第 3 节」而不是「节 3」，用专门的宏保证语序与超链接
  \newcommand{\secref}[1]{第~\ref{#1}~节}
  \newcommand{\appref}[1]{附录~\ref{#1}}
\else
  \crefname{appendix}{appendix}{appendices}
  \Crefname{appendix}{Appendix}{Appendices}
  \newcommand{\secref}[1]{\cref{#1}}
  \newcommand{\appref}[1]{\cref{#1}}
\fi

%% ------------------------------ PDF 元信息 ---------------------------------
\pdfstringdefDisableCommands{\def\\{ }}
\AtBeginDocument{%
  \ifdefvoid{\bg@shorttitle}{\gdef\bg@shorttitle{\bg@title}}{}%
  \hypersetup{%
    pdftitle={\bg@title},%
    pdfauthor={\bg@author},%
    pdfsubject={\bg@number},%
    pdfkeywords={\bg@metakeywords},%
    pdfcreator={boogonreport},%
  }%
  \ifbg@draft\linenumbers\fi}

\endinput
