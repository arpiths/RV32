module Control(clk,rst,
                alu_rd,ALU_out,d_out,alu_reg_w_en,
                f3,d_r_en,d_w_en,
                wb_en,wb_reg,wb_val);
    
    input [4:0] alu_rd;
    input[2:0] f3;
    input [31:0] ALU_out,d_out;
    input alu_reg_w_en,rst,clk,d_r_en,d_w_en;      
        
    output reg wb_en;
    output reg [4:0] wb_reg;
    output [31:0] wb_val;   
    
    wire[31:0] val;
    assign val = val_gen==2'b00 ? $signed(d_out & wb_sel) :
                 (val_gen==2'b11 ? $unsigned(d_out & wb_sel) :  0);
    
    
    assign wb_val = v_sel ? val : wb_alu ;     
            
    ///////////writeback stage////////// 
    reg[31:0] wb_alu , wb_sel;
//    reg[4:0] add;
    reg v_sel;
    reg[1:0] val_gen;
    always@(posedge clk)begin
        if(rst)begin
            wb_alu <= 0;
            wb_reg <= 0;
            wb_en <= 0;
            v_sel =1;
        end
        else begin 
             wb_alu <= ALU_out;
             wb_reg <= alu_rd;
             v_sel <= d_r_en;
             wb_en = (alu_reg_w_en == 1'b1 || d_r_en ==1'b1) ? 1'b1: 1'b0;
             wb_sel = ( f3==3'b010 ? 32'hFFFFFFFF :
                    ((f3==3'b000 || f3==3'b100) ? 32'h0FF : 
                    ((f3==3'b001 || f3==3'b101) ? 32'h0FFFF : 32'b00))); 
             val_gen = ((f3==3'b000 || f3==3'b001) ? 2'b00 :
                    (( f3==3'b010 || f3==3'b100 || f3==3'b101) ? 2'b11 : 2'b01 ));
        end
    end   
endmodule
