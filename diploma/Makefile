name=diploma
main=main
build=build

FILES=$(main).tex \
      intro.tex methods.tex algo.tex infinum.tex samples.tex extro.tex \
	  preamble.sty thesis.bib pic

# Which compilation model shall be used?
# Possible options:
#   latex    - traditional TEX->DVI->PS model,
#   xelatex  - novaday TEX->PDF model using EPS pics.
#   pdflatex - novaday TEX->PDF model using all pic formats except EPS.

LATEX_MODEL=pdflatex

##################################################

# Wich compilers shall be used?
pdflatex=pdflatex      # may be pdflatex, lualatex etc.
latex=latex            #this model is not fully supported!
xelatex=xelatex

all: $(name).pdf

$(name).pdf: $(build)/$(main).pdf
	@echo; echo ===== CP; echo;
	@cp $< $@

ifeq ($(LATEX_MODEL), latex)

$(build)/$(main).pdf: $(build)/$(main).ps
	@echo; echo ===== PS2PDF; echo;
	@cd $(build); ps2pdf $(main).ps $(main).pdf;

$(build)/$(main).ps: $(build)/$(main).dvi
	@echo; echo ===== DVIPS; echo;
	@cd $(build); dvips -o $(main).ps $(main).dvi;

$(build)/$(main).dvi: $(FILES) Makefile
	@if test -d $(build); then rm -r $(build); fi;
	@mkdir $(build);
	@cd $(build) && ln -s $(FILES:%=../%) .

	@echo; echo ===== 1-st LaTeX; echo;
	@cd $(build); $(latex) -shell-escape $(main).tex;
	@echo; echo ===== 2-nd LaTeX; echo;
	@cd $(build); $(latex) -shell-escape $(main).tex;

else

ifeq ($(LATEX_MODEL), xelatex)
compiler=$(xelatex)
else
compiler=$(pdflatex)
endif

build:
	@if test -d $(build); then rm -r $(build); fi;
	@mkdir $(build);
	@cd $(build) && ln -s $(FILES:%=../%) .

latex:
	@echo; echo ===== LaTeX; 
	@cd $(build); $(compiler) -quiet -halt-on-error -shell-escape $(main).tex;

biber:
	@if test -f $(build)/$(main).bcf;\
	then\
		echo; echo ===== Biber; echo;\
		cd $(build) && biber $(main);\
	fi;

warnings:
	@echo; echo ===== WARNINGS; echo;
	@cat $(build)/$(main).log | grep 'LaTeX Warning' | grep -v 'float specifier changed' || echo "NONE"

quick:
	@$(MAKE) latex
	@cp $(build)/$(main).pdf $(name).pdf

$(build)/$(main).pdf: $(FILES) Makefile clean build
	@$(MAKE) latex
	@$(MAKE) biber
	@$(MAKE) latex
	@$(MAKE) latex
	@$(MAKE) warnings
	
endif

clean:
	@echo; echo ===== CLEAN; echo;
	@rm -f -r $(build)
	@rm -f ./*~
	@$(RM) -f `find . -name \*'-eps-converted-to.pdf'`

clobber: clean
	@echo; echo ===== CLOBBER; echo;
	@rm -f $(name).pdf

