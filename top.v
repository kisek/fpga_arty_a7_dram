/** top.v for dram.v simulation Version v2024-10-30a    ArchLab, Institute of Science Tokyo **/
/** DDR3 SDRAM: MT41K128M16XX-15E for MT41K128M16JT-125 of Arty A7-35T                      **/
/*********************************************************************************************/
`ifndef SYNTHESIS

`default_nettype none

`define READ_DELAY      10

`define MEM_TXT         "sample1.txt"
`define MAX_CYCLES      100000000
`define DDR3_DQ__WIDTH  16
`define DDR3_DQS_WIDTH  2
`define DDR3_ADR_WIDTH  14
`define DDR3_BA__WIDTH  3
`define DDR3_DM__WIDTH  2

/*********************************************************************************************/
module top;
    reg r_clk   = 1'b0; always  #10  r_clk   <= !r_clk  ;
    reg r_rst_n = 1'b0; initial #100 r_rst_n  = 1'b1    ;

//    initial begin
//        $dumpfile("dump.fst");
//        $dumpvars(0);
//    end

    wire                 [3:0] w_led            ;

    wire [`DDR3_DQ__WIDTH-1:0] ddr3_dq          ;
    wire [`DDR3_DQS_WIDTH-1:0] ddr3_dqs_n       ;
    wire [`DDR3_DQS_WIDTH-1:0] ddr3_dqs_p       ;
    wire [`DDR3_ADR_WIDTH-1:0] ddr3_addr        ;
    wire [`DDR3_BA__WIDTH-1:0] ddr3_ba          ;
    wire                       ddr3_ras_n       ;
    wire                       ddr3_cas_n       ;
    wire                       ddr3_we_n        ;
    wire                       ddr3_reset_n     ;
    wire                 [0:0] ddr3_ck_p        ;
    wire                 [0:0] ddr3_ck_n        ;
    wire                 [0:0] ddr3_cke         ;
    wire                 [0:0] ddr3_cs_n        ;
    wire [`DDR3_DM__WIDTH-1:0] ddr3_dm          ;
    wire                 [0:0] ddr3_odt         ;

    m_main dram (
        .w_clk              (r_clk              ), // input  wire                      
        .w_led              (w_led              ), // output wire                 [3:0]
        .ddr3_dq            (ddr3_dq            ), // inout  wire [`DDR3_DQ__WIDTH-1:0]
        .ddr3_dqs_n         (ddr3_dqs_n         ), // inout  wire [`DDR3_DQS_WIDTH-1:0]
        .ddr3_dqs_p         (ddr3_dqs_p         ), // inout  wire [`DDR3_DQS_WIDTH-1:0]
        .ddr3_addr          (ddr3_addr          ), // output wire [`DDR3_ADR_WIDTH-1:0]
        .ddr3_ba            (ddr3_ba            ), // output wire [`DDR3_BA__WIDTH-1:0]
        .ddr3_ras_n         (ddr3_ras_n         ), // output wire
        .ddr3_cas_n         (ddr3_cas_n         ), // output wire
        .ddr3_we_n          (ddr3_we_n          ), // output wire
        .ddr3_reset_n       (ddr3_reset_n       ), // output wire
        .ddr3_ck_p          (ddr3_ck_p          ), // output wire                 [0:0]
        .ddr3_ck_n          (ddr3_ck_n          ), // output wire                 [0:0]
        .ddr3_cke           (ddr3_cke           ), // output wire                 [0:0]
        .ddr3_cs_n          (ddr3_cs_n          ), // output wire                 [0:0]
        .ddr3_dm            (ddr3_dm            ), // output wire [`DDR3_DM__WIDTH-1:0]
        .ddr3_odt           (ddr3_odt           )  // output wire                 [0:0]
    );

    reg [63:0] r_cycle  = 0   ;
    always @(posedge dram.w_ui_clk) r_cycle <= r_cycle + 1;
      
    always @(posedge dram.w_ui_clk) begin
        if (r_cycle>=`MAX_CYCLES) begin
            $write("\n");
            $write("Simulation time out specified by MAX_CYCLES\n\n");
            $finish();
        end
    end

    always @(posedge dram.w_ui_clk) begin
        if (dram.r_state==5) begin // NOTE
            $write("\n");
            $write("r_sum: %0d\n"   , dram.r_sum);
            $write("Simulation finish at cycle %0d\n\n", r_cycle);
            $finish();
        end
    end

endmodule

/*********************************************************************************************/
module clk_wiz_0 (
    output wire clk_out1    ,
    output wire clk_out2    ,
    input  wire clk_in1
);

    reg clk_200_00000_mhz = 1'b0; always #5 clk_200_00000_mhz <= !clk_200_00000_mhz;
    reg clk_166_66667_mhz = 1'b0; always #6 clk_166_66667_mhz <= !clk_166_66667_mhz;

    assign clk_out1 = clk_200_00000_mhz ;
    assign clk_out2 = clk_166_66667_mhz ;
endmodule

/*********************************************************************************************/
module vio_0 (
    input wire        clk       ,
    input wire [27:0] probe_in0 ,
    input wire [31:0] probe_in1
);
endmodule

/*********************************************************************************************/
module mig_7series_0 #(
    parameter  DRAM_SIZE    = (2*1024*1024) // 2 MiB
) (
    inout  wire [`DDR3_DQ__WIDTH-1:0] ddr3_dq                   ,
    inout  wire [`DDR3_DQS_WIDTH-1:0] ddr3_dqs_n                ,
    inout  wire [`DDR3_DQS_WIDTH-1:0] ddr3_dqs_p                ,
    output wire [`DDR3_ADR_WIDTH-1:0] ddr3_addr                 ,
    output wire [`DDR3_BA__WIDTH-1:0] ddr3_ba                   ,
    output wire                       ddr3_ras_n                ,
    output wire                       ddr3_cas_n                ,
    output wire                       ddr3_we_n                 ,
    output wire                       ddr3_reset_n              ,
    output wire                 [0:0] ddr3_ck_p                 ,
    output wire                 [0:0] ddr3_ck_n                 ,
    output wire                 [0:0] ddr3_cke                  ,
    output wire                 [0:0] ddr3_cs_n                 ,
    output wire [`DDR3_DM__WIDTH-1:0] ddr3_dm                   ,
    output wire                 [0:0] ddr3_odt                  ,
    input  wire                [27:0] app_addr                  ,
    input  wire                 [2:0] app_cmd                   ,
    input  wire                       app_en                    ,
    input  wire               [127:0] app_wdf_data              ,
    input  wire                       app_wdf_end               ,
    input  wire                       app_wdf_wren              ,
    output reg                [127:0] app_rd_data               ,
    output wire                       app_rd_data_end           ,
    output wire                       app_rd_data_valid         ,
    output wire                       app_rdy                   ,
    output wire                       app_wdf_rdy               ,
    input  wire                       app_sr_req                ,
    input  wire                       app_ref_req               ,
    input  wire                       app_zq_req                ,
    output wire                       app_sr_active             ,
    output wire                       app_ref_ack               ,
    output wire                       app_zq_ack                ,
    output wire                       ui_clk                    , //  83.33333 MHz
    output wire                       ui_clk_sync_rst           ,
    output reg                        init_calib_complete = 1'b0,
    output wire                       device_temp               ,
    input  wire                [15:0] app_wdf_mask              ,
    input  wire                       sys_clk_i                 , // 166.66667 MHz
    input  wire                       clk_ref_i                 , // 200.00000 MHz
    input  wire                       sys_rst
);

    // Clock and Reset Signals
    reg clk_83_33333_mhz = 1'b0; always #12 clk_83_33333_mhz <= !clk_83_33333_mhz;
    assign ui_clk = clk_83_33333_mhz;

    reg rst1, rst2;
    always @(posedge ui_clk or posedge sys_rst) begin
        if (sys_rst) begin
            rst1 <= 1'b1;
            rst2 <= 1'b1;
        end else begin
            rst1 <= 1'b0;
            rst2 <= rst1;
        end
    end
    assign ui_clk_sync_rst = rst2;

    // DRAM
    localparam OFFSET_WIDTH     = 3;
    localparam VALID_ADDR_WIDTH = $clog2(DRAM_SIZE)-OFFSET_WIDTH;
    wire [VALID_ADDR_WIDTH-1:0] valid_addr = app_addr[VALID_ADDR_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
    reg [31:0] mem [0:(2**VALID_ADDR_WIDTH)*4-1];
// `ifndef SYNTHESIS
// initial begin
// `include `MEM_TXT
// end
// `endif
    
    // CMD
    reg  [VALID_ADDR_WIDTH-1:0] app_addr_q          , app_addr_d            ;
    reg                         app_rd_data_end_q   , app_rd_data_end_d     ;
    reg                         app_rd_data_valid_q , app_rd_data_valid_d   ;

    assign app_rd_data_end    = app_rd_data_end_q     ;
    assign app_rd_data_valid  = app_rd_data_valid_q   ;

    // CMD FSM
    localparam CMD_IDLE     = 2'd0  ;
    localparam CMD_WRITE    = 2'd1  ;
    localparam CMD_READ     = 2'd2  ;
    reg [1:0] cmd_state_q   , cmd_state_d   ;

    assign app_rdy  = (cmd_state_q==CMD_IDLE)   ;

    reg  [7:0] read_wait_cntr_q , read_wait_cntr_d  ;

    always @(*) begin
        app_addr_d          = app_addr_q            ;
        app_rd_data_end_d   = 1'b0                  ;
        app_rd_data_valid_d = 1'b0                  ;
        read_wait_cntr_d    = read_wait_cntr_q-'h1  ;
        cmd_state_d         = cmd_state_q           ;
        casez (cmd_state_q)
            CMD_IDLE: begin
                if (app_en) begin
                    app_addr_d          = valid_addr    ;
                    if (app_cmd==3'b000) begin // write
                        cmd_state_d         = CMD_WRITE     ;
                    end
                    if (app_cmd==3'b001) begin // read
                        read_wait_cntr_d    = `READ_DELAY-1 ;
                        cmd_state_d         = CMD_READ      ;
                    end
                end
            end
            CMD_WRITE: begin
                if (wdf_state_q==WDF_WDATA) begin
                    cmd_state_d         = CMD_IDLE      ;
                end
            end
            CMD_READ : begin
                if (~|read_wait_cntr_q) begin
                    app_rd_data_end_d   = 1'b1          ;
                    app_rd_data_valid_d = 1'b1          ;
                    cmd_state_d         = CMD_IDLE      ;
                end
            end
            default  : begin
                cmd_state_d         = CMD_IDLE      ;
            end
        endcase
    end

    always @(posedge ui_clk) begin
        if (ui_clk_sync_rst) begin
            app_rd_data_end_q   <= 1'b0                 ;
            app_rd_data_valid_q <= 1'b0                 ;
            cmd_state_q         <= CMD_IDLE             ;
        end else begin
            app_addr_q          <= app_addr_d           ;
            app_rd_data_end_q   <= app_rd_data_end_d    ;
            app_rd_data_valid_q <= app_rd_data_valid_d  ;
            read_wait_cntr_q    <= read_wait_cntr_d     ;
            cmd_state_q         <= cmd_state_d          ;
        end
    end

    // WDF
    reg  [127:0] app_wdf_data_q , app_wdf_data_d;
    reg   [15:0] app_wdf_mask_q , app_wdf_mask_d;

    // WDF FSM
    localparam WDF_IDLE  = 1'd0;
    localparam WDF_WDATA = 1'd1;
    reg        wdf_state_q  , wdf_state_d   ;

    assign app_wdf_rdy  = (wdf_state_q==WDF_IDLE)   ;

    always @(*) begin
        app_wdf_data_d  = app_wdf_data_q;
        app_wdf_mask_d  = app_wdf_mask_q;
        wdf_state_d     = wdf_state_q   ;
        casez (wdf_state_q)
            WDF_IDLE : begin
                if (app_wdf_wren && app_wdf_end) begin
                    app_wdf_data_d  = app_wdf_data  ;
                    app_wdf_mask_d  = app_wdf_mask  ;
                    wdf_state_d     = WDF_WDATA     ;
                end
            end
            WDF_WDATA: begin
                if (cmd_state_q==CMD_WRITE) begin
                    wdf_state_d = WDF_IDLE;
                end
            end
            default  : begin
                wdf_state_d = WDF_IDLE;
            end
        endcase
    end

    always @(posedge ui_clk) begin
        if (ui_clk_sync_rst) begin
            wdf_state_q     <= WDF_IDLE         ;
        end else begin
            app_wdf_data_q  <= app_wdf_data_d   ;
            app_wdf_mask_q  <= app_wdf_mask_d   ;
            wdf_state_q     <= wdf_state_d      ;
        end
    end

    // DRAM Read/Write
    always @(posedge ui_clk) begin
        if ((cmd_state_q==CMD_READ) && ~|read_wait_cntr_q) begin
            app_rd_data <= {mem[{app_addr_q, 2'd3}], mem[{app_addr_q, 2'd2}], 
                            mem[{app_addr_q, 2'd1}], mem[{app_addr_q, 2'd0}]};
        end
        if ((cmd_state_q==CMD_WRITE) && (wdf_state_q==WDF_WDATA)) begin
            if (!app_wdf_mask_q[ 0]) mem[{app_addr_q, 2'd0}][ 7: 0] <= app_wdf_data_q[ 7: 0];
            if (!app_wdf_mask_q[ 1]) mem[{app_addr_q, 2'd0}][15: 8] <= app_wdf_data_q[15: 8];
            if (!app_wdf_mask_q[ 2]) mem[{app_addr_q, 2'd0}][23:16] <= app_wdf_data_q[23:16];
            if (!app_wdf_mask_q[ 3]) mem[{app_addr_q, 2'd0}][31:24] <= app_wdf_data_q[31:24];

            if (!app_wdf_mask_q[ 4]) mem[{app_addr_q, 2'd1}][ 7: 0] <= app_wdf_data_q[39:32];
            if (!app_wdf_mask_q[ 5]) mem[{app_addr_q, 2'd1}][15: 8] <= app_wdf_data_q[47:40];
            if (!app_wdf_mask_q[ 6]) mem[{app_addr_q, 2'd1}][23:16] <= app_wdf_data_q[55:48];
            if (!app_wdf_mask_q[ 7]) mem[{app_addr_q, 2'd1}][31:24] <= app_wdf_data_q[63:56];

            if (!app_wdf_mask_q[ 8]) mem[{app_addr_q, 2'd2}][ 7: 0] <= app_wdf_data_q[71:64];
            if (!app_wdf_mask_q[ 9]) mem[{app_addr_q, 2'd2}][15: 8] <= app_wdf_data_q[79:72];
            if (!app_wdf_mask_q[10]) mem[{app_addr_q, 2'd2}][23:16] <= app_wdf_data_q[87:80];
            if (!app_wdf_mask_q[11]) mem[{app_addr_q, 2'd2}][31:24] <= app_wdf_data_q[95:88];

            if (!app_wdf_mask_q[12]) mem[{app_addr_q, 2'd3}][ 7: 0] <= app_wdf_data_q[103:96];
            if (!app_wdf_mask_q[13]) mem[{app_addr_q, 2'd3}][15: 8] <= app_wdf_data_q[111:104];
            if (!app_wdf_mask_q[14]) mem[{app_addr_q, 2'd3}][23:16] <= app_wdf_data_q[119:112];
            if (!app_wdf_mask_q[15]) mem[{app_addr_q, 2'd3}][31:24] <= app_wdf_data_q[127:120];
        end
    end
    
    assign app_sr_active = app_sr_req ;
    assign app_ref_ack   = app_ref_req;
    assign app_zq_ack    = app_zq_req ;

    always @(posedge ui_clk) begin
        if (ui_clk_sync_rst) begin
            init_calib_complete <= 1'b0;
        end else begin
            init_calib_complete <= 1'b1;
        end
    end

endmodule
`endif // !SYNTHESIS
/*********************************************************************************************/
