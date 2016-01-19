#Folder names and filenames
name=article
main=main
build=build

FILES=$(main).tex \
      myruss.sty ruslist.sty thesis.bib 160-240.sty a\&t.cls

##################################################

# Wich compilers shall be used?
#   xelatex  - novaday TEX->PDF model using EPS pics.
#   pdflatex - novaday TEX->PDF model using all pic formats except EPS.
compiler=pdflatex      # may be pdflatex, lualatex, xelatex etc.


all: $(name).pdf

$(name).pdf: $(build)/$(main).pdf
	@echo; echo ===== CP; 
	@cp $< $@

build: $(FILES) $(build)
	@rm -f -r $(build);
	@mkdir $(build);
	@cd $(build) && ln -s $(FILES:%=../%) .

latex:
	@echo; echo ===== LaTeX; 
	@cd $(build); $(compiler) -halt-on-error  $(main).tex;
	
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
	@make build
	@make latex
	@echo; echo ===== CP; 
	@cp $(build)/$(main).pdf $(name).pdf

$(build)/$(main).pdf:  $(FILES)
	@make build
	@make latex 
	@make biber
	@make latex
	@make latex
	@make warnings

clean:
	@echo; echo ===== CLEAN; 
	@rm -f -r $(build)
	@rm -f ./*~

clobber: clean
	@echo; echo ===== CLOBBER; 
	@rm -f $(name).pdf