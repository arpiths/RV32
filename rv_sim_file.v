`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2022 18:02:17
// Design Name: 
// Module Name: rv_sim_file
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


module rv_sim_file(
    );
    reg clktb,rsttb;
    wire [7:0] LEDtb;
//    PC_gen pcgen(clk,rst,LEDtb);
    initial begin
        clktb=0;rsttb=0;
        #10 rsttb = 1;
        #40 rsttb = 0;  
        #700 $finish;
    end
    always #20 clktb=~clktb;
    RV32I rv(clktb, rsttb, LEDtb); 
    
endmodule
