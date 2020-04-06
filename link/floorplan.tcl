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


#contents of this script are run after opt_design and before placement
# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

#source configuration file
source ${origin_dir}/../compile/system_config.tcl

foreach SLR $available_SLRs {
	foreach ip [lindex $ip_floorplan $SLR ] {
		add_cells_to_pblock pblock_dynamic_SLR${SLR} [get_cells [list pfm_top_i/dynamic_region/resnet50_1/resnet50_i/${ip}]] -clear_locs
	}
}

foreach SLR $SLRs_with_mem_subsystem {
	add_cells_to_pblock pblock_dynamic_SLR${SLR} [get_cells [list pfm_top_i/dynamic_region/resnet50_1/resnet50_i/mem_subsystem_slr${SLR}]] -clear_locs
}

#rst pipe

foreach SLR $available_SLRs {
	add_cells_to_pblock pblock_dynamic_SLR${SLR} [get_cells [list pfm_top_i/dynamic_region/resnet50_1/resnet50_i/rst0_pipe_slr${SLR}]] -clear_locs
	add_cells_to_pblock pblock_dynamic_SLR${SLR} [get_cells [list pfm_top_i/dynamic_region/resnet50_1/resnet50_i/rst0_buf_slr${SLR}]] -clear_locs 	
}


if { $enable_clk2 } {
	foreach SLR $SLRs_with_mem_subsystem {
		add_cells_to_pblock pblock_dynamic_SLR${SLR} [get_cells [list pfm_top_i/dynamic_region/resnet50_1/resnet50_i/rst1_pipe_slr${SLR}]] -clear_locs
		add_cells_to_pblock pblock_dynamic_SLR${SLR} [get_cells [list pfm_top_i/dynamic_region/resnet50_1/resnet50_i/rst1_buf_slr${SLR}]] -clear_locs 	
	}	
}

