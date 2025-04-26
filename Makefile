# Makefile for Lox interpreter

# Variables
JC = javac
JFLAGS = -d build
JVM = java
BUILD_DIR = build
SRC_DIR = lox
SRC_FILES = $(SRC_DIR)/*.java
MAIN_CLASS = lox.Lox

# Default target
all: compile

# Create build directory and compile all Java files
compile:
	mkdir -p $(BUILD_DIR)
	$(JC) $(JFLAGS) $(SRC_FILES)

# Clean build directory
clean:
	rm -rf $(BUILD_DIR)

# Run REPL mode
repl: compile
	$(JVM) -cp $(BUILD_DIR) $(MAIN_CLASS)

# Run with file input or REPL if no file is specified
run: compile
	@if [ "$(words $(MAKECMDGOALS))" -gt 1 ]; then \
		$(JVM) -cp $(BUILD_DIR) $(MAIN_CLASS) $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)); \
	else \
		$(JVM) -cp $(BUILD_DIR) $(MAIN_CLASS); \
	fi

# Run AstPrinter
ast: compile
	$(JVM) -cp $(BUILD_DIR) lox.AstPrinter

# Run GenerateAst tool
gen_ast: 
	$(JC) -d build tool/GenerateAst.java
	$(JVM) -cp build tool.GenerateAst $(SRC_DIR)

# Help target
help:
	@echo "Lox Interpreter Makefile"
	@echo "-------------------------"
	@echo "Available targets:"
	@echo "  make compile    - Compile all Java files"
	@echo "  make clean      - Remove compiled class files"
	@echo "  make repl       - Run Lox in interactive REPL mode (same as make run)"
	@echo "  make run        - Run Lox in interactive REPL mode"
	@echo "  make run <file> - Run Lox with script file"
	@echo "  make ast        - Run the AstPrinter example" 
	@echo "  make gen_ast    - Generate AST classes"
	@echo "  make help       - Show this help message"

# This is a special target to handle arguments passed to the run target
%:
	@:

.PHONY: all compile clean repl run ast gen_ast help
