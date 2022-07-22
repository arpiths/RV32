`timescale 1ns / 100ps
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

module RV32I(input clk, rst, output[7:0] out);   
    
    wire[31:0] PC;       
    wire [31:0]ins_dec_in,alu_out,rso1,rso2,alu_in1,alu_in2,alu_in3,ins_dec_out,wb_val,d_add,d_out,pc2,pc_out;
    wire [2:0] f3;
    wire[4:0]wb_reg,alu_rd;
    wire wb_en,alu_reg_w_en,d_r_en,d_w_en,br_en,br_ctrl;
    wire [4:0] rs1,rs2;
    
    assign out = alu_out;

    PC_gen pcgen(clk,br_ctrl,rst,pc_out,PC);

    Insmem insm(clk,PC,ins_dec_in);
   
    Read r1(clk,PC,br_ctrl,rst,ins_dec_in,
            alu_out,alu_reg_w_en,alu_rd,
            wb_val,wb_en,wb_reg,
            alu_in1,alu_in2,alu_in3,ins_dec_out,pc2
            ); 
    
    ALU alu1(clk,rst,ins_dec_out,alu_in1,alu_in2,alu_in3,pc2,
        alu_out,alu_reg_w_en,alu_rd,    
        f3,d_r_en,d_w_en,d_add,
        br_ctrl,pc_out);
             
    DataMem data(clk,rst,d_r_en,d_w_en,d_add,alu_out,d_out);
    
    Control ctrl(clk,rst,
                alu_rd,d_out,alu_reg_w_en,
                f3,d_r_en,d_w_en,
                wb_en,wb_reg,wb_val);
        
endmodule