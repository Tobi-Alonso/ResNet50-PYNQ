#  Copyright (c) 2019, Xilinx
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#  
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

PLATFORM ?= "xilinx_u250_xdma_201830_2"
# PLATFORM ?= "xilinx_u280_xdma_201920_1"
XO_INPUT=../compile/resnet50.xo
KERNEL = resnet50
XCLBIN_OUTPUT=$(KERNEL).xclbin
XCLBIN_COMPUTE_MHZ ?= 200
XCLBIN_MEMORY_MHZ ?= 400
XCLBIN_FREQ_OPTS := "0:$(XCLBIN_COMPUTE_MHZ)|1:$(XCLBIN_MEMORY_MHZ)"
XCLBIN_OPTIMIZE := 2
#configuration defines passed to the HLS code
#can define chipscope core insertion during XOCC link
#example to add debug cores to all interfaces:
#CHIPSCOPE=--dk chipscope:$(KERNEL)_1:s_axi_control --dk chipscope:$(KERNEL)_1:m_axi_gmem0 --dk chipscope:$(KERNEL)_1:m_axi_gmem1
CHIPSCOPE=
#optional memory bank assignment, for multi-MM designs (MULTIBANK defined)
MEMBANK = 
#example dual bank assignment:
#MEMBANK=--sp $(KERNEL)_1.gmem0:bank2 --sp $(KERNEL)_1.gmem1:bank3
#floorplanning
FLOORPLAN=`pwd`/floorplan.tcl

# TODO:  The option 'xp' is deprecated
# test: FLOORPLAN_OPTS= --vivado_prop:run.impl_1.STEPS.OPT_DESIGN.TCL.POST=$(FLOORPLAN)
FLOORPLAN_OPTS=--xp vivado_prop:run.impl_1.STEPS.OPT_DESIGN.TCL.POST=$(FLOORPLAN)
#profiling
#example to add profiling to all kernels
#PROFILE_OPTS=--profile_kernel data:all:all:all
PROFILE_OPTS=

# Config for HBM instead of DDR:
# MEM_MAP := --connectivity.sp resnet50_1.in:HBM[0:31]
# MEM_MAP := $(MEM_MAP) --connectivity.sp resnet50_1.out:HBM[0:31]
# MEM_MAP := $(MEM_MAP) --connectivity.sp resnet50_1.weightsmem:HBM[0:31]

all: $(XCLBIN_OUTPUT)

$(XCLBIN_OUTPUT): $(XO_INPUT)
	v++ --link --target hw $(PROFILE_OPTS) --kernel_frequency $(XCLBIN_FREQ_OPTS) $(MEM_MAP)  --save-temps -R2 --optimize $(XCLBIN_OPTIMIZE) $(CHIPSCOPE) $(MEMBANK) --platform $(PLATFORM) $(FLOORPLAN_OPTS) $< -o $@

.PHONY=clean
clean:
	-git clean -xfd
