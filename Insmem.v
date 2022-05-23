module Insmem(clk,PC,ins);
    input clk;
    input[31:0] PC;
    output reg[31:0] ins;
   
   reg[31:0] mem[0:999];
   
   initial
    begin
        ins=0;
        $readmemh("testcode.txt", mem);        
    end
    
    always @(posedge clk)begin                    
        ins = mem[PC];        
    end  
      
endmodule