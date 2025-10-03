###############################################
# PackingGeneration Makefile (Linux)
# Default build: Release (optimized)
# Debug build:   make debug (adds symbols, no optimization)
# Externals: Boost subset (header-only) + Eigen (header-only) -> packed into libexternals.a (single dummy object)
# Incremental: libexternals.a built once unless its sources change
###############################################

# Project names
PROJECT       := packing_generation
EXTERNALS_LIB := libexternals.a
CORE_LIB      := libpackinggeneration.a

# Directories
SRC_ROOT      := PackingGeneration
EXTERNALS_DIR := Externals
BUILD_DIR     := build
BIN_DIR       := bin
INCLUDE_DIRS  := $(SRC_ROOT) $(EXTERNALS_DIR)/Boost $(EXTERNALS_DIR)/Eigen

# Compiler & tools
CXX      ?= mpic++
AR       := ar
ARFLAGS  := rcs
RM       := rm -f
MKDIR_P  := mkdir -p

# Common warning / standard flags
STD      := -std=c++17
WARN     := -Wall -Wextra -Wpedantic -Wno-unused-parameter -Wno-long-long
DEFS     := 

# Build type flags
OPT_RELEASE := -O3 -DNDEBUG
OPT_DEBUG   := -O0 -g -DDEBUG

# Toggle parallel (MPI) build by defining PARALLEL=1 on command line
ifeq ($(PARALLEL),1)
  DEFS += -DPARALLEL
endif

# Include flags
INCLUDES := $(addprefix -I ,$(INCLUDE_DIRS))

# Source file discovery (all .cpp under project tree except tests)
CPP_SOURCES := $(shell find $(SRC_ROOT) -type f -name '*.cpp')

# Separate out main executable source (Main.cpp)
MAIN_SOURCE := $(SRC_ROOT)/Main.cpp
LIB_SOURCES := $(filter-out $(MAIN_SOURCE),$(CPP_SOURCES))

# External dummy source (ensures archive not empty)
EXTERNALS_SRC := $(EXTERNALS_DIR)/externals_dummy.cpp

# Object files per configuration
OBJ_RELEASE := $(addprefix $(BUILD_DIR)/release/,$(LIB_SOURCES:.cpp=.o))
OBJ_DEBUG   := $(addprefix $(BUILD_DIR)/debug/,$(LIB_SOURCES:.cpp=.o))
MAIN_RELEASE_OBJ := $(BUILD_DIR)/release/$(MAIN_SOURCE:.cpp=.o)
MAIN_DEBUG_OBJ   := $(BUILD_DIR)/debug/$(MAIN_SOURCE:.cpp=.o)
EXTERNALS_OBJ    := $(BUILD_DIR)/externals/externals_dummy.o

# Final artifacts
RELEASE_BIN := $(BIN_DIR)/$(PROJECT)
DEBUG_BIN   := $(BIN_DIR)/$(PROJECT)_debug
RELEASE_LIB := $(BUILD_DIR)/release/$(CORE_LIB)
DEBUG_LIB   := $(BUILD_DIR)/debug/$(CORE_LIB)
EXTERNALS_AR:= $(BUILD_DIR)/externals/$(EXTERNALS_LIB)

###############################################
# Default target = release
###############################################
.PHONY: all release debug clean distclean externals dirs

all: release

release: CXXFLAGS := $(STD) $(WARN) $(OPT_RELEASE) $(DEFS) $(INCLUDES)
release: dirs $(EXTERNALS_AR) $(RELEASE_LIB) $(RELEASE_BIN)

debug: CXXFLAGS := $(STD) $(WARN) $(OPT_DEBUG) $(DEFS) $(INCLUDES)
debug: dirs $(EXTERNALS_AR) $(DEBUG_LIB) $(DEBUG_BIN)

###############################################
# External archive (header-only libs placeholder)
###############################################
$(EXTERNALS_AR): $(EXTERNALS_OBJ)
	@echo "[AR]  $@"
	@$(AR) $(ARFLAGS) $@ $^
	@echo "External archive ready: $@"

$(EXTERNALS_OBJ): $(EXTERNALS_SRC)
	@echo "[CXX] $<"
	@$(MKDIR_P) $(dir $@)
	@$(CXX) $(CXXFLAGS) -c $< -o $@

###############################################
# Core library objects and archives
###############################################
$(RELEASE_LIB): $(OBJ_RELEASE)
	@echo "[AR]  $@"
	@$(AR) $(ARFLAGS) $@ $^

$(DEBUG_LIB): $(OBJ_DEBUG)
	@echo "[AR]  $@"
	@$(AR) $(ARFLAGS) $@ $^

###############################################
# Executables
###############################################
$(RELEASE_BIN): $(RELEASE_LIB) $(MAIN_RELEASE_OBJ) $(EXTERNALS_AR)
	@echo "[LD]  $@"
	@$(MKDIR_P) $(dir $@)
	@$(CXX) $(CXXFLAGS) $(MAIN_RELEASE_OBJ) $(RELEASE_LIB) $(EXTERNALS_AR) -o $@

$(DEBUG_BIN): $(DEBUG_LIB) $(MAIN_DEBUG_OBJ) $(EXTERNALS_AR)
	@echo "[LD]  $@"
	@$(MKDIR_P) $(dir $@)
	@$(CXX) $(CXXFLAGS) $(MAIN_DEBUG_OBJ) $(DEBUG_LIB) $(EXTERNALS_AR) -o $@

###############################################
# Pattern rules for objects
###############################################
$(BUILD_DIR)/release/%.o: %.cpp
	@echo "[CXX] $<"
	@$(MKDIR_P) $(dir $@)
	@$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/debug/%.o: %.cpp
	@echo "[CXX] $<"
	@$(MKDIR_P) $(dir $@)
	@$(CXX) $(CXXFLAGS) -c $< -o $@

###############################################
# Housekeeping
###############################################
dirs:
	@$(MKDIR_P) $(BUILD_DIR)/release $(BUILD_DIR)/debug $(BUILD_DIR)/externals $(BIN_DIR)

clean:
	@echo "Cleaning objects and binaries (keeping external archive)"
	@$(RM) -r $(BUILD_DIR)/release $(BUILD_DIR)/debug $(RELEASE_BIN) $(DEBUG_BIN)

distclean: clean
	@echo "Removing externals archive"
	@$(RM) -r $(BUILD_DIR)/externals

###############################################
# Convenience / info
###############################################
print-%:
	@echo '$*=$($*)'

help:
	@echo "Targets:"
	@echo "  all (default) -> release"
	@echo "  release       -> optimized build"
	@echo "  debug         -> debug build (make debug)"
	@echo "  clean         -> remove build artifacts except external archive"
	@echo "  distclean     -> clean + remove external archive"
	@echo "Variables: PARALLEL=1 enables MPI (default off)"
