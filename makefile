# Compiler
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2

# Executable name
TARGET = restaurant-finder

# Source files
SRCS = main.cc

# Default rule (build)
all: $(TARGET)

# Build the executable
$(TARGET): $(SRCS)
	$(CXX) $(CXXFLAGS) $(SRCS) -o $(TARGET)

# Run the program
run: $(TARGET)
	./$(TARGET)

# Windows support for 'make run'
runw: $(TARGET)
	$(TARGET).exe

# Clean generated files
clean:
	rm -f $(TARGET) $(TARGET).exe

# Rebuild from scratch
rebuild: clean all

# Convenience alias
clear: clean
