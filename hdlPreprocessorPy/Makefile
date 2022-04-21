# See https://github.com/markpiffer/gmtt
$(shell if ! [ -d gmtt ]; then git clone https://github.com/markpiffer/gmtt; fi)
include gmtt/gmtt.mk


py3_minver := 8
py3_maxver := 10

SHELL := /bin/bash -O expand_aliases

shell_type := $(notdir $(SHELL))
moduleshome := $(shell echo $$MODULESHOME)

# Tool Libraries
antlr4_runtime := antlr.jar

# Toolchain
PY := python
PIP := pip
MODULE := source $(moduleshome)/init/$(shell_type); module
GIT := git
JAVA := java
ANTLR4PY3 := antlr4 -Xlog -Dlanguage=Python3



# Public source locations
antlr4_dl_url := https://www.antlr.org/download/
p3_antlr_book_git := https://github.com/jszheng/py3antlr4book
ex_01_dir := 01-Hello

# define a table of 3 columns: <unique_project_name> <SRC_DIR:source_dir> <SRC_GLOB:file_globs>
# use | (bar) to make the list of globs or files if there is more than one minus (-) is used for an empty field
PROJ = 1
SRC_DIR = 2
SRC_GLOB = 3
PREREQ = 4
# <PROJECT>			<SOURCE PATH|->										<SOURCE GLOB|->				<PREREQUISITE|->
define ANTLR_SOURCE_LOCATIONS
4
SVPPLexer			../grammars											verilogPreprocLexer.g4		-
SVPPLexerPy			../grammars											verilogPreprocLexerPy.g4	-
SVPPParserPy		../grammars											verilogPreprocParserPy.g4	-
Hello   			../../../../sandbox/antlr/py3antlr4book/01-Hello	*.iml|*.g4|test_hello.py	-
run-Hello			-													-							Hello
endef

#test-SVPPLexerPy 	-													-							SVPPLexerPy


# NOTE: ANTLR mandates that the .g4 file name must match the defined ANTLR symbol within that
# file and that the target language output files also have the same name pattern
# e.g. Hello.g4 -> HelloParser.py + Hello.interp + Hello.tokens.... etc...
# Hence the .g4's name is the ANTLR Name for that project

# Temporary build folder
build_dir := build

# Check for java
res != $(JAVA) --version
ifeq ($(.SHELLSTATUS),0)
  java_version != echo "$(res)" | head -1 | cut -f2 -d' '
else
  $(error You must install Java JRE e.g. sudo apt install openjdk-11-jre)
endif

# Check for Python
python_version != $(PY) -c "import sys;print(sys.version.split()[0])"
ifeq ($(.SHELLSTATUS),0)
  python_major != echo "$(python_version)" | cut -f1 -d'.'
  python_minor != echo "$(python_version)" | cut -f2 -d'.'

  ifneq ($(python_major),3)
    $(error Only Python3 is supported, you seem to be running Python$(python_major) from $(shell which $(PY)))
  endif

  res != test $(python_minor) -ge $(py3_minver) && test $(python_minor) -le $(py3_maxver)
  ifeq ($(.SHELLSTATUS),1)
    $(error Only Python3 versions $(py3_minver) through $(py3_maxver) are supported\n \
  you seem to have version $(python_version) - we recommend using pyenv)
  endif
else
  $(error Python not installed, please install Python3)
endif

# Check for Python dependencies
res != pip show antlr4-python3-runtime
ifeq ($(.SHELLSTATUS),0)
  py_antlr_version != echo "$(res)" | tr '\t\r\n' ' ' | cut -f4 -d' '
else
  $(error You must install Python ANTLR4 bindings e.g. pip install antlr4-python3-runtime)
endif

res != pip show pyside2
ifeq ($(.SHELLSTATUS),0)
  pyside2_version != echo "$(res)" | tr '\t\r\n' ' ' | cut -f4 -d' '
else
  $(error You must install Python3 pyside2 e.g. pip install pyside2)
endif

# Check for environemnt modules package
res != 2>&1 module --version | tr -d '\r\n'
ifeq ($(.SHELLSTATUS),0)
  modules_version != echo "$(res)" | cut -f3 -d' '
else
  $(error You must install Environment Modules, e.g. apt install environment-modules)
endif

# $(eval $(call cleanfolder, folder, prefix))
# $(eval $(call cleanfolder, build/01-Hello, Hello))
define cleanfolder =
	cd $1;\
	rm -rf __pycache__;\
	rm -rf *.interp;\
	rm -rf *.tokens;\
	rm -rf $2[LP]*
endef


# Lookup a project in the ANTLR_SOURCE_LOCATIONS table and return a value
# $(call lookup,<column>,<project_name>)
# $(call lookup,SRC_DIR,Hello)
# $(call lookup,SRC_GLOB,Hello)
lookup = $(filter-out -,$(subst |, ,$(call select,$(value $1),$(ANTLR_SOURCE_LOCATIONS),$$(call str-eq,$$1,$2))))

# Get the contents of a given column from the ANTLR_SOURCE_LOCATIONS table
# $(call get_column,<column>)
# $(call get_column,PROJ)  # Get a list of project names
get_column = $(filter-out -,$(call select,$(value $1),$(ANTLR_SOURCE_LOCATIONS),any))

# Return a prerequisite project for a given project
# $(call get_prereq,run-hello) -> Hello
get_prereq = $(strip $(call lookup,PREREQ,$1))

ALL_PROJ = $(call get_column,PROJ)

# Get a list of source assets for a project#
# $1 = Project
get_source_assets = $(foreach PATTERN,$(call lookup,SRC_GLOB,$1),$(wildcard $(call lookup,SRC_DIR,$1)/$(PATTERN)))

$(info ASSETS---------)
$(foreach PROJ,$(ALL_PROJ),$(foreach ASSET,$(call get_source_assets,$(PROJ)),$(info $(PROJ): $(ASSET))))
$(info ---------------)

# Take a list of source assets and convert into a list of build assets
# $1 = Project
get_build_assets = $(foreach ASSET,$(call get_source_assets,$1),$(build_dir)/$1/$(notdir $(ASSET)))

# Function to collect a source asset and make a target for it that copies it to a build asset
# $1 project name 
# $2 path to source asset
define collect_asset =
$(build_dir)/$1/$(notdir $2): $(build_dir)/$1 $2
	@echo -e "Copying source to $$@"
	cp $2 $(build_dir)/$1
endef

# Function to create a built target
# $1: project name
define create_target = 
# Make the build folder
$(build_dir)/$1:
	@echo -e "\nCreate build directory"
	mkdir -p $(build_dir)/$1

# Make a target for each asset
$(foreach ASSET,$(call get_source_assets,$1),$(eval $(call collect_asset,$1,$(ASSET))))

$(build_dir)/$1/$1.py: $(filter %.g4,$(call get_build_assets,$1)) | $(antlr4_runtime) $(filter-out %.g4,$(call get_build_assets,$1))
	@echo -e "\n-----------------------------\n"
	@echo -e "Building parser $$@"
	@$(MODULE) clear -f;\
	$(MODULE) switch ./antlr4module;\
	cd $$(dir $$^);\
	if ! [ -L antlr.jar ]; then ln -s ../../antlr.jar antlr.jar;fi;\
	echo "Building from $$(notdir $$^) in $$(dir $$^)";\
	echo "$$(notdir $$^)" | xargs $(ANTLR4PY3)


run-$1: $(build_dir)/$1/$1.py
	@$(MODULE) clear -f;\
	$(MODULE) switch ./antlr4module;\
	cd $$(dir $$^);\
	echo -e "\n";\
	pygrun $1 r --tokens input.txt

$1: $(build_dir)/$1/$1.py
endef

# Get a list of all prerequisite projects
PREREQ_PROJ = $(foreach PROJ,$(ALL_PROJ), $(call get_prereq,$(PROJ)))

# Ensure that prerequsites are built before others, by removing prerequisites from $(ALL_PROJ)
$(foreach PREREQ,$(PREREQ_PROJ), $(eval ALL_PROJ = $(filter-out $(PREREQ),$(ALL_PROJ))))

# Final goal, deps
all:  $(PREREQ_PROJ) $(ALL_PROJ)

# Individual goals
$(foreach PROJ,$(PREREQ_PROJ) $(ALL_PROJ),$(eval $(call create_target,$(PROJ))))


#Results
$(info Java    :  $(java_version))
$(info Python3 :  $(python_version))
$(info pyANTLR4:  $(py_antlr_version))
$(info modules :  $(modules_version))
$(info pyside2 :  $(pyside2_version))
$(info ------------------------------)
$(info targets :  $(ALL_PROJ))
$(info prereqs :  $(PREREQ_PROJ))
$(info ------------------------------)


# Now we know which version we have we can get the correct runtime
antlr_jar := antlr-$(py_antlr_version)-complete.jar
antlr_jar_dl := $(antlr4_dl_url)$(antlr_jar)

# Download the appropriate ANTLR runtime if we don't have it
$(antlr_jar):
	@echo -e "\nObtaining ANTLR Java Runtime Library"
	@if [ -L $(antlr4_runtime) ]; then rm -f $(antlr4_runtime); fi
	@test ! -e $(antlr4_runtime)
	@wget $(antlr_jar_dl) -nv -O $(antlr_jar)

# Create a symlink to the correct ANTLR version to make the name constant
$(antlr4_runtime): $(antlr_jar)
	@echo -e "\nCreating symlink to the tools\n"
	@ln -s $(antlr_jar) $(antlr4_runtime)

# There is a bug in module which means "module load" does create aliases, but module "switch does"!!
# https://github.com/cea-hpc/modules/issues/86
$(example_01)&: $(ex_01_dir)/Hello.g4 $(antlr4_runtime)
	@echo -e "\nBuilding the parser"
	$(MODULE) clear -f;\
	$(MODULE) switch ./antlr4module;\
	$(ANTLR4PY3) $<

clean:
	rm -rf build
	rm -rf __pycache__
	rm *.jar

.PHONY: clean all $(PREREQ_PROJ) $(ALL_PROJ)

