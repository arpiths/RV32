module test1();

    reg clk,rst,rst_i;
    reg [31:0] wb_val;
    reg[31:0] PC;
    reg[4:0] wb_reg;
    reg wb_en;
    
    wire [31:0] rso1,rso2,ins_dec_in,ins_dec_out,alu_in1,alu_in2;
    wire [4:0] rs1,rs2;
    assign rs1=ins_dec_in[19:15];
    assign rs2=ins_dec_in[24:20];

    Insmem ins(clk,PC,ins_dec_in);

    Regfile32 regfile(clk,rst,
                ins_dec_in,
                wb_reg,wb_en,wb_val,
                rso1,rso2);
    
    
    reg[31:0] alu_out;
    reg[4:0] alu_rd;
    reg alu_reg_w_en;
    Decode dec(ins_dec_in,rst,
            alu_out,alu_rd,alu_reg_w_en,
            rso1,rso2,
            alu_in1,alu_in2,ins_dec_out
            );

    initial begin
        $dumpfile("test2.vcd");
        $dumpvars(0,test1);
    end

    initial begin  
        PC = 0;       
        clk = 0;
        alu_out = 0;alu_reg_w_en=0;alu_rd=0;
        rst =1;#2;
        rst=0;rst_i=1;#2;
        
        //testing regfile
        wb_reg = 5'h0; wb_val= 32'h01234; wb_en=1; #2;
        wb_reg = 5'h1; wb_val= 32'h01231; wb_en=1;#2;
        wb_reg = 5'h2; wb_val= 32'h01232; wb_en=1; #2;
        wb_reg = 5'h3; wb_val= 32'h01233; wb_en=1; #2;
        rst_i=0; wb_en=0;
        alu_out = 32'h00220220;alu_reg_w_en=1;alu_rd=5'h01;#2;
        alu_out = 32'h00220220;alu_reg_w_en=1;alu_rd=5'h02;#2;
        alu_out = 32'h00220220;alu_reg_w_en=1;alu_rd=5'h07;#2;
        alu_out = 32'h00220220;alu_reg_w_en=1;alu_rd=5'h08;#2;      

        #2 rst = 1'b1;
        #2 rst = 1'b0; 

        #20;       

        #25 $finish;
    end

    always #1 clk = !clk;

    always @(posedge clk ) begin
        PC = PC+1;
        if(rst_i)
            PC=0;
    end

endmodule 

