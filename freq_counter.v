`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/19 20:30:48
// Design Name: 
// Module Name: freq_counter
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

module freq_counter(
    input wire sys_clk,          // 100MHz clock
    input wire rst_n,            // global reset
    input wire sig_in,           // test square wave
    output reg [31:0] sig_freq_cnt_buf // the paulse of input signal in a second
    );
    
    parameter max_clk_1_2Hz_cnt = 100_000_000;
    
    reg [31:0] clk_1_2Hz_cnt;
    reg [31:0] sig_freq_cnt;
    reg ref_clk_1_2Hz;
    
    initial begin
        clk_1_2Hz_cnt <= 32'd0;
        sig_freq_cnt <= 32'd0;
        sig_freq_cnt_buf <= 32'd0;
        ref_clk_1_2Hz <= 1'b0;
    end
    
    // -- 0.5Hz clock generator
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_1_2Hz_cnt <= 32'd0;
            sig_freq_cnt <= 32'd0;
            ref_clk_1_2Hz <= 1'b0;
        end
        else begin
            if (clk_1_2Hz_cnt == max_clk_1_2Hz_cnt) begin
                ref_clk_1_2Hz <= ~ ref_clk_1_2Hz;
                clk_1_2Hz_cnt <= 32'd0;
            end
            else clk_1_2Hz_cnt <= clk_1_2Hz_cnt + 1;
        end
    end
    
    // -- sig_in posedge detect
    reg sig_in_pos_detect_r0 = 1'b0;
    reg sig_in_pos_detect_r1 = 1'b0;
    wire sig_in_pos_detect;
    assign sig_in_pos_detect = (sig_in_pos_detect_r0 && 
                            !sig_in_pos_detect_r1) ? 1'b1: 1'b0;
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_in_pos_detect_r0 <= 1'b0;
            sig_in_pos_detect_r1 <= 1'b0;
        end
        else begin
            sig_in_pos_detect_r0 <= sig_in;
            sig_in_pos_detect_r1 <= sig_in_pos_detect_r0;
        end
    end
    
    // -- ref clock 0.5Hz posedge detect
    reg ref_clk_1_2Hz_pos_detect_r0 = 1'b0;
    reg ref_clk_1_2Hz_pos_detect_r1 = 1'b0;
    wire ref_clk_1_2Hz_pos_detect;
    wire ref_clk_1_2Hz_neg_detect;
    assign ref_clk_1_2Hz_pos_detect = (ref_clk_1_2Hz_pos_detect_r0 &&
                             !ref_clk_1_2Hz_pos_detect_r1) ? 1'b1: 1'b0;
    assign ref_clk_1_2Hz_neg_detect = (!ref_clk_1_2Hz_pos_detect_r0 &&
                             ref_clk_1_2Hz_pos_detect_r1) ? 1'b1: 1'b0;                        
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
                ref_clk_1_2Hz_pos_detect_r0 <= 1'b0;
                ref_clk_1_2Hz_pos_detect_r1 <= 1'b0;
        end
        else begin
            ref_clk_1_2Hz_pos_detect_r0 <= ref_clk_1_2Hz;
            ref_clk_1_2Hz_pos_detect_r1 <= ref_clk_1_2Hz_pos_detect_r0;
        end
    end
    
    // -- set synchronizing data flag
    reg buffer_done = 1'b0;
    reg [31:0] buffer_done_cnt = 32'b0;
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            buffer_done <= 1'b0;
        end
        else begin
            if (!ref_clk_1_2Hz && buffer_done_cnt == 10) begin
                buffer_done_cnt <= buffer_done_cnt;
                buffer_done <= 1'b1;
            end
            else if (!ref_clk_1_2Hz && buffer_done_cnt != 10) begin
                buffer_done_cnt <= buffer_done_cnt + 1'b1;
            end
            else if (ref_clk_1_2Hz) begin
                buffer_done_cnt <= 32'd0;
                buffer_done <= 1'b0;
            end
        end
    end
    
    // -- count the paulse of sig_in 
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) sig_freq_cnt <= 32'd0;
        else begin
            if (ref_clk_1_2Hz) begin
                if (sig_in_pos_detect) sig_freq_cnt <= sig_freq_cnt + 1'b1;
                else sig_freq_cnt <= sig_freq_cnt;
            end
            else if (buffer_done) sig_freq_cnt <= 32'd0;
        end
    end
    
    // -- synchronize data
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_freq_cnt_buf <= 32'd0;
        end
        else begin
            if (ref_clk_1_2Hz_neg_detect) begin
                sig_freq_cnt_buf <= sig_freq_cnt;
            end
            else begin
                sig_freq_cnt_buf <= sig_freq_cnt_buf;
            end
        end
    end
    
endmodule
