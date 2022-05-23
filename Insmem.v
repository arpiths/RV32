module Insmem(clk,PC,ins);
    input clk;
    input[31:0] PC;
    output reg[31:0] ins;
   
//    reg[31:0] mem[0:999];
    
    always @(posedge clk)begin
        casez(PC)
            32'b000000 : ins <= 32'b0;
            32'b000100 : ins <= 32'b0;
            32'b001000 : ins <= 32'b0;
            32'b001100 : ins <= 32'b0;
            32'b010000 : ins <= 32'b0;
            32'b010100 : ins <= 32'b0;
            32'b011000 : ins <= 32'b0;
            32'b011100 : ins <= 32'b0;
            32'b100000 : ins <= 32'b0;
            default: ins<=0;
        endcase
    end  
      
endmodule