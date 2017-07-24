`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/23 09:20:25
// Design Name: 
// Module Name: LED_module
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


module LED_module(
	input wire sys_clk,
	output reg [15:0] led
    );
    
    always @ (posedge sys_clk or negedge rst_n) begin
    	if (!rst_n) begin 
    		
    	end
    end
    
endmodule
