`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2022 23:09:07
// Design Name: 
// Module Name: Decode
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


module Decode(clk,ins_dec_in,rst,
            alu_out,alu_rd,alu_reg_w_en,
            rso1,rso2,
            wb_en,wb_reg,wb_val,
            alu_in1,alu_in2,ins_dec_out
            );
input clk,rst,wb_en,alu_reg_w_en;
input [31:0]ins_dec_in,alu_out,rso1,rso2,wb_val;
input[4:0]alu_rd,wb_reg;
output reg [31:0] ins_dec_out ;
output [31:0] alu_in1,alu_in2;

reg[31:0] nop;

initial begin
    nop=32'h000013; 
end

wire[4:0] rs1,rs2;
assign rs1=ins_dec_out[19:15];
assign rs2=ins_dec_out[24:20];

always@(posedge clk)begin
    ins_dec_out= rst? nop : ins_dec_in;
end      

//wire in1,in2;
//assign in1= rs1==alu_rd? 1 :0;
//assign in2= rs2==alu_rd? 1 :0;

assign alu_in1 = alu_reg_w_en == 1 ? (rs1==alu_rd ? alu_out : rso1 ) : rso1;
assign alu_in2 = alu_reg_w_en == 1 ? (rs2==alu_rd ? alu_out : rso2 ) : rso2;  

endmodule
