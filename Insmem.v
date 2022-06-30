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
   
//   reg[31:0] mem[0:15];
   
   wire[31:0] nop;
   assign nop = 32'h00000033;
   
   initial
    begin
        ins=0;
//        $readmemh("D:/arpRISC/dock/code/RISCV-RV32I-Assembler/src/outfile.txt", mem);        
    end
    
    always @(negedge clk)begin       
//          ins = mem[PC[31:2]];    
//         case({2'b0,PC[31:2]})  
//                32'h0 :ins=32'h80300093;
//                32'h1 :ins=32'h200113;
//                32'h2 :ins=32'h300193;
//                32'h3 :ins=32'h100023;
//                32'h4 :ins=32'h101223;
//                32'h5 :ins=32'h102423;
//                32'h6 :ins=32'h800203;
//                32'h7 :ins=32'h801283;
//                32'h8 :ins=32'h402303;
//                32'h9 :ins=32'h804383;
//                32'hA :ins=32'h805403;
//            endcase       
        case({2'b0,PC[31:2]})                 
        32'h0 :ins=32'h100093;
        32'h1 :ins=32'h200113;
        32'h2 :ins=32'h300193;
        32'h3 :ins=32'h208233;
        32'h4:ins=32'h401102B3;
        32'h5:ins=32'h40208333;
        32'h6:ins=32'h002093B3;
        32'h7:ins=32'hFF800413;
        32'h8:ins=32'h0080A4B3;
        32'h9:ins=32'h0080B533;
        32'hA:ins=32'h0020C5B3;
        32'hB:ins=32'h145633;
        32'hC:ins=32'h40145633;
        32'hD:ins=32'h0080A713;
        32'hE:ins=32'h0080B793;
        32'hF:ins=32'hF0B0C813;
        32'h10:ins=32'h315893;
        32'h11:ins=32'h40215913;
    endcase 
    
              
    end  
      
endmodule