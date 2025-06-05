# Makefile for Lox interpreter

#####################
# Java Implementation
#####################

# Variables for jlox
JC = javac
JFLAGS = -d build
JVM = java
JBUILD_DIR = build
SRC_DIR = jlox/lox
SRC_FILES = $(SRC_DIR)/*.java
MAIN_CLASS = jlox.lox.Lox

# Default target
all: jlox clox

# Create build directory and compile all Java files
jlox:
	mkdir -p $(JBUILD_DIR)
	$(JC) $(JFLAGS) $(SRC_FILES)

#####################
# C Implementation
#####################

# Variables for clox
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
CLOX_SRC_DIR = clox
CLOX_BUILD_DIR = clox/build
CLOX_SOURCES = $(wildcard $(CLOX_SRC_DIR)/*.c)
CLOX_OBJECTS = $(patsubst $(CLOX_SRC_DIR)/%.c,$(CLOX_BUILD_DIR)/%.o,$(CLOX_SOURCES))
CLOX_EXECUTABLE = $(CLOX_BUILD_DIR)/clox

# Create clox build directory
$(CLOX_BUILD_DIR):
	mkdir -p $(CLOX_BUILD_DIR)

# Compile each C file into an object file
$(CLOX_BUILD_DIR)/%.o: $(CLOX_SRC_DIR)/%.c | $(CLOX_BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Link all object files into the executable
$(CLOX_EXECUTABLE): $(CLOX_OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^

# Build clox
clox: $(CLOX_EXECUTABLE)

#####################
# Shared targets
#####################

# Clean build directories
clean:
	rm -rf $(JBUILD_DIR)
	rm -rf $(CLOX_BUILD_DIR)

# Run jlox REPL
jlox-repl: jlox
	$(JVM) -cp $(JBUILD_DIR) $(MAIN_CLASS)

# Run clox REPL
clox-repl: clox
	$(CLOX_EXECUTABLE)

# Run clox with file input
clox-run: clox
	@if [ "$(words $(MAKECMDGOALS))" -gt 1 ]; then \
		$(CLOX_EXECUTABLE) $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)); \
	else \
		$(CLOX_EXECUTABLE); \
	fi

# Run jlox with file input or REPL if no file is specified
jlox-run: jlox
	@if [ "$(words $(MAKECMDGOALS))" -gt 1 ]; then \
		$(JVM) -cp $(JBUILD_DIR) $(MAIN_CLASS) $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)); \
	else \
		$(JVM) -cp $(JBUILD_DIR) $(MAIN_CLASS); \
	fi

# Run AstPrinter
ast: jlox
	$(JVM) -cp $(JBUILD_DIR) lox.AstPrinter

# Run GenerateAst tool
gen_ast: 
	$(JC) -d build tool/GenerateAst.java
	$(JVM) -cp build tool.GenerateAst $(SRC_DIR)

# Help target
help:
	@echo "Lox Interpreter Makefile"
	@echo "-------------------------"
	@echo "Available targets:"
	@echo "  make all            - Build both jlox and clox"
	@echo "  make jlox           - Compile jlox (Java implementation)"
	@echo "  make clox           - Compile clox (C implementation)"
	@echo "  make clean          - Remove compiled files for both implementations"
	@echo "  make jlox-repl      - Run jlox in interactive REPL mode"
	@echo "  make jlox-run       - Run jlox in interactive REPL mode"
	@echo "  make jlox-run <file> - Run jlox with script file"
	@echo "  make clox-repl      - Run clox in interactive REPL mode"
	@echo "  make clox-run       - Run clox in interactive REPL mode"
	@echo "  make clox-run <file> - Run clox with script file"
	@echo "  make ast            - Run the AstPrinter example" 
	@echo "  make gen_ast        - Generate AST classes"
	@echo "  make help           - Show this help message"

# This is a special target to handle arguments passed to the run target
%:
	@:

.PHONY: all jlox clox clean jlox-repl clox-repl jlox-run clox-run ast gen_ast help
