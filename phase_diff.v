`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/21 01:05:32
// Design Name: 
// Module Name: phase_diff
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


module phase_diff(
    input wire sys_clk,
    input wire rst_n,
    input wire sig_in0,
    input wire sig_in1,
    output reg [31:0] phase_diff_cnt_buf
    );
    
    parameter max_clk_1_2Hz_cnt = 100_000_000;
    reg [31:0] clk_1_2Hz_cnt;
	reg ref_clk_1_2Hz;
	reg [31:0] phase_diff_cnt;
	reg phase_diff_detect;
    
    // -- initialize var
    initial begin
        clk_1_2Hz_cnt <= 32'd0;
        ref_clk_1_2Hz <= 1'b0;
        phase_diff_cnt <= 32'd0;
        phase_diff_cnt_buf <= 32'd0;
        phase_diff_detect <= 1'b0;
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
    
    // ___________|．．．．．．．．．．．．．．．．．．|_______... 
    //
    //____|．．．．．．．．．．．．．．．．．．|________...
    //
    //_______________________|．．．．．．|_______...
    //
    //..._|．|_|．|_|．|_|．|_|．|_|．|_|．|_...

    // -- sig_in0 posedge& negedge detect
    reg sig_in0_pos_detect_r0 = 1'b0;
    reg sig_in0_pos_detect_r1 = 1'b0;
    wire sig_in0_pos_detect;
    wire sig_in0_neg_detect;
    assign sig_in0_pos_detect = (sig_in0_pos_detect_r0 &&
                             !sig_in0_pos_detect_r1) ? 1'b1: 1'b0;
    assign sig_in0_neg_detect = (!sig_in0_pos_detect_r0 &&
                             sig_in0_pos_detect_r1) ? 1'b1: 1'b0;                        
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
                sig_in0_pos_detect_r0 <= 1'b0;
                sig_in0_pos_detect_r1 <= 1'b0;
        end
        else begin
            sig_in0_pos_detect_r0 <= sig_in0;
            sig_in0_pos_detect_r1 <= sig_in0_pos_detect_r0;
        end
    end
    
    // -- sig_in1 posedge& negedge detect
    reg sig_in1_pos_detect_r0 = 1'b0;
    reg sig_in1_pos_detect_r1 = 1'b0;
    wire sig_in1_pos_detect;
    wire sig_in1_neg_detect;
    assign sig_in1_pos_detect = (sig_in1_pos_detect_r0 &&
                             !sig_in1_pos_detect_r1) ? 1'b1: 1'b0;
    assign sig_in1_neg_detect = (!sig_in1_pos_detect_r0 &&
                             sig_in1_pos_detect_r1) ? 1'b1: 1'b0;                        
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
			sig_in1_pos_detect_r0 <= 1'b0;
			sig_in1_pos_detect_r1 <= 1'b0;
        end
        else begin
            sig_in1_pos_detect_r0 <= sig_in1;
            sig_in1_pos_detect_r1 <= sig_in1_pos_detect_r0;
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
    
    // -- phase_diff_detector
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_diff_detect <= 1'b0;
        end
        else if (sig_in0_pos_detect) begin
            phase_diff_detect <= 1'b1;
        end
        else if (sig_in1_pos_detect) begin
            phase_diff_detect <= 1'b0;
        end
        else phase_diff_detect <= phase_diff_detect;   
    end
    
    // -- set synchronizing data flag
    reg buffer_done = 1'b0;
    reg [31:0] buffer_done_cnt = 32'd0;
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
            phase_diff_cnt_buf <= 32'd0;
        end
        else begin
            if (ref_clk_1_2Hz_neg_detect) begin
                phase_diff_cnt_buf <= phase_diff_cnt;
            end
            else begin
                phase_diff_cnt_buf <= phase_diff_cnt_buf;
            end
        end
    end
    
    // -- count the paulse when phase_diff_detect is high
    always @ (posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_diff_cnt <= 32'd0;
        end
        else if (phase_diff_detect && ref_clk_1_2Hz) begin
            phase_diff_cnt <= phase_diff_cnt + 1;
        end
        else if (!ref_clk_1_2Hz && buffer_done) begin
        	phase_diff_cnt <= 32'd0;
        end
        else phase_diff_cnt <= phase_diff_cnt;
    end
    
endmodule
