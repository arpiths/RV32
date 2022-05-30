`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2022 16:22:12
// Design Name: 
// Module Name: adder
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

module Insmem(clk,PC,ins);
    input clk;
    input[31:0] PC;
    output reg[31:0] ins;
   
   reg[31:0] mem[0:15];
   
   initial
    begin
        ins=0;
        $readmemh("D:/arpRISC/riscv/project_1/project_1.srcs/sources_1/imports/design32/testcode.txt", mem);        
    end
    
    always @(posedge clk)begin                    
        ins = mem[{2'b0,PC[31:2]}];        
    end  
      
endmodule