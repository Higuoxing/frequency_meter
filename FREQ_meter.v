`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/27 14:18:51
// Design Name: 
// Module Name: FREQ_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FREQ_measure(
    input wire clk_200M,          // -- clk_200M = 200MHz
    input wire rst_n,
    input wire sig_in,
    output reg [31:0] sig_freq_cnt_buf,
    output reg [31:0] ref_clk_cnt_buf
    );
    
    parameter max_ref_gate_cnt = 199_999_999;
    parameter max_ref_clk_100MHz_cnt = 0;
    
    reg [31:0] ref_gate_cnt;
    reg [31:0] sig_freq_cnt;
    
    reg sig_in_pos_detect_r0;
    reg sig_in_pos_detect_r1;
    wire sig_in_pos_detect;
    wire sig_in_neg_detect;
    
    reg ref_gate;
    reg ref_gate_pos_detect_r0;
    reg ref_gate_pos_detect_r1;
    wire ref_gate_pos_detect;
    wire ref_gate_neg_detect;
    
    reg real_gate;
    reg real_gate_pos_detect_r0;
    reg real_gate_pos_detect_r1;
    wire real_gate_neg_detect;
    
//    wire clk_200M;
    reg ref_clk_100MHz;
    reg [31:0] ref_clk_100MHz_cnt;
    reg ref_clk_100MHz_pos_detect_r0;
    reg ref_clk_100MHz_pos_detect_r1;
    wire ref_clk_100MHz_pos_detect;
    
    reg [31:0] ref_clk_cnt;
    
    reg buffer_done;
    reg [31:0] buffer_done_cnt;
    
    
    initial begin
        sig_freq_cnt <= 32'd0;
        sig_freq_cnt_buf <= 32'd0;
        
        ref_clk_100MHz <= 1'b0;
        ref_clk_100MHz_cnt <= 32'd0;
        
        ref_clk_cnt <= 32'd0;
        ref_clk_cnt_buf <= 32'd0;
        
        ref_gate <= 1'b0;
        ref_gate_cnt <= 32'd0;
        ref_gate_pos_detect_r0 <= 1'b0;
        ref_gate_pos_detect_r1 <= 1'b0;
        
        real_gate <= 1'b0;
        real_gate_pos_detect_r0 <= 1'b0;
        real_gate_pos_detect_r1 <= 1'b0;
        
        sig_in_pos_detect_r0 <= 1'b0;
        sig_in_pos_detect_r1 <= 1'b0;
        
        buffer_done <= 1'b0;
        buffer_done_cnt <= 32'd0;
    end
    
    // -- ref gate 0.5Hz clock generator
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            ref_gate <= 1'b0;
            ref_gate_cnt <= 32'd0;
        end
        else if (ref_gate_cnt == max_ref_gate_cnt) begin
            ref_gate <= ~ ref_gate;
            ref_gate_cnt <= 32'd0;
        end
        else ref_gate_cnt <= ref_gate_cnt + 1;
    end
    
    // -- ref 100MHz clock generator
//    always @ (posedge clk_200M or negedge rst_n) begin
//        if (!rst_n) begin
//            ref_clk_100MHz <= 1'b0;
//            ref_clk_100MHz_cnt <= 32'd0;
//        end
//        else if (ref_clk_100MHz_cnt == max_ref_clk_100MHz_cnt) begin
//            ref_clk_100MHz <= ~ ref_clk_100MHz;
//            ref_clk_100MHz_cnt <= 32'd0;
//        end
//        else ref_clk_100MHz_cnt <= ref_clk_100MHz_cnt + 1;
//    end

    always @ (posedge clk_200M) ref_clk_100MHz <= ~ ref_clk_100MHz;
    
    // -- sig_in posedge detect
    assign sig_in_pos_detect = (sig_in_pos_detect_r0 && 
                               !sig_in_pos_detect_r1) ? 1'b1: 1'b0;
    assign sig_in_neg_detect = (!sig_in_pos_detect_r0 &&
                                sig_in_pos_detect_r1) ? 1'b1: 1'b0;
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            sig_in_pos_detect_r0 <= 1'b0;
            sig_in_pos_detect_r1 <= 1'b0;
        end
        else begin
            sig_in_pos_detect_r0 <= sig_in;
            sig_in_pos_detect_r1 <= sig_in_pos_detect_r0;
        end
    end
    
    // -- ref 100MHz clock posedge detect
    assign ref_clk_100MHz_pos_detect = (ref_clk_100MHz_pos_detect_r0 &&
                                      !ref_clk_100MHz_pos_detect_r1) ? 1'b1: 1'b0;
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            ref_clk_100MHz_pos_detect_r0 <= 1'b0;
            ref_clk_100MHz_pos_detect_r1 <= 1'b0;
        end
        else begin
            ref_clk_100MHz_pos_detect_r0 <= ref_clk_100MHz;
            ref_clk_100MHz_pos_detect_r1 <= ref_clk_100MHz_pos_detect_r0;
        end
    end
    
    // -- ref gate 0.5Hz clock posedge& negedge detect
    assign ref_gate_pos_detect = (ref_gate_pos_detect_r0 &&
                                        !ref_gate_pos_detect_r1) ? 1'b1: 1'b0;
    assign ref_gate_neg_detect = (!ref_gate_pos_detect_r0 &&
                                        ref_gate_pos_detect_r1) ? 1'b1: 1'b0;                                       
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            ref_gate_pos_detect_r0 <= 1'b0;
            ref_gate_pos_detect_r1 <= 1'b0;
        end
        else begin
            ref_gate_pos_detect_r0 <= ref_gate;
            ref_gate_pos_detect_r1 <= ref_gate_pos_detect_r0;
        end
    end
    
    // -- real gate generator
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            real_gate <= 1'b0;
        end
        else if (ref_gate && sig_in_pos_detect) begin
            real_gate <= 1'b1;
        end
        else if (!ref_gate && sig_in_pos_detect) begin
            real_gate <= 1'b0;
        end
        else real_gate <= real_gate;
    end
    
    // -- real gate posedge& negedge detect
    assign real_gate_neg_detect =  (!real_gate_pos_detect_r0 && 
                                    real_gate_pos_detect_r1) ? 1'b1: 1'b0;
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            real_gate_pos_detect_r0 <= 1'b0;
            real_gate_pos_detect_r1 <= 1'b0;
        end
        else begin
            real_gate_pos_detect_r0 <= real_gate;
            real_gate_pos_detect_r1 <= real_gate_pos_detect_r0;
        end
    end
    
    // -- ref_100MHz clock counter
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            ref_clk_cnt <= 32'd0;
        end
        else if (real_gate && ref_clk_100MHz_pos_detect) begin
            ref_clk_cnt <= ref_clk_cnt + 1;
        end
        else if (!real_gate && buffer_done) begin
            ref_clk_cnt <= 32'd0;
        end
        else ref_clk_cnt <= ref_clk_cnt;
    end
    
    // -- sig_in paulse counter
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            sig_freq_cnt <= 32'd0;
        end
        else if (real_gate && sig_in_pos_detect) begin
            sig_freq_cnt <= sig_freq_cnt + 1;
        end
        else if (!real_gate && buffer_done ) begin
            sig_freq_cnt <= 32'd0;
        end
        else sig_freq_cnt <= sig_freq_cnt;
    end
    
    // -- set synchronizing data flag
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            buffer_done <= 1'b0;
            buffer_done_cnt <= 32'd0;
        end
        else if (!real_gate && buffer_done_cnt != 20) begin
            buffer_done_cnt <= buffer_done_cnt + 1;
            buffer_done <= 1'b0;
        end
        else if (!real_gate && buffer_done_cnt == 20) begin
            buffer_done_cnt <= buffer_done_cnt;
            buffer_done <= 1'b1;
        end
        else if (real_gate) begin
            buffer_done_cnt <= 32'd0;
            buffer_done <= 1'b0;
        end
        else begin
            buffer_done <= buffer_done;
            buffer_done_cnt <= buffer_done_cnt;
        end
    end
    
    // -- synchronize data
    always @ (posedge clk_200M or negedge rst_n) begin
        if (!rst_n) begin
            sig_freq_cnt_buf <= 32'd0;
            ref_clk_cnt_buf <= 32'd0;
        end
        else if (real_gate_neg_detect) begin
            sig_freq_cnt_buf <= sig_freq_cnt;
            ref_clk_cnt_buf <= ref_clk_cnt;
        end
        else begin
            sig_freq_cnt_buf <= sig_freq_cnt_buf;
            ref_clk_cnt_buf <= ref_clk_cnt_buf;
        end
    end
    
endmodule
