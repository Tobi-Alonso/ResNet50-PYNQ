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

set clkfreqmhz  [lindex $::argv 0]
set device      [lindex $::argv 1]

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}


#source configuration file
source ${origin_dir}/system_config.tcl

# Set the project name
set project_name "project_1"

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set project_name $::user_project_name
}

variable script_file
set script_file "ipi.tcl"

# Help information for this script
proc help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < [llength $::argc]} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set project_name [lindex $::argv $i] }
      "--help"         { help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/project_1"]"

# Create project
create_project ${project_name} ./${project_name} -part ${device}

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Reconstruct message rules
# None

# Set project properties
set obj [current_project]
set_property -name "part" -value "$device" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "dsa.num_compute_units" -value "60" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${project_name}.cache/ip" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "$origin_dir"]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Set 'sources_1' fileset file properties for remote files
# None

# Set 'sources_1' fileset file properties for local files
# None

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Empty (no sources present)

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]


# Adding sources referenced in BDs, if not already added

############################
# Proc to create BD resnet50
############################
proc cr_bd_resnet50 { parentCell } {

  global clkfreqmhz

  global design_name
  global using_double_pumping
  global single_streamer_layers
  global SLRs_with_mem_subsystem
  global pack_streamer_layers
  global layer_floorplan
  global available_SLRs
  global RST_list
  global enable_clk2
  global ip_floorplan
  

  common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  #############
  # CHECK IPs
  #############
    set bCheckIPsPassed 1
    set bCheckIPs 1
    if { $bCheckIPs == 1 } {
      set list_check_ips "\ 
        xilinx.com:hls:res2a:1.0\
        xilinx.com:hls:res2b:1.0\
        xilinx.com:hls:res2c:1.0\
        xilinx.com:hls:res3a:1.0\
        xilinx.com:hls:res3b:1.0\
        xilinx.com:hls:res3c:1.0\
        xilinx.com:hls:res3d:1.0\
        xilinx.com:hls:res4a:1.0\
        xilinx.com:hls:res4b:1.0\
        xilinx.com:hls:res4c:1.0\
        xilinx.com:hls:res4d:1.0\
        xilinx.com:hls:res4e:1.0\
        xilinx.com:hls:res4f:1.0\
        xilinx.com:hls:res5a:1.0\
        xilinx.com:hls:res5b:1.0\
        xilinx.com:hls:res5c:1.0\
        xilinx.com:hls:inoutdma:1.0\
        xilinx.com:hls:preres:1.0\
        xilinx.com:hls:postres:1.0\
      "

    puts "CHECK IPs : Fixed list: $list_check_ips"
    foreach layer $single_streamer_layers {
      puts "CHECK IPs : Add ip: ${layer}_streamer:1.0 "
      lappend list_check_ips xilinx.com:hls:${layer}_streamer:1.0
    }

    foreach SLR $SLRs_with_mem_subsystem {
      puts "CHECK IPs : Add ip: mem_subsystem_slr${SLR}:1.0"
      lappend list_check_ips "xilinx.com:user:mem_subsystem_slr${SLR}:1.0"
    }

    puts "IP list: $list_check_ips"

    
     set list_ips_missing ""
     common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

     foreach ip_vlnv $list_check_ips {
        set ip_obj [get_ipdefs -all $ip_vlnv]
        if { $ip_obj eq "" } {
           lappend list_ips_missing $ip_vlnv
        }
     }

     if { $list_ips_missing ne "" } {
        catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
        set bCheckIPsPassed 0
     }

    }

    if { $bCheckIPsPassed != 1 } {
      common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
      return 3
    }


  #############
  # Init Block Design
  #############
    variable script_folder

    if { $parentCell eq "" } {
       set parentCell [get_bd_cells /]
    }

    # Get object for parentCell
    set parentObj [get_bd_cells $parentCell]
    if { $parentObj == "" } {
       catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
       return
    }

    # Make sure parentObj is hier blk
    set parentType [get_property TYPE $parentObj]
    if { $parentType ne "hier" } {
       catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
       return
    }

    # Save current instance; Restore later
    set oldCurInst [current_bd_instance .]

    # Set parent object as current
    current_bd_instance $parentObj


  # Create clock and reset ports according to SDx spec
    create_bd_port -dir I -type clk -freq_hz [expr {$clkfreqmhz*1000000}] ap_clk
    #set_property CONFIG.FREQ_HZ [expr {$clkfreqmhz*1000000}] [get_bd_ports ap_clk]

    create_bd_port -dir I -type rst ap_rst_n
    set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports ap_rst_n]

    if { $enable_clk2 } {
      puts "CLK & RST: Adding clk_2 and rst_2"
      create_bd_port -dir I -type clk -freq_hz [expr {$clkfreqmhz*2*1000000}] ap_clk_2  
      #set_property CONFIG.FREQ_HZ [expr {$clkfreqmhz*2*1000000}] [get_bd_ports ap_clk_2]

      create_bd_port -dir I -type rst ap_rst_n_2
      set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports ap_rst_n_2]
    }


    #create reset infrastructure
      #reset originates in SLR0 and we pipeline it using one register in each slr:
      #SLR0 -> SLR1 -> SLR2 -> SLR3
      #from each slr pipeline register, we push the reset through a BUFG to destinations
      #using a passthrough reduced logic to avoid wire type errors 
    foreach RST $RST_list {
      foreach SLR $available_SLRs {
        puts "Implementing reset ${RST} infrastructure for SLR${SLR}"

        create_bd_cell -type ip -vlnv xilinx.com:ip:c_shift_ram:12.0 rst${RST}_pipe_slr${SLR}
        set_property -dict [list CONFIG.Width.VALUE_SRC USER] [get_bd_cells rst${RST}_pipe_slr${SLR}]
        set_property -dict [list CONFIG.Width {1} CONFIG.Depth {1} CONFIG.DefaultData {0} CONFIG.AsyncInitVal {0} CONFIG.SSET {false} CONFIG.SCLR {false} CONFIG.SyncInitVal {0}] [get_bd_cells rst${RST}_pipe_slr${SLR}]
        if {$RST == 0} {
          connect_bd_net [get_bd_ports ap_clk] [get_bd_pins rst${RST}_pipe_slr${SLR}/CLK]
        } else {
          connect_bd_net [get_bd_ports ap_clk_2] [get_bd_pins rst${RST}_pipe_slr${SLR}/CLK]
        }
        if {$SLR == 0} {
          #one passthrough to remove reset attribute from net
          create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 rst${RST}_conv_in
          set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {or}] [get_bd_cells rst${RST}_conv_in]
          if {$RST == 0} {
            connect_bd_net [get_bd_ports ap_rst_n] [get_bd_pins rst${RST}_conv_in/Op1]
          } else {
            connect_bd_net [get_bd_ports ap_rst_n_2] [get_bd_pins rst${RST}_conv_in/Op1]
          }
          connect_bd_net [get_bd_pins rst${RST}_conv_in/Res] [get_bd_pins rst${RST}_pipe_slr${SLR}/D]
        } else {
          connect_bd_net [get_bd_pins rst${RST}_pipe_slr[expr {$SLR-1}]/Q] [get_bd_pins rst${RST}_pipe_slr${SLR}/D]
        }
        create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 rst${RST}_buf_slr${SLR}
        set_property -dict [list CONFIG.C_BUF_TYPE {BUFG}] [get_bd_cells rst${RST}_buf_slr${SLR}]
        connect_bd_net [get_bd_pins rst${RST}_pipe_slr${SLR}/Q] [get_bd_pins rst${RST}_buf_slr${SLR}/BUFG_I]

        create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 rst${RST}_pass_slr${SLR}
        set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {or}] [get_bd_cells rst${RST}_pass_slr${SLR}]
        connect_bd_net [get_bd_pins rst${RST}_buf_slr${SLR}/BUFG_O] [get_bd_pins rst${RST}_pass_slr${SLR}/Op1]
      }
    }

  # Create IP instances and connect them to clk and reset
    foreach SLR $available_SLRs {
      foreach ip [ lindex $ip_floorplan $SLR ] {
        create_bd_cell -type ip -vlnv xilinx.com:hls:${ip}:1.0 $ip
        connect_bd_net [get_bd_ports ap_clk] [get_bd_pins ${ip}/ap_clk] 
        connect_bd_net [get_bd_pins rst0_pass_slr${SLR}/Res] [get_bd_pins ${ip}/ap_rst_n]
      }
    }

    # add mem_subsystems
    foreach SLR $SLRs_with_mem_subsystem {
      set ip mem_subsystem_slr${SLR}
      create_bd_cell -type ip -vlnv xilinx.com:user:${ip}:1.0 ${ip}
      connect_bd_net [get_bd_ports ap_clk] [get_bd_pins ${ip}/compute_clk] 
      connect_bd_net [get_bd_pins rst0_pass_slr${SLR}/Res] [get_bd_pins ${ip}/compute_aresetn]
      if { $using_double_pumping} {
        connect_bd_net [get_bd_ports ap_clk_2] [get_bd_pins ${ip}/memory_clk] 
        connect_bd_net [get_bd_pins rst1_pass_slr${SLR}/Res] [get_bd_pins ${ip}/memory_aresetn]
      } else {
        connect_bd_net [get_bd_ports ap_clk] [get_bd_pins ${ip}/memory_clk] 
        connect_bd_net [get_bd_pins rst0_pass_slr${SLR}/Res] [get_bd_pins ${ip}/memory_aresetn]
      }

    }

  save_bd_design

  # Make AXI interfaces external and rename them to standard names
    make_bd_intf_pins_external  [get_bd_intf_pins inoutdma/m_axi_gmem0]
    make_bd_intf_pins_external  [get_bd_intf_pins inoutdma/m_axi_gmem1]
    make_bd_intf_pins_external  [get_bd_intf_pins inoutdma/m_axi_gmem2]
    make_bd_intf_pins_external  [get_bd_intf_pins inoutdma/s_axi_control]
    set_property name m_axi_gmem0 [get_bd_intf_ports m_axi_gmem0_0]
    set_property name m_axi_gmem1 [get_bd_intf_ports m_axi_gmem1_0]
    set_property name m_axi_gmem2 [get_bd_intf_ports m_axi_gmem2_0]
    set_property name s_axi_control [get_bd_intf_ports s_axi_control_0]
  
  #connect layers
    foreach SRC [list inoutdma preres res2a res2b res2c res3a res3b res3c res3d res4a res4b res4c res4d res4e res4f res5a res5b res5c postres] DST [list preres res2a res2b res2c res3a res3b res3c res3d res4a res4b res4c res4d res4e res4f res5a res5b res5c postres inoutdma] {
      set OUTWB [get_property [list CONFIG.TDATA_NUM_BYTES] [get_bd_intf_pins ${SRC}/output_V_V]]
      set INWB [get_property [list CONFIG.TDATA_NUM_BYTES] [get_bd_intf_pins ${DST}/input_V_V]]
      if {$OUTWB != $INWB} {
        puts "Connecting $SRC to $DST through data width converter (${OUTWB}B -> ${INWB}B)"
        create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 dwc_${SRC}_${DST}
        set_property -dict [list CONFIG.S_TDATA_NUM_BYTES $OUTWB] [get_bd_cells dwc_${SRC}_${DST}]
        set_property -dict [list CONFIG.M_TDATA_NUM_BYTES $INWB] [get_bd_cells dwc_${SRC}_${DST}]
        connect_bd_intf_net [get_bd_intf_pins ${SRC}/output_V_V] [get_bd_intf_pins dwc_${SRC}_${DST}/S_AXIS]
        connect_bd_intf_net [get_bd_intf_pins dwc_${SRC}_${DST}/M_AXIS] [get_bd_intf_pins ${DST}/input_V_V]
        connect_bd_net [get_bd_ports ap_clk] [get_bd_pins dwc_${SRC}_${DST}/aclk]
        
        foreach SLR $available_SLRs {
          set in_slr [lsearch [lindex $ip_floorplan $SLR ] $SRC ]
            if { $in_slr ne -1 } {
              connect_bd_net [get_bd_pins rst0_pass_slr${SLR}/Res] [get_bd_pins dwc_${SRC}_${DST}/aresetn]
              break
          }
        }
        
      } else {
        puts "Connecting $SRC to $DST directly"
        connect_bd_intf_net [get_bd_intf_pins ${SRC}/output_V_V] [get_bd_intf_pins ${DST}/input_V_V]
      }
    }

  # connect weight streams for non-packed layers
    foreach layer $single_streamer_layers {
      puts "Connecting $layer to ${layer}_streamer"
      connect_bd_intf_net [get_bd_intf_pins ${layer}_streamer/weights2a_V_V] [get_bd_intf_pins ${layer}/weights2a_V_V]
      connect_bd_intf_net [get_bd_intf_pins ${layer}_streamer/weights2b_V_V] [get_bd_intf_pins ${layer}/weights2b_V_V]
      connect_bd_intf_net [get_bd_intf_pins ${layer}_streamer/weights2c_V_V] [get_bd_intf_pins ${layer}/weights2c_V_V]
      if { [regexp {res.*a} $layer] } {
        puts "  $layer - connecting bypass weights"
        connect_bd_intf_net [get_bd_intf_pins ${layer}_streamer/weights1_V_V] [get_bd_intf_pins ${layer}/weights1_V_V]
      }
    }

    connect_bd_intf_net [get_bd_intf_pins inoutdma/weights_V_V] [get_bd_intf_pins postres/weights_V_V]


  #connect streams to per-slr packed streamers
    foreach SLR $SLRs_with_mem_subsystem {
      foreach layer [lindex $layer_floorplan $SLR ] {
        set in_slr [ lsearch  ${pack_streamer_layers}  $layer ]
          if { $in_slr ne -1 } {
            puts "Connecting $layer to mem_subsystem_slr${SLR}"
            connect_bd_intf_net [get_bd_intf_pins mem_subsystem_slr${SLR}/${layer}_2a] [get_bd_intf_pins ${layer}/weights2a_V_V]
            connect_bd_intf_net [get_bd_intf_pins mem_subsystem_slr${SLR}/${layer}_2b] [get_bd_intf_pins ${layer}/weights2b_V_V]
            connect_bd_intf_net [get_bd_intf_pins mem_subsystem_slr${SLR}/${layer}_2c] [get_bd_intf_pins ${layer}/weights2c_V_V]
            if { [regexp {res.*a} $layer] } {
              puts "  $layer - connecting bypass weights"
              connect_bd_intf_net [get_bd_intf_pins mem_subsystem_slr${SLR}/${layer}_1] [get_bd_intf_pins ${layer}/weights1_V_V]
            }
        }
      }
    }

  # Create constant 1 for start and continue lines
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
    set_property -dict [list CONFIG.CONST_VAL {1}] [get_bd_cells xlconstant_0]
    foreach ip { preres res2a res2b res2c res3a res3b res3c res3d res4a res4b res4c res4d res4e res4f res5a res5b res5c postres } {
      connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins ${ip}/ap_start]
      connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins ${ip}/ap_continue]
    }

  # Auto-assign addresses (TODO: check)
    exclude_bd_addr_seg [get_bd_addr_segs inoutdma/Data_m_axi_gmem0/SEG_m_axi_gmem0_Reg]
    exclude_bd_addr_seg [get_bd_addr_segs inoutdma/Data_m_axi_gmem1/SEG_m_axi_gmem1_Reg]
    exclude_bd_addr_seg [get_bd_addr_segs inoutdma/Data_m_axi_gmem2/SEG_m_axi_gmem2_Reg]
    exclude_bd_addr_seg [get_bd_addr_segs s_axi_control/SEG_inoutdma_Reg]

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_resnet50()

