`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/05/18 19:06:59
// Design Name: 
// Module Name: decoder
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


module bin_to_seg(
    input wire clk,
    input wire rst_n,
    input wire [3:0] in1,
    input wire [3:0] in2,
    input wire [3:0] in3,
    input wire [3:0] in4,
    output reg [6:0] seg,
    output reg [3:0] wela
    );
    
    reg [3:0] in;
    reg [1:0] count;


    initial begin
        in	<=	0;
        count	<=	0;
        {seg,wela}	<=	11'b11111111111;
    end
    
    
    
    always@(posedge clk or negedge rst_n) begin//or negedge rst
        if(!rst_n) begin
            count	<=	0;
            //seg<=7'b1111111;
        end
        else begin
            count	<=	count+1;
        end
    end
    
    //always@(count) begin
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            wela	<=	4'b0000;
            in	<=	0;
        end
        else	begin
            case(count)
            2'b00: begin
                wela	<=	4'b0111;
                in		<=	in4;
            end
            2'b01: begin
                wela	<=	4'b1011;
                in		<=	in3;
            end
            2'b10: begin
                wela	<=	4'b1101;
                in		<=	in2;
            end
            2'b11: begin
                wela	<=	4'b1110;
                in		<=	in1;
            end
        endcase
    end
    end
    
    
    //always@(in)begin//7seg
    always@(in) begin
        if(!rst_n)	seg	<=	7'b1111111;
        else begin
            case(in)
                0: seg<=7'b1000000;
                1: seg<=7'b1111001;
                2: seg<=7'b0100100;
                3: seg<=7'b0110000;
                4: seg<=7'b0011001;
                5: seg<=7'b0010010;
                6: seg<=7'b0000010;
                7: seg<=7'b1111000;
                8: seg<=7'b0000000;
                9: seg<=7'b0010000;
                10: seg<=7'b0001000;
                11: seg<=7'b0000011;
                12: seg<=7'b1000110;
                13: seg<=7'b0100001;
                14: seg<=7'b0000110;
                15: seg<=7'b0001110;
            default: seg<=7'b1111111;
        endcase
    end
    end 
endmodule
