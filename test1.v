module test1();

    reg clk,rst;
    wire [31:0] ins;
    
    RV1 rv(clk,rst,ins);
    
    initial begin
        $dumpfile("test1.vcd");
        $dumpvars(0,test1);
    end

    initial begin         
        clk = 1'b0;
        rst = 1'b0;
        #2 rst = 1'b1;
        #2 rst = 1'b0;        
        #25 $finish;
    end

    always #1 clk = !clk;


endmodule 

module RV1(clk,rst,ins);   
    input clk,rst;   
    output[31:0] ins;
    
    reg[31:0] PC;
    initial begin PC=0; end
    
    wire [31:0] ins_dec_in;

    always@(posedge clk) begin
        PC <= PC+32'b01;
        if(rst)
            PC <= 0 ;
    end

    
        

    
    Insmem instruction(clk,PC,ins_dec_in);
    assign ins = ins_dec_in;    
    
endmodule