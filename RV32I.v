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

module RV32I(input clk,rst;);   
//    reg clk,rst;
    reg[31:0] PC;    
    
//    initial begin
//        clk<=0;
//        PC<=0;
//        rst = 1;
//        #5 rst=0; 
//        #200 $finish;       
//    end
    
//    initial begin
//        $dumpfile("test2.vcd");
//        $dumpvars(0,RV32I);
//    end
    
//    always #1 clk = ~clk;    
    
    always @(posedge clk)        
        PC= rst ? 32'b0 : PC+32'd4;
    
    wire [31:0]ins_dec_in,alu_out,rso1,rso2,alu_in1,alu_in2,ins_dec_out,wb_val,d_add,d_out;
    wire [2:0] f3;
    wire[4:0]wb_reg,alu_rd;
    wire wb_en,zero,alu_reg_w_en,d_r_en,d_w_en;
//    assign wb_en=0;
//    assign alu_reg_w_en=0;
//    assign alu_rd=0; 
    
    Insmem insme(clk,PC,ins_dec_in);
    
    Decode decod(clk,ins_dec_in,rst,
            alu_out,alu_rd,alu_reg_w_en,
            rso1,rso2,
            alu_in1,alu_in2,ins_dec_out
            );
    
    Regfile32 regfile(clk,rst,
                ins_dec_in,
                wb_reg,wb_en,wb_val,
                rso1,rso2);
               
    ALU alu(clk,rst,ins_dec_out,alu_in1,alu_in2,
        alu_out,zero,   
        alu_reg_w_en,alu_rd,    
        f3,d_r_en,d_w_en,d_add);
                
    Control ctrl(clk,rst,
                alu_rd,alu_out,d_out,alu_reg_w_en,
                f3,d_r_en,d_w_en,
                wb_en,wb_reg,wb_val);
                
    DataMem data(clk,rst,d_r_en,d_w_en,d_add,alu_out,d_out);

    
endmodule