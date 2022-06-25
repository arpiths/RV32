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
    
    reg[31:0] PC;       
   
    wire [31:0]ins_dec_in,alu_out,rso1,rso2,alu_in1,alu_in2,ins_dec_out,wb_val,d_add,d_out,pc1,pc2;
    wire [2:0] f3;
    wire[4:0]wb_reg,alu_rd;
    wire wb_en,alu_reg_w_en,d_r_en,d_w_en,br_en;
    
    
// //  //    stg 1
//    1 POS
    always @(posedge clk)begin
        if(rst)
            PC = -4;
        else            
            PC = PC + 4;        
    end

    Insmem insm(clk,{2'b0,PC[31:2]},ins_dec_in);
    
    wire [4:0] rs1,rs2;
    assign rs1 = ins_dec_in[19:15];
    assign rs2 = ins_dec_in[24:20];
    
    Regfile32 regf(clk,rst,
                rs1,rs2,
                wb_reg,wb_en,wb_val,alu_out,alu_reg_w_en,alu_rd,
                rso1,rso2);

//         2 NEG
    Decode dcd(clk,ins_dec_in,rst,
                alu_out,alu_rd,alu_reg_w_en,
                rso1,rso2,
                wb_en,wb_reg,wb_val,
                alu_in1,alu_in2,ins_dec_out
                );
        
//       stg 3            
        ALU alu1(clk,rst,ins_dec_out,alu_in1,alu_in2,
        alu_out,   
        alu_reg_w_en,alu_rd,    
        f3,d_r_en,d_w_en,d_add);
             
        assign out = alu_out[7:0];
//        //stg 4
//        //4 pos
        DataMem data(clk,rst,d_r_en,d_w_en,d_add,alu_out,d_out);
        
//        //stg 5 
//        //4 NEG
        Control ctrl(clk,rst,
                alu_rd,d_out,alu_reg_w_en,
                f3,d_r_en,d_w_en,
                wb_en,wb_reg,wb_val);
    
        
endmodule