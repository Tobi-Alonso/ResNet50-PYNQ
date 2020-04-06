

# CHANGE DESIGN NAME HERE
set design_name resnet50


# TODO: this file should source non-automatic variables to from a single configuration point
# for now they can be redundant and must match Makefile variables:
# PACK_WEIGHTS, DEVICE, RESBLOCK_BAKEDIN_IPS, RESBLOCK_STREAMED_IPS

#TODO: generate this list from SLR number argument
set enable_clk2 1 
set single_streamer_layers {  }
set pack_streamer_layers { res4a res4b res4c res4d res4e res4f res5a res5b res5c }
set SLRs_with_mem_subsystem { 1 2 3 }
set layer_floorplan {
  { inoutdma preres res3d postres }    
  { res2a res3c res4a res4b res5c } 
  { res2b res3b res4c res4d res5b } 
  { res2c res3a res4e res4f res5a } 
}

# automatic configurations
set number_of_SLRs [ llength $layer_floorplan ]
set available_SLRs ""
for {set i 0} {$i < $number_of_SLRs} {incr i} {
	lappend available_SLRs $i
}

if { $enable_clk2} {
  set RST_list [list 0 1]
} else {
  set RST_list [list 0]
}

# create IP floorplan
set ip_floorplan {}
foreach SLR $available_SLRs {
	set IPs_in_SLR [lindex $layer_floorplan $SLR ]

	#add single layer streamers
	foreach layer [lindex $layer_floorplan $SLR ] {
	 	set in_slr [ lsearch  ${single_streamer_layers}  $layer ]
	  	if { $in_slr ne -1 } {
	  		lappend IPs_in_SLR ${layer}_streamer
		}
	}

	#is there any mem_subssystem in this SLR?
	# set in_slr [ lsearch $SLRs_with_mem_subsystem $SLR ]
	# if { $in_slr ne -1 } {
 #  		lappend IPs_in_SLR mem_subsystem_slr${SLR}
	# }

	lappend ip_floorplan $IPs_in_SLR
}
