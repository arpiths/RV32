`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2022 23:50:10
// Design Name: 
// Module Name: rd_reg
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


module rd_reg(ins_dec_in,rs1,rs2);
    input [31:0] ins_dec_in;
    output [4:0] rs1;
    output [4:0] rs2;
    assign rs1 = ins_dec_in[19:15];
    assign rs2 = ins_dec_in[24:20];
endmodule
