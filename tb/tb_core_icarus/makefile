###############################################################################
# Variables: Program ELF
###############################################################################
ELF_FILE ?= test.elf

OBJCOPY ?= riscv32-unknown-elf-objcopy
ifeq ($(shell which $(OBJCOPY)),)
  ${error $(OBJCOPY) missing from PATH}
endif
ifeq ($(shell which iverilog),)
  ${error iverilog missing from PATH - Icarus Verilog required}
endif


###############################################################################
# Variables: Defaults
###############################################################################
DUMPDB         ?= 1
TRACE          ?= 1

SRC_V_DIR      ?= ../../src/core ../../src/defines .
SRC_DIR        ?= .

EXE            ?= output.out

###############################################################################
# Variables: Verilog
###############################################################################
SRC_V       ?= $(foreach src,$(SRC_V_DIR),$(wildcard $(src)/*.v))

VFLAGS      += $(patsubst %,-I%,$(SRC_V_DIR))
VFLAGS      += -DDUMPDB=$(DUMPDB)
VFLAGS      += -DTRACE=$(TRACE)
VFLAGS      += -Dverilog_sim
VFLAGS      += -Wall

###############################################################################
# Variables: Lists of objects, source and deps
###############################################################################
BUILD_DIR      ?= build/

###############################################################################
# Rules
###############################################################################
all: run

$(BUILD_DIR):
	@mkdir -p $@

$(BUILD_DIR)/tcm.bin: $(ELF_FILE) | $(BUILD_DIR)
	$(OBJCOPY) $< -O binary $@

$(BUILD_DIR)/$(EXE): $(SRC_V) | $(BUILD_DIR)
	@echo "# Compiling verilog"
	iverilog -o $@ $(SRC_V) $(VFLAGS)

run: $(BUILD_DIR)/$(EXE) $(BUILD_DIR)/tcm.bin
	vvp $(BUILD_DIR)/$(EXE) -lxt2

view:
	gtkwave waveform.vcd gtksettings.sav

clean:
	rm -rf $(BUILD_DIR) *.vcd

