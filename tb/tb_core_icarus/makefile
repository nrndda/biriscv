###############################################################################
# Variables: Program ELF
###############################################################################
ELF_FILE ?= test.elf

ENTRY := $(shell od -j24 -An -tu4 -N4 $(ELF_FILE) | tr -d '[:space:]')
ENTRY_HEX := $(shell printf '0x%.8x' $(ENTRY) )

# PRINT_ADDR_HEX := UART_DATA_ADDRESS
PRINT_ADDR_HEX := 0x$(shell nm $(ELF_FILE) | grep printer_char | cut -d " " -f -1 | tr -d '[:space:]')
PRINT_ADDR := $(shell printf '%d' $(PRINT_ADDR_HEX) )

OBJCOPY ?= riscv32-unknown-elf-objcopy
OBJDUMP ?= riscv32-unknown-elf-objdump
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
PRINTER2STDO   ?= 1
PRINTER2FILE   ?= 1

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
VFLAGS      += -DPRINTER2STDO=$(PRINTER2STDO)
VFLAGS      += -DPRINTER2FILE=$(PRINTER2FILE)
VFLAGS      += -Dverilog_sim
VFLAGS      += -DRESET_VECTOR=$(ENTRY)
VFLAGS      += -DPRINTER_ADDR_START=$(PRINT_ADDR)
VFLAGS      += -DPRINTER_ADDR_SIZE=1
VFLAGS      += -Wall
VVPFLAGS    += -n
VVPEXT      += -lxt2

###############################################################################
# Variables: Lists of objects, source and deps
###############################################################################
BUILD_DIR      ?= build
RUN_DIR        ?= run
###############################################################################
# Rules
###############################################################################
.PHONY: waves trace clean
.PHONY: $(BUILD_DIR)/tcm.dis $(BUILD_DIR)/tcm.bin $(BUILD_DIR)/tcm.vh

all: sim

$(BUILD_DIR):
	@mkdir -p $@

$(RUN_DIR):
	@mkdir -p $@

$(BUILD_DIR)/tcm.dis: $(ELF_FILE)
	$(OBJDUMP) -d $(ELF_FILE) > $@

$(BUILD_DIR)/tcm.bin: $(ELF_FILE) $(BUILD_DIR)
	$(OBJCOPY) $< -O binary $@

$(BUILD_DIR)/tcm.vh: $(ELF_FILE) $(BUILD_DIR)
	$(OBJCOPY) $< -O verilog $@

$(BUILD_DIR)/$(EXE): $(SRC_V) $(BUILD_DIR) $(BUILD_DIR)/tcm.bin
	iverilog $(VFLAGS) -o $@ $(SRC_V)

sim: $(BUILD_DIR)/$(EXE) $(BUILD_DIR) $(RUN_DIR)
	@echo "# ELF Entry Point:" $(ENTRY_HEX)
	@echo "# Printer address:" $(PRINT_ADDR_HEX)
	vvp $(VVPFLAGS) $< $(VVPEXT)

waves:
	@gtkwave $(RUN_DIR)/waveform.vcd gtksettings.sav

trace:
	@python3 showtrace.py $(RUN_DIR)/testbench.trace $(ELF_FILE)

clean:
	rm -rf $(BUILD_DIR) $(RUN_DIR)

