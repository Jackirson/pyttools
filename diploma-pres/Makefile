#Folder names and filenames
name=diploma_pres
main=main_pres
build=build

FILES=$(main).tex \
	  10_pev.tex 20_order.tex 30_result.tex draw.tex preamble.tex pic

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
	@mkdir $(build);
	@cd $(build) && ln -s $(FILES:%=../%) .

latex:
	@echo; echo ===== LaTeX; 
	@cd $(build); $(compiler)  -halt-on-error -shell-escape $(main).tex;
	
latex2:
	@echo; echo ===== LaTeX-2; 
	@cd $(build); $(compiler)  -halt-on-error -shell-escape $(main).tex;

warnings:
	@echo; echo ===== WARNINGS; 
	@cat $(build)/$(main).log | grep 'LaTeX Warning' | grep -v 'float specifier changed' || echo "NONE"

quick:
	@$(MAKE) latex
	@cp $(build)/$(main).pdf $(name).pdf

$(build)/$(main).pdf:  clean build latex latex2 warnings

clean:
	@echo; echo ===== CLEAN; 
	@rm -f -r $(build)
	@rm -f ./*~

clobber: clean
	@echo; echo ===== CLOBBER; 
	@rm -f $(name).pdf