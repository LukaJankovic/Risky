SHELL := /bin/bash

VIVADO=/opt/Xilinx/Vivado/2022.2

TB=r_tb

all: sim clean

sim:
	source $(VIVADO)/settings64.sh && \
	xvhdl *.vhd && \
	xelab -debug typical -top $(TB) -snapshot $(TB)_snapshot && \
	xsim $(TB)_snapshot --gui

.PHONY: clean
clean:
	rm -rf *.log *.jou *.wdb *.pb xsim.dir .Xil