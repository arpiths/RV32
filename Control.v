module Control(rst,alu_rd,ALU_out,d_out,alu_reg_w_en,f3,
wb_en,wb_reg,wb_val);
    
    input [4:0] alu_rd;
    input[2:0] f3;
    input [31:0] ALU_out,d_out;
    input alu_reg_w_en,rst;
    input [3:0] d_r_ctrl,d_w_ctrl;     
    
    output r_en,w_en;
    output[31:0] data_in,wb_out;
    
    output reg wb_en;
    output reg [4:0] wb_reg;
    output reg [31:0] wb_val;
    
    assign r_en = d_r_ctrl[0];
    assign w_en = d_w_ctrl[0];
     
    ///////////writeback stage////////// 
    always@(d_out,d_r_ctrl,d_w_ctrl,alu_rd,f3,alu_reg_w_en && !rst)begin
        ///LOAD///
        wb_reg <= alu_rd; 
        if(r_en==1'b1)begin
            wb_en <= 1'b1;                       
            casez(f3)
                3'b000:begin //lb
                    wb_val <= $signed(d_out & 32'h000F);      
                end
                3'b001:begin  //lh
                    wb_val <= $signed(d_out & 32'h00FF);
                end
                3'b010:begin //lw
                    wb_val <= d_out;
                end
                3'b100:begin  //lbu
                    wb_val <= d_out & 32'h000F;
                end 
                3'b101:begin //lhu
                    wb_val <= d_out & 32'h00FF;
                end
                default:
                    wb_reg <=0;
            endcase
        end

        else if(w_en==1'b1)begin
            wb_en<=0;           
        end

        else begin
            wb_reg <= alu_rd;
            wb_en <= alu_reg_w_en;
            wb_val <= ALU_out;
        end       
    end
    
    
endmodule

