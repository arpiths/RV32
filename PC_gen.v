`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2022 23:46:40
// Design Name: 
// Module Name: PC_gen
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


module PC_gen(clk,rst,pc);
    input clk;
    input rst;
    output reg[31:0] pc;
    
     always @ (posedge clk) begin  
    if(rst)  
      pc <= -4;  
    else  
      pc <= pc + 4;  
  end  
endmodule
