# 技术报告构建（macOS / Linux）
# 英文用 pdfLaTeX，中文用 XeLaTeX，均由 latexmk 驱动两遍编译。

LATEXMK ?= latexmk
JOB_EN  ?= main-en
JOB_ZH  ?= main-zh
FLAGS   := -bibtex -interaction=nonstopmode -halt-on-error -file-line-error

.PHONY: all en zh starter watch-zh watch-en clean distclean

all: en zh

en:
	$(LATEXMK) -pdf $(FLAGS) $(JOB_EN).tex

zh:
	$(LATEXMK) -xelatex $(FLAGS) $(JOB_ZH).tex

# 空白骨架：借用仓库根目录的类文件，不复制第二份
starter:
	cd starter && TEXINPUTS="$(CURDIR):$(TEXINPUTS)" \
		$(LATEXMK) -xelatex $(FLAGS) report.tex

watch-en:
	$(LATEXMK) -pdf -pvc $(FLAGS) $(JOB_EN).tex

watch-zh:
	$(LATEXMK) -xelatex -pvc $(FLAGS) $(JOB_ZH).tex

clean:
	$(LATEXMK) -c
	-cd starter && $(LATEXMK) -c

distclean:
	$(LATEXMK) -C
	-cd starter && $(LATEXMK) -C
