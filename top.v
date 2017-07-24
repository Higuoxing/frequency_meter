`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/19 20:27:06
// Design Name: 
// Module Name: top
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


module top(
	input  wire sys_clk,
	input  wire rst_n,
	input  wire sig_in0,
	input  wire sig_in1,
	output wire sck,
	output wire miso,
	output wire cs,
	output wire [15:0] led
	);
	wire [31:0] sig_freq_cnt_buf1;
	wire [31:0] sig_freq_cnt_buf2;
	wire [31:0] phase_diff_cnt_buf;
	wire [31:0] sig_in_high_cnt_buf;
	wire [31:0] sig_in_low_cnt_buf;
	wire [159:0] valid_data;
	wire [175:0] send_data;
	reg  [7:0] spi_data_out;
	wire spi_send_done;
	reg  cs_pos_detect_r0;
	reg  cs_pos_detect_r1;
	wire cs_pos_detect;
	reg [5:0] data_cnt;
	
	
	initial begin
		cs_pos_detect_r0 <= 1'b0;
		cs_pos_detect_r1 <= 1'b0;
		spi_data_out     <= 8'b0000_0000;
		data_cnt <= 6'd0;
	end
	
	// -- cs posedge detect
	assign cs_pos_detect = (cs_pos_detect_r0 && 
						!cs_pos_detect_r1) ? 1'b1: 1'b0;
	always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			cs_pos_detect_r0 <= 1'b0;
			cs_pos_detect_r1 <= 1'b0;
		end
		else begin
			cs_pos_detect_r0 <= cs;
			cs_pos_detect_r1 <= cs_pos_detect_r0;
		end
	end
	
	// -- sync data
	always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			data_cnt <= 0;
		end
		else if (cs_pos_detect && data_cnt != 21) begin
			data_cnt <= data_cnt + 1;
		end
		else if (cs_pos_detect && data_cnt == 21) data_cnt <= 5'd0;
		else data_cnt <= data_cnt;
	end
	
	assign send_data = {8'h55, 8'hAA, valid_data};
	always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			spi_data_out <= 8'b0000_0000;
		end
		case (data_cnt) 
			0	: spi_data_out <= send_data	[175:168];
			1 	: spi_data_out <= send_data	[167:160];
			2 	: spi_data_out <= send_data	[159:152];
			3 	: spi_data_out <= send_data	[151:144];
			4 	: spi_data_out <= send_data	[143:136];
			5 	: spi_data_out <= send_data	[135:128];
			6 	: spi_data_out <= send_data	[127:120];
			7 	: spi_data_out <= send_data	[119:112];
			8 	: spi_data_out <= send_data	[111:104];
			9 	: spi_data_out <= send_data	[103:96 ];
			10 	: spi_data_out <= send_data	[95 :88 ];
			11	: spi_data_out <= send_data	[87 :80 ];
			12 	: spi_data_out <= send_data	[79 :72 ];
			13 	: spi_data_out <= send_data	[71 :64 ];
			14 	: spi_data_out <= send_data	[63 :56 ];
			15 	: spi_data_out <= send_data	[55 :48 ];
			16 	: spi_data_out <= send_data	[47 :40 ];
			17 	: spi_data_out <= send_data	[39 :32 ];
		    18 	: spi_data_out <= send_data	[31 :24 ];
			19 	: spi_data_out <= send_data	[23 :16 ];
			20 	: spi_data_out <= send_data	[15 :8  ];
			21 	: spi_data_out <= send_data	[7  :0  ];
			default : spi_data_out <= send_data[175:168];
		endcase
	end

	wire [31:0] phase_diff_final;
	assign phase_diff_final = {2'b00, phase_diff_cnt_buf[31:2]};
	assign valid_data = {
						 sig_freq_cnt_buf1, sig_freq_cnt_buf2, 
						 phase_diff_final, sig_in_high_cnt_buf, 
						 sig_in_low_cnt_buf
						 };
	

	
	freq_counter freq_cnter1(
		.sys_clk(sys_clk),
		.rst_n(1'b1),
		.sig_in(sig_in0),
		.sig_freq_cnt_buf(sig_freq_cnt_buf1)
	);
	
	freq_counter freq_cnter2(
		.sys_clk(sys_clk),
		.rst_n(rst_n),
		.sig_in(sig_in1),
		.sig_freq_cnt_buf(sig_freq_cnt_buf2)
	);
    
    phase_diff phase_diff_cnter(
    	.sys_clk(sys_clk),
    	.rst_n(rst_n),
    	.sig_in0(sig_in0),
    	.sig_in1(sig_in1),
    	.phase_diff_cnt_buf(phase_diff_cnt_buf)
    );
    
    duty_cycle_meter duty_cycle_cnter(
    	.sys_clk(sys_clk),
    	.rst_n(rst_n),
    	.sig_in(sig_in1),
    	.sig_in_high_cnt_buf(sig_in_high_cnt_buf),
    	.sig_in_low_cnt_buf(sig_in_low_cnt_buf)
    );
    
    spi_transmit spi_trans(
    	.busy(1'b1),
    	.rst(rst_n),
    	.spi_send(1'b1),
    	.spi_data_out(spi_data_out),
    	.clk(sys_clk),
    	.sck(sck),
    	.miso(miso),
    	.cs(cs),
    	.spi_send_done(spi_send_done)
    );
    
endmodule

//module bin_to_seg(
//    input wire clk,
//    input wire rst_n,
//    input wire [3:0] in1,
//    input wire [3:0] in2,
//    input wire [3:0] in3,
//    input wire [3:0] in4,
//    output reg [6:0] seg,
//    output reg [3:0] wela
//    );

//			1	: spi_data_out <= send_data	[175:168];
//			2 	: spi_data_out <= send_data	[167:160];
//			3 	: spi_data_out <= send_data	[159:152];
//			4 	: spi_data_out <= send_data	[151:144];
//			5 	: spi_data_out <= send_data	[143:136];
//			6 	: spi_data_out <= send_data	[135:128];
//			7 	: spi_data_out <= send_data	[127:120];
//			8 	: spi_data_out <= send_data	[119:112];
//			9 	: spi_data_out <= send_data	[111:104];
//			10 	: spi_data_out <= send_data	[103:96 ];
//			11 	: spi_data_out <= send_data	[95 :88 ];
//			12	: spi_data_out <= send_data	[87 :80 ];
//			13 	: spi_data_out <= send_data	[79 :72 ];
//			14 	: spi_data_out <= send_data	[71 :64 ];
//			15 	: spi_data_out <= send_data	[63 :56 ];
//			16 	: spi_data_out <= send_data	[55 :48 ];
//			17 	: spi_data_out <= send_data	[47 :40 ];
//			18 	: spi_data_out <= send_data	[39 :32 ];
//		    19 	: spi_data_out <= send_data	[31 :24 ];
//			20 	: spi_data_out <= send_data	[23 :16 ];
//			21 	: spi_data_out <= send_data	[15 :8  ];
//			22 	: spi_data_out <= send_data	[7  :0  ];

