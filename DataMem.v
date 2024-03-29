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

module DataMem(clk,rst,d_r_en,d_w_en,d_add,data_in,d_out);
    
    input clk,rst,d_w_en,d_r_en;
    
    input [31:0]d_add,data_in;    
    output reg[31:0] d_out;
    
    reg[31:0] data[0:99];
    integer i; 
    
    always@(posedge clk)begin  
        if(rst)begin
             for(i=0;i<100;i=i+1)
                data[i]=32'b0;
             d_out=0;
        end      
        else begin    
            if(d_w_en==1'b1)begin
                data[{2'b0,d_add[29:0]}] = data_in;
                d_out=0;
            end
            else if(d_r_en==1'b1)begin
                d_out = data[{2'b0,d_add[29:0]}];
            end 
            else begin
                d_out = data_in;
            end       
        end
    end
        
endmodule