#create ResNet50 BD
cr_bd_resnet50 ""
set_property SYNTH_CHECKPOINT_MODE "Hierarchical" [ get_files resnet50.bd ] 

# Generate HDL Wrapper
make_wrapper -files [get_files resnet50.bd] -import -fileset sources_1 -top
# OOC synthesis of IPs then block design
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

generate_target all [get_files  resnet50.bd ]
export_ip_user_files -of_objects [get_files resnet50.bd ] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] resnet50.bd ]


foreach layer $single_streamer_layers {
  set_property STEPS.SYNTH_DESIGN.ARGS.FANOUT_LIMIT 100 [get_runs resnet50_${layer}_streamer_0_synth_1]
}

foreach SLR $SLRs_with_mem_subsystem {
  set_property STEPS.SYNTH_DESIGN.ARGS.FANOUT_LIMIT 100 [get_runs resnet50_mem_subsystem_slr${SLR}_0_synth_1]
}

launch_runs synth_1 -jobs 10
wait_on_run [get_runs synth_1]

#export DCP and constraints to destination IP folder
set ipdir $origin_dir/ip
if {[file exists $ipdir]} {
    file delete -force $ipdir
}
file mkdir $ipdir

open_run synth_1 -name synth_1
write_verilog -force -mode synth_stub $ipdir/resnet50.v
write_checkpoint $ipdir/resnet50.dcp
write_xdc $ipdir/resnet50.xdc

close_project
