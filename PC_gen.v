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


module PC_gen(clk,br_ctrl,rst,pc_br,pc);
    input clk, rst,br_ctrl;
    input [31:0] pc_br;
    output reg[31:0] pc;
    
     always @ (posedge clk) begin  
    if(rst)  
      pc <= 0;
    else if(br_ctrl == 1)
      pc <= pc_br;  
    else  
      pc <= pc + 4;  
  end  
endmodule
