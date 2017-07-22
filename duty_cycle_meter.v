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
	input wire sig_in,
	output reg [31:0] sig_in_high_cnt_buf,
	output reg [31:0] sig_in_low_cnt_buf
	);
	
	parameter max_clk_1_2Hz_cnt = 100;
	reg [31:0] clk_1_2Hz_cnt;
	reg ref_clk_1_2Hz;
	
	reg sig_in_r;
	
	reg ref_clk_1_2Hz_pos_detect_r0;
	reg ref_clk_1_2Hz_pos_detect_r1;
	wire ref_clk_1_2Hz_pos_detect;
	wire ref_clk_1_2Hz_neg_detect;
	
	reg [31:0] sig_in_high_cnt;
	reg [31:0] sig_in_low_cnt;
	
	reg buffer_done;
	reg [31:0] buffer_done_cnt;
	
	// -- initialize var
	initial begin
		
		sig_in_r <= 1'b0;
		sig_in_high_cnt_buf <= 32'd0;
		sig_in_low_cnt_buf  <= 32'd0;
		
		ref_clk_1_2Hz <= 1'b0;
		clk_1_2Hz_cnt <= 1'b0;
		ref_clk_1_2Hz_pos_detect_r0 <= 1'b0;
		ref_clk_1_2Hz_pos_detect_r1 <= 1'b0;
		
		sig_in_high_cnt <= 32'd0;
		sig_in_low_cnt <= 32'd0;
		
		buffer_done <= 1'b0;
		buffer_done_cnt <= 32'd0;
	end
    
	// -- 0.5Hz refference clock generator
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
	
    // -- ref clock 0.5Hz posedge detect
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
	
    // -- sig_in posedge detect
	reg sig_in_neg_detect_r0 = 1'b0;
	reg sig_in_neg_detect_r1 = 1'b0;
	wire sig_in_neg_detect;
	assign sig_in_neg_detect = (!sig_in_pos_detect_r0 && 
	                         sig_in_pos_detect_r1) ? 1'b1: 1'b0;
	always @ (posedge sys_clk or negedge rst_n) begin
	    if (!rst_n) begin
	        sig_in_neg_detect_r0 <= 1'b0;
	        sig_in_neg_detect_r1 <= 1'b0;
	    end
	    else begin
	        sig_in_neg_detect_r0 <= sig_in;
	        sig_in_neg_detect_r1 <= sig_in_neg_detect_r0;
	    end
	end
		
	// -- reshape sig_in
	always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			sig_in_r <= 1'b0;
		end
		else if (sig_in_pos_detect) begin
			sig_in_r <= 1'b1;
		end
		else if (sig_in_neg_detect) begin
			sig_in_r <= 1'b0;
		end
		else sig_in_r <= sig_in_r;
	end
	
	// -- count paulse when ref_clk_1_2hz is high
	always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			sig_in_high_cnt <= 32'd0;
		end
		else begin
			if (ref_clk_1_2Hz && sig_in_r) begin
				sig_in_high_cnt <= sig_in_high_cnt + 1;
			end
			else if (!ref_clk_1_2Hz && buffer_done) begin
				sig_in_high_cnt <= 32'd0;
			end
			else sig_in_high_cnt <= sig_in_high_cnt;
		end
	end
	
	// -- count paulse when ref-clk_1_2Hz is low
	always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			sig_in_low_cnt <= 32'd0;
		end
		else begin
			if (ref_clk_1_2Hz && !sig_in_r) begin
				sig_in_low_cnt <= sig_in_low_cnt + 1;
			end
			else if (!ref_clk_1_2Hz && buffer_done) begin
				sig_in_low_cnt <= 32'd0;
			end
			else sig_in_low_cnt <= sig_in_low_cnt;
		end
	end
	
	// -- set synchronizing data flag
    always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			buffer_done <= 1'b0;
			buffer_done_cnt <= 32'd0;
		end
		else if (!ref_clk_1_2Hz && buffer_done_cnt != 100) begin
			buffer_done_cnt <= buffer_done_cnt + 1;
			buffer_done <= 1'b0;
		end
		else if (!ref_clk_1_2Hz && buffer_done_cnt == 100) begin
			buffer_done <= 1'b1;
			buffer_done_cnt <= buffer_done_cnt;
		end
		else if (ref_clk_1_2Hz) begin
			buffer_done_cnt <= 32'd0;
			buffer_done <= 1'b0;
		end
	end
	
	// -- synchronize data
    always @ (posedge sys_clk or negedge rst_n) begin
	    if (!rst_n) begin
	        sig_in_high_cnt_buf <= 32'd0;
	        sig_in_low_cnt_buf <= 32'd0;
	    end
	    else begin
	        if (ref_clk_1_2Hz_neg_detect) begin
	            sig_in_high_cnt_buf <= sig_in_high_cnt;
	            sig_in_low_cnt_buf <= sig_in_low_cnt;
	        end
	        else begin
	            sig_in_high_cnt_buf <= sig_in_high_cnt_buf;
	            sig_in_low_cnt_buf <= sig_in_low_cnt_buf;
	        end
	    end
	end

endmodule
