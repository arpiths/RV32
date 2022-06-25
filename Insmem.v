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
   
   wire[31:0] nop;
   assign nop = 32'h00000033;
   
   initial
    begin
        ins=0;
        $readmemh("D:/arpRISC/dock/code/RISCV-RV32I-Assembler/src/outfile.txt", mem);        
    end
    
    always @(negedge clk)begin                  
         ins <= mem[PC];                
    end  
      
endmodule