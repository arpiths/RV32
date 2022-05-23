module Decode(ins_dec_in,rst,
            alu_out,alu_rd,alu_reg_w_en,
            rso1,rso2,
            alu_in1,alu_in2,ins_dec_out
            );

    input rst, alu_reg_w_en;
    input[31:0] ins_dec_in,alu_out,rso1,rso2;
    input[4:0] alu_rd;
    
    output reg [31:0] alu_in1,alu_in2,ins_dec_out;
    
    wire[4:0] rs1,rs2;
    assign rs1=ins_dec_in[19:15];
    assign rs2=ins_dec_in[24:20];
    
    always@(ins_dec_in,rso1,rso2,rst)begin
        alu_in1<=(alu_reg_w_en==1'b1)?((rs1 == alu_rd)? alu_out : rso1) : rso1 ;
        alu_in2<=(alu_reg_w_en==1'b1)?((rs2 == alu_rd)? alu_out : rso2) : rso1 ;
        ins_dec_out <= ins_dec_in;
        
        if(rst)begin
            alu_in1=0;
            alu_in2=0;
            ins_dec_out=0;
        end
    end
    
endmodule

