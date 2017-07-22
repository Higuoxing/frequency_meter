`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/22 22:23:18
// Design Name: 
// Module Name: freq_counter2
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
	input wire sys_clk,
	input wire rst_n,
	input wire sig_in,
	output reg [31:0] sig_freq_cnt_buf
//	output ref_clk_1_2Hz,
//	output ref_clk_1_2Hz_pos_detect,
//	output ref_clk_1_2Hz_neg_detect,
//	output sig_in_pos_detect_r0,
//	output sig_in_pos_detect_r1,
//	output sig_in_pos_detect
    );
    
    parameter max_clk_1_2Hz_cnt = 399_999_999;
    
    reg [31:0] clk_1_2Hz_cnt;
    reg [31:0] sig_freq_cnt;
    reg ref_clk_1_2Hz;
    
    reg sig_in_pos_detect_r0;
    reg sig_in_pos_detect_r1;
    wire sig_in_pos_detect;
    
    reg ref_clk_1_2Hz_pos_detect_r0;
    reg ref_clk_1_2Hz_pos_detect_r1;
    wire ref_clk_1_2Hz_pos_detect;
    wire ref_clk_1_2Hz_neg_detect;
    
    reg buffer_done;
    reg [31:0] buffer_done_cnt;
    initial begin
    	clk_1_2Hz_cnt <= 32'd0;
    	sig_freq_cnt <= 32'd0;
    	sig_freq_cnt_buf <= 32'd0;
    	ref_clk_1_2Hz <= 1'b0;
    	sig_in_pos_detect_r0 <= 1'b0;
    	sig_in_pos_detect_r1 <= 1'b0;
    	ref_clk_1_2Hz_pos_detect_r0 <= 1'b0;
    	ref_clk_1_2Hz_pos_detect_r1 <= 1'b0;
    	
    end
    
    // -- 0.5Hz clock generator
    always @ (posedge sys_clk or negedge rst_n) begin
    	if (!rst_n) begin
    		ref_clk_1_2Hz <= 1'b0;
    		clk_1_2Hz_cnt <= 32'd0;
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
    
    // -- ref clock 0.5Hz posedge& negedge detect
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
    always @ (posedge sys_clk or negedge rst_n) begin
		if (!rst_n) begin
			buffer_done <= 1'b0;
			buffer_done_cnt <= 32'd0;
		end
		else if (!ref_clk_1_2Hz && buffer_done_cnt != 10) begin
			buffer_done_cnt <= buffer_done_cnt + 1;
			buffer_done <= 1'b0;
		end
		else if (!ref_clk_1_2Hz && buffer_done_cnt == 10) begin
			buffer_done <= 1'b1;
			buffer_done_cnt <= buffer_done_cnt;
		end
		else if (ref_clk_1_2Hz) begin
			buffer_done_cnt <= 32'd0;
			buffer_done <= 1'b0;
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
