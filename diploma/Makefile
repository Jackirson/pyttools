#Folder names and filenames
name=diploma
main=main
build=build

FILES=$(main).tex \
      intro.tex methods.tex algo.tex infinum.tex samples.tex extro.tex \
	  preamble.sty thesis.bib pic

##################################################

# Wich compilers shall be used?
#   xelatex  - novaday TEX->PDF model using EPS pics.
#   pdflatex - novaday TEX->PDF model using all pic formats except EPS.
compiler=pdflatex      # may be pdflatex, lualatex, xelatex etc.


all: $(name).pdf

$(name).pdf: $(build)/$(main).pdf
	@echo; echo ===== CP; 
	@cp $< $@

build:
	@echo; echo "===== LN (clean build)";  
	@rm -f -r $(build);
	@mkdir $(build);
	@cd $(build) && ln -s $(FILES:%=../%) .

latex:
	@echo; echo ===== LaTeX; 
	@cd $(build); $(compiler) -quiet -halt-on-error -shell-escape $(main).tex;
	
latex2:
	@echo; echo ===== LaTeX-2; 
	@cd $(build); $(compiler) -quiet -halt-on-error -shell-escape $(main).tex;

biber:
	@if test -f $(build)/$(main).bcf;\
	then\
		echo; echo ===== Biber; \
		cd $(build) && biber $(main);\
	fi;

warnings:
	@echo; echo ===== WARNINGS; 
	@cat $(build)/$(main).log | grep 'LaTeX Warning' | grep -v 'float specifier changed' || echo "NONE"

quick:
	@$(MAKE) latex
	@cp $(build)/$(main).pdf $(name).pdf

$(build)/$(main).pdf:  build latex biber latex2 warnings


clean:
	@echo; echo ===== CLEAN; 
	@rm -f -r $(build)
	@rm -f ./*~
	@$(RM) -f `find . -name \*'-eps-converted-to.pdf'`

clobber: clean
	@echo; echo ===== CLOBBER; 
	@rm -f $(name).pdf

