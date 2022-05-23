module test1();

    reg clk,rst;
    wire [31:0] ins;

    initial begin 
        clk<=1'b0;
        rst<=1'b0;
        #2 rst=1'b1;
        #2 rst=1'b0;
        #25 $finish;
    end
    forever begin
        #1 clk = ~clk;
    end

    RV1 fetch (clk,rst,ins);
    
    initial
    begin
        $dumpfile("test1.vcd");
        $dumpvars(0,test1);
    end



endmodule 

module RV1(clk,rst,ins);   
    input clk,rst;   
    output[31:0] ins;
    reg[31:0] PC;
    
    always @(posedge clk) begin
        PC <= PC+4;
    end
    
    wire[31:0] ins_dec_in,ins_dec_out,alu_in1,alu_in2,rso1,rso2,ALU_out,wb_val,d_add,d_out;
    wire[4:0] alu_rd,wb_reg,
    wire[2:0] f3;
    wire alu_reg_w_en,wb_en,zero,d_r_en,d_w_en,
    
    Insmem instruction(clk,PC,ins_dec_in);
    assign ins = ins_dec_in;    
    
endmodule