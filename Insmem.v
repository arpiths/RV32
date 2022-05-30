module Insmem(clk,PC,ins);
    input clk;
    input[31:0] PC;
    output reg[31:0] ins;
   
   reg[31:0] mem[0:15];
   
   initial
    begin
        ins=0;
        $readmemh("D:/arpRISC/riscv/project_1/project_1.srcs/sources_1/imports/design32/testcode.txt", mem);        
    end
    
    always @(posedge clk)begin                    
        ins = mem[{2'b0,PC[31:2]}];        
    end  
      
endmodule