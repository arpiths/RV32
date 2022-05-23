module RV32I(clk,rst);   
    input clk,rst;

    reg[31:0] PC;
    
    always @(posedge clk ) begin
        PC <= PC+4;
    end
    
    wire[31:0] ins_dec_in,ins_dec_out,alu_in1,alu_in2,rso1,rso2,ALU_out,wb_val,d_add,d_out;
    wire[4:0] alu_rd,wb_reg,
    wire[2:0] f3;
    wire alu_reg_w_en,wb_en,zero,d_r_en,d_w_en,
    
    Insmem instruction(clk,PC,ins_dec_in);
    
    Decode decoder(ins_dec_in,rst,
            ALU_out,alu_rd,alu_reg_w_en,
            rso1,rso2,
            alu_in1,alu_in2,ins_dec_out);
    
    Regfile32 regfile(clk,rst,
                ins_dec_in,
                wb_reg,wb_en,wb_val,
                rso1,rso2);
    
    ALU alu(ins_dec_out,alu_in1,alu_in2,
        ALU_out,zero,   
        alu_reg_w_en,alu_rd,    
        f3,d_r_en,d_w_en,d_add);

    DataMem data (clk,rst,d_r_en,d_w_en,d_add,ALU_out,     d_out);

    Control ctrl(rst,alu_rd,ALU_out,d_out,alu_reg_w_en,f3,
                wb_en,wb_reg,wb_val);
    
endmodule