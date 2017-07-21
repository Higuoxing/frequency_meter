`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/21 01:06:11
// Design Name: 
// Module Name: duty_cycle_meter
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


module duty_cycle_meter(
    input wire sys_clk,
    input wire rst_n,
    input sig_in,
    output reg [31:0] duty_cycle_cnt_buf
    );
    
    parameter max_clk_1_2Hz_cnt = 100;
    reg        ref_clk_1_2Hz;
    reg [31:0] clk_1_2Hz_cnt;
    
    initial begin
    	ref_clk_1_2Hz <= 1'b0;
    	clk_1_2Hz_cnt <= 32'd0;
    end
    
    // -- 0.5Hz clock generator
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_1_2Hz_cnt <= 32'd0;
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
    
    // -- count the paulse when sig_in is high
    reg [31:0] sig_in_high_cnt = 32'd0;
    always @ (posedge sys_clk or negedge rst_n) begin
    	
    end
    
    // -- count the paulse when sig_in is low
    always @ (posedge sys_clk or negedge rst_n) begin
    
    end
    
endmodule
