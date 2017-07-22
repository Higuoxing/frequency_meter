`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/22 21:58:10
// Design Name: 
// Module Name: top_test
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


module top_test(
	input wire sys_clk,
	input wire rst_n,
	input wire sig_in,
	output wire [15:0] led
    );
    
    
	wire [31:0] sig_freq_cnt_buf;
	freq_counter2 test(
		.sys_clk(sys_clk),
		.rst_n(rst_n),
		.sig_in(sig_in),
		.sig_freq_cnt_buf(sig_freq_cnt_buf)
	);
	
    assign led = sig_freq_cnt_buf[15:0];
endmodule

//module freq_counter(
//    input wire sys_clk,          // 100MHz clock
//    input wire rst_n,            // global reset
//    input wire sig_in,           // test square wave
//    output reg [31:0] sig_freq_cnt_buf // the paulse of input signal in a second
//    );