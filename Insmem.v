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
   
   reg[31:0] mem[0:50];
   
   wire[31:0] nop;
   assign nop = 32'h00000033;
   
   initial
    begin
        ins=0;
        $readmemh("<path to a hex code>", mem);        
    end
    
    always @(negedge clk)begin       
          ins = mem[{2'b0,PC[31:2]}];    
    end  
      
endmodule
