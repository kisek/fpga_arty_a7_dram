/** main.v for Arty A7-35T (xc7a35ticsg324-1L)          ArchLab, Institute of Science Tokyo **/
/** DDR3 SDRAM: MT41K128M16XX-15E for MT41K128M16JT-125 of Arty A7-35T                      **/
/*********************************************************************************************/
`default_nettype none

`ifdef SYNTHESIS
`define LAST_ADDRESS     25'h1ffffff  // for FPGA run
`else
`define LAST_ADDRESS     25'h1ffff    // for simulation
`endif

`define DDR3_DQ__WIDTH   16
`define DDR3_DQS_WIDTH   2
`define DDR3_ADR_WIDTH   14
`define DDR3_BA__WIDTH   3
`define DDR3_DM__WIDTH   2
`define APP_ADDR_WIDTH   28
`define APP_CMD__WIDTH   3
`define APP_DATA_WIDTH   128
`define APP_MASK_WIDTH   16
`define CMD_READ         3'b001
`define CMD_WRITE        3'b000
         
module m_main (
    input  wire w_clk,                              // 100MHz clock signal
    output wire [3:0] w_led,                        // LED
    inout  wire [`DDR3_DQ__WIDTH-1 : 0]  ddr3_dq,
    inout  wire [`DDR3_DQS_WIDTH-1 : 0]  ddr3_dqs_n,
    inout  wire [`DDR3_DQS_WIDTH-1 : 0]  ddr3_dqs_p,
    output wire [`DDR3_ADR_WIDTH-1 : 0]  ddr3_addr,
    output wire [`DDR3_BA__WIDTH-1 : 0]  ddr3_ba,
    output wire                          ddr3_ras_n,
    output wire                          ddr3_cas_n,
    output wire                          ddr3_we_n,
    output wire                          ddr3_reset_n,
    output wire [0:0]                    ddr3_ck_p,
    output wire [0:0]                    ddr3_ck_n,
    output wire [0:0]                    ddr3_cke,
    output wire [0:0]                    ddr3_cs_n,
    output wire [`DDR3_DM__WIDTH-1 : 0]  ddr3_dm,
    output wire [0:0]                    ddr3_odt
);

    wire                         sys_clk;     // input clock (166.67MHz),
    wire                         ref_clk;     // reference clock (200MHz),
    wire                         sys_rst = 0; // reset (active-high)
    clk_wiz_0 m0 (sys_clk, ref_clk, w_clk);
        
    reg  [`APP_ADDR_WIDTH-1 : 0] r_app_addr = 0;
    reg  [`APP_CMD__WIDTH-1 : 0] r_app_cmd  = 0;
    reg                          r_app_en = 0;  
    reg                          r_app_wdf_wren = 0;
    reg  [`APP_DATA_WIDTH-1 : 0] r_app_wdf_data = {32'h1, 32'h1, 32'h1, 32'h1};
    reg  [`APP_MASK_WIDTH-1 : 0] r_app_wdf_mask = 0;
    
    wire [`APP_DATA_WIDTH-1 : 0] app_rd_data;
    wire                         app_rd_data_valid;
    wire                         app_rdy;
    wire                         app_wdf_rdy;

    wire                         w_ui_clk; // 333.33MHz / 4 = 83.33MHz
    wire                         init_calib_complete;

    reg [3:0] r_state = 0;
    reg [31:0] r_sum = 0;
    always @(posedge w_ui_clk) if (init_calib_complete) begin
       if (r_state==0 && app_rdy && app_wdf_rdy) begin  ///// WRITE_1
           r_app_en       <= 1;
           r_app_wdf_wren <= 1;         
           r_app_cmd      <= `CMD_WRITE;
           r_state        <= 1;
       end
       else if (r_state==1) begin ///// WRITE_2
           if (app_rdy && app_wdf_rdy && r_app_en) begin
               r_app_en <= 0; 
               r_app_wdf_wren <= 0; 
           end
           if (r_app_en==0 && r_app_wdf_wren==0) begin
               r_app_addr <= r_app_addr + 8;
               r_state <= (r_app_addr[27:3]==`LAST_ADDRESS) ? 2 : 0;
           end
       end
       else if (r_state==2) begin ///// INIT_FOR_READ
           r_app_addr <= 0;
           r_state    <= 3;
       end
       else if (r_state==3 && app_rdy) begin ///// READ_1
           r_app_en       <= 1;
           r_app_wdf_wren <= 0;
           r_app_cmd      <= `CMD_READ;
           r_state        <= 4;
       end
       else if (r_state==4) begin  ///// READ_2
           if (app_rdy && r_app_en) r_app_en <= 0;
           if (app_rd_data_valid) begin
               r_app_addr <= r_app_addr + 8;
               r_sum <= r_sum + app_rd_data[31:0];
               r_state <= (r_app_addr[27:3]==`LAST_ADDRESS) ? 5 : 3;
           end
       end
    end
    assign w_led = {init_calib_complete, r_state[2:0]};
        
    vio_0 vio0 (w_ui_clk, r_app_addr, r_sum);
    
    mig_7series_0 mig (
       .ddr3_addr           (ddr3_addr),  /// dram interface signals
       .ddr3_ba             (ddr3_ba),
       .ddr3_cas_n          (ddr3_cas_n),
       .ddr3_ck_n           (ddr3_ck_n),
       .ddr3_ck_p           (ddr3_ck_p),
       .ddr3_cke            (ddr3_cke),
       .ddr3_ras_n          (ddr3_ras_n),
       .ddr3_we_n           (ddr3_we_n),
       .ddr3_dq             (ddr3_dq),
       .ddr3_dqs_n          (ddr3_dqs_n),
       .ddr3_dqs_p          (ddr3_dqs_p),
       .ddr3_reset_n        (ddr3_reset_n),
       .ddr3_cs_n           (ddr3_cs_n),
       .ddr3_dm             (ddr3_dm),
       .ddr3_odt            (ddr3_odt),
       .app_addr            (r_app_addr),  /// application interface signals
       .app_cmd             (r_app_cmd),
       .app_en              (r_app_en),
       .app_wdf_data        (r_app_wdf_data),
       .app_wdf_end         (r_app_wdf_wren),
       .app_wdf_wren        (r_app_wdf_wren),
       .app_wdf_mask        (r_app_wdf_mask),
       .app_rd_data         (app_rd_data),
       .app_rd_data_valid   (app_rd_data_valid),
       .app_rd_data_end     (),
       .app_rdy             (app_rdy),
       .app_wdf_rdy         (app_wdf_rdy),
       .app_sr_req          (1'b0),
       .app_ref_req         (1'b0),
       .app_zq_req          (1'b0),
       .app_sr_active       (),
       .app_ref_ack         (),
       .app_zq_ack          (),
       .ui_clk              (w_ui_clk),
       .ui_clk_sync_rst     (),
       .init_calib_complete (init_calib_complete),
       .device_temp         (),
       .sys_clk_i           (sys_clk),  // input clock (166.67MHz)
       .clk_ref_i           (ref_clk),  // reference clock (200MHz)
       .sys_rst             (sys_rst)); // reset (active-high)
endmodule
