//RES3C

#pragma HLS ARRAY_PARTITION variable=weights_FPGABipolarConvThresholdLayer_br2a.m_weights complete dim=1
#pragma HLS RESOURCE variable=weights_FPGABipolarConvThresholdLayer_br2a.m_weights core=ROM_1P_LUTRAM

#pragma HLS ARRAY_PARTITION variable=weights_FPGABipolarConvThresholdLayer_br2b.m_weights complete dim=1
#pragma HLS RESOURCE variable=weights_FPGABipolarConvThresholdLayer_br2b core=ROM_1P_LUTRAM

#pragma HLS ARRAY_PARTITION variable=weights_FPGABipolarConvThresholdLayer_br2c.m_weights complete dim=1
#pragma HLS RESOURCE variable=weights_FPGABipolarConvThresholdLayer_br2c.m_weights core=ROM_1P_LUTRAM
