	ECE423_QSYS u0 (
		.button_pio_export                            (<connected-to-button_pio_export>),                            //         button_pio.export
		.clk_125_clk                                  (<connected-to-clk_125_clk>),                                  //            clk_125.clk
		.clk_50_clk                                   (<connected-to-clk_50_clk>),                                   //             clk_50.clk
		.cpu_0_reset_cpu_resetrequest                 (<connected-to-cpu_0_reset_cpu_resetrequest>),                 //        cpu_0_reset.cpu_resetrequest
		.cpu_0_reset_cpu_resettaken                   (<connected-to-cpu_0_reset_cpu_resettaken>),                   //                   .cpu_resettaken
		.cpu_1_reset_cpu_resetrequest                 (<connected-to-cpu_1_reset_cpu_resetrequest>),                 //        cpu_1_reset.cpu_resetrequest
		.cpu_1_reset_cpu_resettaken                   (<connected-to-cpu_1_reset_cpu_resettaken>),                   //                   .cpu_resettaken
		.i2c_scl_export                               (<connected-to-i2c_scl_export>),                               //            i2c_scl.export
		.i2c_sda_export                               (<connected-to-i2c_sda_export>),                               //            i2c_sda.export
		.key_export                                   (<connected-to-key_export>),                                   //                key.export
		.ledg_export                                  (<connected-to-ledg_export>),                                  //               ledg.export
		.ledr_export                                  (<connected-to-ledr_export>),                                  //               ledr.export
		.lpddr2_mem_ca                                (<connected-to-lpddr2_mem_ca>),                                //             lpddr2.mem_ca
		.lpddr2_mem_ck                                (<connected-to-lpddr2_mem_ck>),                                //                   .mem_ck
		.lpddr2_mem_ck_n                              (<connected-to-lpddr2_mem_ck_n>),                              //                   .mem_ck_n
		.lpddr2_mem_cke                               (<connected-to-lpddr2_mem_cke>),                               //                   .mem_cke
		.lpddr2_mem_cs_n                              (<connected-to-lpddr2_mem_cs_n>),                              //                   .mem_cs_n
		.lpddr2_mem_dm                                (<connected-to-lpddr2_mem_dm>),                                //                   .mem_dm
		.lpddr2_mem_dq                                (<connected-to-lpddr2_mem_dq>),                                //                   .mem_dq
		.lpddr2_mem_dqs                               (<connected-to-lpddr2_mem_dqs>),                               //                   .mem_dqs
		.lpddr2_mem_dqs_n                             (<connected-to-lpddr2_mem_dqs_n>),                             //                   .mem_dqs_n
		.lpddr2_oct_rzqin                             (<connected-to-lpddr2_oct_rzqin>),                             //         lpddr2_oct.rzqin
		.lpddr2_pll_ref_clk_clk                       (<connected-to-lpddr2_pll_ref_clk_clk>),                       // lpddr2_pll_ref_clk.clk
		.lpddr2_pll_sharing_pll_mem_clk               (<connected-to-lpddr2_pll_sharing_pll_mem_clk>),               // lpddr2_pll_sharing.pll_mem_clk
		.lpddr2_pll_sharing_pll_write_clk             (<connected-to-lpddr2_pll_sharing_pll_write_clk>),             //                   .pll_write_clk
		.lpddr2_pll_sharing_pll_locked                (<connected-to-lpddr2_pll_sharing_pll_locked>),                //                   .pll_locked
		.lpddr2_pll_sharing_pll_write_clk_pre_phy_clk (<connected-to-lpddr2_pll_sharing_pll_write_clk_pre_phy_clk>), //                   .pll_write_clk_pre_phy_clk
		.lpddr2_pll_sharing_pll_addr_cmd_clk          (<connected-to-lpddr2_pll_sharing_pll_addr_cmd_clk>),          //                   .pll_addr_cmd_clk
		.lpddr2_pll_sharing_pll_avl_clk               (<connected-to-lpddr2_pll_sharing_pll_avl_clk>),               //                   .pll_avl_clk
		.lpddr2_pll_sharing_pll_config_clk            (<connected-to-lpddr2_pll_sharing_pll_config_clk>),            //                   .pll_config_clk
		.lpddr2_pll_sharing_pll_mem_phy_clk           (<connected-to-lpddr2_pll_sharing_pll_mem_phy_clk>),           //                   .pll_mem_phy_clk
		.lpddr2_pll_sharing_afi_phy_clk               (<connected-to-lpddr2_pll_sharing_afi_phy_clk>),               //                   .afi_phy_clk
		.lpddr2_pll_sharing_pll_avl_phy_clk           (<connected-to-lpddr2_pll_sharing_pll_avl_phy_clk>),           //                   .pll_avl_phy_clk
		.lpddr2_status_local_init_done                (<connected-to-lpddr2_status_local_init_done>),                //      lpddr2_status.local_init_done
		.lpddr2_status_local_cal_success              (<connected-to-lpddr2_status_local_cal_success>),              //                   .local_cal_success
		.lpddr2_status_local_cal_fail                 (<connected-to-lpddr2_status_local_cal_fail>),                 //                   .local_cal_fail
		.reset_reset_n                                (<connected-to-reset_reset_n>),                                //              reset.reset_n
		.reset_bridge_reset                           (<connected-to-reset_bridge_reset>),                           //       reset_bridge.reset
		.sd_sd_clk                                    (<connected-to-sd_sd_clk>),                                    //                 sd.sd_clk
		.sd_sd_cmd                                    (<connected-to-sd_sd_cmd>),                                    //                   .sd_cmd
		.sd_sd_dat                                    (<connected-to-sd_sd_dat>),                                    //                   .sd_dat
		.sram_memory_tcm_chipselect_n_out             (<connected-to-sram_memory_tcm_chipselect_n_out>),             //               sram.memory_tcm_chipselect_n_out
		.sram_memory_tcm_byteenable_n_out             (<connected-to-sram_memory_tcm_byteenable_n_out>),             //                   .memory_tcm_byteenable_n_out
		.sram_memory_tcm_address_out                  (<connected-to-sram_memory_tcm_address_out>),                  //                   .memory_tcm_address_out
		.sram_memory_tcm_data_out                     (<connected-to-sram_memory_tcm_data_out>),                     //                   .memory_tcm_data_out
		.sram_memory_tcm_write_n_out                  (<connected-to-sram_memory_tcm_write_n_out>),                  //                   .memory_tcm_write_n_out
		.sram_memory_tcm_outputenable_n_out           (<connected-to-sram_memory_tcm_outputenable_n_out>),           //                   .memory_tcm_outputenable_n_out
		.video_RGB_OUT                                (<connected-to-video_RGB_OUT>),                                //              video.RGB_OUT
		.video_HD                                     (<connected-to-video_HD>),                                     //                   .HD
		.video_VD                                     (<connected-to-video_VD>),                                     //                   .VD
		.video_DEN                                    (<connected-to-video_DEN>),                                    //                   .DEN
		.video_clk_clk                                (<connected-to-video_clk_clk>)                                 //          video_clk.clk
	);

