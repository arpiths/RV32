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

module Regfile32(clk,rst,
                rs1,rs2,
                wb_reg,wb_en,wb_val,alu_out,alu_reg_w_en,alu_rd,
                rso1,rso2);
    
    input clk,rst,wb_en,alu_reg_w_en;   
    
    input[4:0] wb_reg,rs1,rs2,alu_rd;    
    input[31:0] wb_val,alu_out;    
    output [31:0] rso1,rso2;    
    
    integer i,r1,r2;
    reg[31:0] mem[0:31];  
               
    always@(posedge clk) begin
        r1<=$unsigned(rs1);
        r2<=$unsigned(rs2);
        if(rst)begin            
             for (i = 0; i < 32; i = i + 1)
                mem[i] <= 0;
        end        
        else begin
            case({alu_reg_w_en,wb_en})
                2'b00:begin 
                    mem[0]<=0;
                end
                2'b01:begin
                    mem[wb_reg] <= (wb_reg==0)? 32'b0 : wb_val;
                end
                2'b10:begin
                    mem[alu_rd] <= (alu_rd==0)? 32'b0 : alu_out;
                end
                2'b11:begin
                    if(alu_rd==wb_reg)begin
                        mem[alu_rd] <= (alu_rd==0)? 32'b0 : alu_out;
                    end
                    else begin
                        mem[alu_rd] <= (alu_rd==0)? 32'b0 : alu_out;
                        mem[wb_reg] <= (wb_reg==0)? 32'b0 : wb_val;
                    end
                end
            endcase           
        end         
     end  
      
     assign  rso1 = mem[r1];
     assign  rso2 = mem[r2];
     
endmodule