
module Regfile32(clk,rst,
                ins,
                wb_reg,wb_en,wb_val,
                rso1,rso2);
    
    input clk,rst,wb_en;   
    
    input[4:0] wb_reg;    
    input[31:0] ins,wb_val;
    
    output reg[31:0] rso1,rso2;    
    wire[4:0] rs1,rs2;
    
    assign rs1=ins[19:15];
    assign rs2=ins[24:20];

    reg[31:0] mem[0:31];    
                 
    always@(negedge clk && !rst) begin

        if(wb_en == 1'b1)begin
            mem[wb_reg] = (wb_reg==0)? 32'b0 : wb_val;            
            
            rso1 = (rs1==0)? 32'b0:mem[rs1];
            rso2 = (rs2==0)? 32'b0:mem[rs2];            
        end

        else begin
            rso1 <= (rs1==0)? 32'b0:mem[rs1];
            rso2 <= (rs2==0)? 32'b0:mem[rs2]; 
        end

    end

    integer i;

    always @(posedge rst) begin
        for(i=0; i<32; i=i+1)
            mem[i] = 32'b0;
    end

endmodule