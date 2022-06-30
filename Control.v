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
module Control(clk,rst,
                alu_rd,d_out,
                f3_in,d_r_en,d_w_en,
                wb_en,wb_reg,wb_val);
    
    input [4:0] alu_rd;
    input[2:0] f3_in;
    input [31:0] d_out;
    input rst,clk,d_r_en,d_w_en;      
    reg[2:0]f3;    
    output reg wb_en;
    output reg [4:0] wb_reg;
    output reg [31:0] wb_val;   
    
    always@(posedge clk)begin             
            wb_reg <= alu_rd;
            wb_en <= rst==1 ? 0 : d_r_en ;
            f3=f3_in;    
    end
    
   always@(f3,d_out)begin                                
        casez(f3)
            3'b000:begin 
                wb_val = $signed(d_out[7:0]);
            end
            3'b001:begin 
                wb_val = $signed(d_out[15:0]);
            end
            3'b010:begin 
               wb_val = d_out ;
            end
            3'b100:begin
                wb_val = d_out[7:0];
            end
            3'b101:begin 
                wb_val = d_out[15:0];
            end
            default: begin
                wb_val = 0;
            end 
        endcase 
    end
       
endmodule
