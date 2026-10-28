\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{boogonreport} % fork of deepseek.cls (arXiv:2412.19437 e-print)

%%======== Package options and base class ========
\RequirePackage{xifthen}
\newboolean{nonumbering}
\newboolean{logo}
\newboolean{address}
\newboolean{copyright}
\newboolean{internal}
\DeclareOption{nonumbering}{\setboolean{nonumbering}{true}}
\DeclareOption{logo}{\setboolean{logo}{true}}
\DeclareOption{address}{\setboolean{address}{true}}
\DeclareOption{copyright}{\setboolean{copyright}{true}}
\DeclareOption{internal}{\setboolean{internal}{true}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\ProcessOptions
\LoadClass{extarticle}

%%======== Branding hooks (override in the document) ========
% Logo file path (relative to the main file); empty = no logo.
\newcommand{\reportlogo}{}
% Short title used in the running header from page 2 onwards.
\newcommand{\reportshorttitle}{}
% Organisation shown in the first-page footer and the copyright line.
\newcommand{\reportorg}{Cooper Intelligence}
% Postal/office line printed above the copyright notice.
\newcommand{\reportaddress}{}
% Wording used when the "internal" option is active.
\newcommand{\reportinternalnote}{Confidential. Internal Only.}
% Class-name shown in the running header when no short title is given.
\newcommand{\reporttypename}{Technical Report}

%%======== Packages Required ========
% Fonts and language
\AtEndOfClass{\RequirePackage[tracking=smallcaps]{microtype}}
\RequirePackage[utf8]{inputenc}
\RequirePackage[english]{babel}
\RequirePackage{amsthm, amsmath, amsfonts, amssymb}
\RequirePackage{cmap}
\RequirePackage[T1]{fontenc}
% JH: switched to xurl from url due to wrapping issues. This fixes it. For example, the Megatron-Turing NLG link
\RequirePackage{xurl}
\RequirePackage[hidelinks]{hyperref} % no coloured boxes around cross-references
\RequirePackage{pifont}
\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{textcomp} % For copyright symbol styling
\RequirePackage[overload]{textcase}
%% *Graphics, tables and other formatting
\RequirePackage{graphicx}
\RequirePackage{colortbl}
\RequirePackage{booktabs}
\RequirePackage{changepage}
\RequirePackage{enumitem} % For reducing bullet list item separation
\RequirePackage{tabularx}
\RequirePackage{datetime}
% Headers and footers
\RequirePackage{fancyhdr}  % custom headers/footers
\RequirePackage{lastpage}  % Number of pages in the document
% Lists and their spacing
\RequirePackage{enumitem}
\setlist[itemize]{noitemsep}
\setlist[enumerate]{noitemsep}
% Title, Abstract, Bibliography
\RequirePackage[explicit]{titlesec}
\RequirePackage{bibentry}
\RequirePackage{mdframed}
\RequirePackage{caption}
\RequirePackage{needspace}
\RequirePackage{etoolbox} % emptiness tests for the branding hooks
\RequirePackage{setspace} % line spacing for the contents page

%%======== Fonts ========
% Text in Bitstream Charter (XCharter), maths from the matching newtx set,
% typewriter from Latin Modern scaled to match Charter's x-height.
\RequirePackage{XCharter}
\RequirePackage[xcharter,bigdelims,vvarbb]{newtxmath}
\RequirePackage[scaled=1.1]{zlmtt}

%%======== Margins and column spacing ========
\RequirePackage[left=2.5cm,%
right=2.5cm,%
top=3cm,%
bottom=3cm,%
headheight=40pt,%
headsep=20pt,%
a4paper]{geometry}%
\setlength{\columnsep}{15pt} % Distance between the two columns of text
\setlength{\parskip}{0.5\baselineskip}

%% *Custom font sizes and styles
\newcommand{\watermarkfont}{\color{black50}\normalfont\fontsize{10}{12}\selectfont}
\newcommand{\headerfont}{\normalfont\sffamily\fontsize{8}{10}\selectfont}
\newcommand{\titlefont}{\color{black}\normalfont\bfseries\fontsize{16}{20}\selectfont}

\newcommand{\datesfont}{\normalfont\sffamily\itshape\fontsize{8}{10}\selectfont}
\newcommand\urlheaderfont{\color{blue}\fontsize{8}{10}\selectfont}
\newcommand{\absfont}{\linespread{1.2}\fontsize{11}{12}\selectfont}
\newcommand{\keywordstitlefont}{\bfseries\linespread{1.2}\fontsize{8}{10}\selectfont}
\newcommand{\keywordsfont}{\itshape\linespread{1.2}\fontsize{11}{12}\selectfont}
\newcommand{\copyrightfont}{\normalfont\fontsize{7}{9}\selectfont}
\newcommand{\footerfont}{\color{black}\normalfont\fontsize{11}{12}\selectfont}
\newcommand{\subjectfont}{\color{white}\bfseries\fontsize{10}{12}\selectfont}
\newcommand{\headingfont}{\color{black}\bfseries\fontsize{13}{14}\selectfont}

\newcommand{\keywords}[1]{\def\@keywords{#1}}
\newtoks\correspondingauthor
\newtoks\paperurl
\newtoks\reportnumber

% ISO-8601 date format
\newdateformat{monthyeardate}{\THEYEAR-\THEMONTH-\THEDAY}

\setcounter{secnumdepth}{3}
\ifthenelse{\boolean{nonumbering}}{\setcounter{secnumdepth}{0}}{}

%%========  Author and affiliation ========
\RequirePackage{authblk}
\setcounter{Maxaffil}{0}
\renewcommand{\Authfont}{\normalfont\fontsize{11}{15}\selectfont\centering}
\renewcommand\Affilfont{\bfseries\fontsize{13}{15}\selectfont\centering}
\makeatletter
\renewcommand\AB@affilsepx{ , \protect\Affilfont}
\makeatother
\renewcommand\Authands{, }

\makeatletter
\newcommand{\internalonly}{\ifdefempty{\reportorg}{}{\reportorg, }\reportinternalnote}
\newcommand{\copyrightext}{\copyrightfont \textcopyright\, \the\year{} \ifdefempty{\reportorg}{}{\reportorg. }All rights reserved}
\makeatother

% Header and Footer Content ========
% Activate the running header/footer for pages 2+ (the original class left this
% commented out, so the fancy definitions never took effect).
\pagestyle{fancy}

\fancypagestyle{firststyle}{
    \fancyhead[R]{{\footerfont\itshape\monthyeardate\today}}
    \fancyhead[L]{%
        \ifthenelse{\boolean{logo}}{%
            \ifdefempty{\reportlogo}{}{\includegraphics[width=138pt]{\reportlogo}}%
        }{}%
        \ifdefined\paperurl
        \if\relax\the\paperurl\relax \else
            \href{\the\paperurl}{\urlheaderfont \itshape \the\paperurl}\\ \fi
        \else \fi
    }
    \fancyhead[C]{}
    \fancyfoot[L]{%
        \ifdefined\correspondingauthor
        \if\relax\the\correspondingauthor\relax
        \else \footerfont {*\the\correspondingauthor \\} \fi
        \else \fi
        \ifthenelse{\boolean{internal}}{\footerfont \internalonly \\}{\footerfont\bfseries\relax}%
        \ifthenelse{\boolean{address}}{%
            \ifdefempty{\reportaddress}{}{\itshape\footerfont \reportaddress \\}}{}%
    }
    \fancyfoot[R]{%
        \ifthenelse{\boolean{internal}}{%
            \ifdefined\reportnumber
            \if\relax\the\reportnumber\relax
            \else \footerfont\itshape  {\footerfont \bfseries} \fi
            \else \fi
        }{\ifthenelse{\boolean{copyright}}{\copyrightext}{\footerfont\bfseries\relax}}%
    }
    \fancyfoot[C]{\footerfont\bfseries\relax}
}

% Header and Footer for pages from 2 onwards
\fancyhead[L,R]{}
\fancyhead[C]{\footerfont \ifdefempty{\reportshorttitle}{\reporttypename}{\reportshorttitle}}
\fancyfoot[C]{}
\fancyfoot[L]{%
    \ifthenelse{\boolean{internal}}{\footerfont \internalonly\newline
        \ifdefined\reportnumber
        \if\relax\the\reportnumber\relax
        \else \footerfont {} \fi
        \else \fi}{\footerfont\bfseries\relax}%
}
\fancyfoot[C]{\footerfont \thepage}

% Header and footer rules (coloured).
\renewcommand{\headrulewidth}{1pt}
\renewcommand{\footrulewidth}{1pt}
\let\DefaultHeadRule\headrule
\let\DefaultFootRule\footrule
\renewcommand{\headrule}{\color{gray}\DefaultHeadRule}
\renewcommand{\footrule}{\textcolor{gray}{\DefaultFootRule}}

\renewenvironment{abstract}
{\par\noindent\\  \ignorespaces \bfseries}
{\par\bigskip}

%%======== Abstract and section formatting ========
\def\xabstract{abstract}
\long\def\abstract#1\end#2{\def\two{#2}\ifx\two\xabstract
	\long\gdef\theabstract{\ignorespaces#1}
	\def\go{\end{abstract}}\else
\typeout{^^J^^J PLEASE DO NOT USE ANY \string\begin\space \string\end^^J
	COMMANDS WITHIN ABSTRACT^^J^^J}#1\end{#2}
\gdef\theabstract{\vskip12pt BADLY FORMED ABSTRACT: PLEASE DO
NOT USE {\tt\string\begin...\string\end} COMMANDS WITHIN
THE ABSTRACT\vskip12pt}\let\go\relax\fi
\go}

\makeatletter
\newcommand{\abscontent}{
	\noindent
    \centerline{\fontsize{15pt}{14pt}\selectfont\textbf{Abstract}}\vspace{5ex}
	\parbox{\dimexpr\linewidth}{\absfont \theabstract}
	\@ifundefined{@keywords}{}{
		\vskip1em \noindent \keywordsfont  Keywords: \@keywords}
}

\if@twocolumn%
\renewcommand{\maketitle}{
	\twocolumn[
	\begin{adjustwidth}{0pt}{0pt}
		\begin{flushleft}
			{
				{ \raggedright \titlefont
				\@title\par}%
				\vskip11pt
				{\raggedright \@author\par}
				\vskip20pt%
			}%
		\end{flushleft}
	\end{adjustwidth}

		\abscontent
	\vskip20pt%
	]
	\thispagestyle{firststyle}
}%
\else% \@twocolumnfalse
\renewcommand{\maketitle}{\bgroup\setlength{\parindent}{0pt}
        \vspace*{3pt}
	\begin{adjustwidth}{0pt}{0pt}
		\begin{flushleft}
			{
				{\raggedright \titlefont \@title\par}%
				\vskip20pt
				{\raggedright \@author\par}
				\vskip30pt %
			}%
		\end{flushleft}
	\end{adjustwidth}
	\egroup
	{%
		{\abscontent}
	}%
	\thispagestyle{firststyle}
}%
\fi
\makeatother

%%======== Contents page ========
% Mirrors the upstream report: the contents page sits on a page of its own and is
% set slightly tighter (0.9 baselineskip) so that a long report still fits it.
% Use \reporttoc after \maketitle. Sections and subsections are listed; deeper
% levels stay out of the contents by default.
\setcounter{tocdepth}{2}
\newcommand{\reporttoc}{%
  \clearpage
  \begin{spacing}{0.9}%
    \tableofcontents
  \end{spacing}%
  \clearpage
}

%%========  Bibliography using bibtex ========
\addto{\captionsenglish}{\renewcommand{\refname}{References}}
\newcommand{\citeas}[1]{\Needspace*{8\baselineskip}\noindent\bibentry{#1}}

\titleformat{\section}
{\large\bfseries\headingfont}
{\thesection.}
{0.5em}
{#1}
[]
\titleformat{name=\section,numberless}
{\large\bfseries\headingfont}
{}
{0em}
{#1}
[]
\titleformat{\subsection}
{\bfseries}
{\thesubsection.}
{0.5em}
{#1}
[]
\titleformat{\subsubsection}
{\bfseries\itshape}
{\thesubsubsection.}
{0.5em}
{#1}
[]

\titlespacing*{\section}{0pc}{3ex plus4pt minus3pt}{5pt}
\titlespacing*{\subsection}{0pc}{2.5ex plus3pt minus2pt}{2pt}
\titlespacing*{\subsubsection}{0pc}{2ex plus2.5pt minus1.5pt}{2pt}

%%======== Captions in tables and figures ========
\DeclareCaptionLabelSeparator{pipe}{ $\vert$ }% or $\vert$
\captionsetup{labelfont={},
labelsep=space,%
figurename=Figure,%
labelsep=pipe,
singlelinecheck=off%
}
