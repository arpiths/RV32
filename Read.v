`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2022 23:43:19
// Design Name: 
// Module Name: Read
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Read(clk,rst,ins_dec_in,
            alu_out,alu_reg_w_en,alu_rd,
            wb_val,wb_en,wb_reg,
            alu_in1,alu_in2,ins_dec_out
            );
    input clk,rst,wb_en,alu_reg_w_en;
    input [31:0]ins_dec_in,alu_out,wb_val;
    input[4:0] wb_reg,alu_rd;
    output reg[31:0] ins_dec_out;
    output[31:0] alu_in1,alu_in2;
    
    reg[31:0] nop;

    initial begin
        nop=32'h000013; 
    end
    
    reg[31:0] mem[0:31];  
    reg[4:0] d1,d2;  
    integer i;
    reg en1,en2,z;   
    reg[31:0] v1,v2,ro1,ro2;      
    wire[31:0] rs1,rs2,hz1,hz2;
    always@(posedge clk) begin
    v1=alu_out;
    v2=wb_val;
    d1=alu_rd;
    d2=alu_rd;
    if(rst==1)begin
        ins_dec_out <= nop;
        en1<= 0;
        en2<= 0;
        for (i = 0; i < 32; i = i + 1)
            mem[i] <= 0;
    end
    else begin
        ins_dec_out <= ins_dec_in;
        en1= alu_reg_w_en;
        en2=wb_en;
        case({en1,en2})
            2'b00:begin mem[0] = mem[0]; end
                
            2'b01:begin
                mem[d2] = (d2==0)? 32'b0 : v2;
            end
            2'b10:begin
                mem[d1] = (d1==0)? 32'b0 : v1;
            end
            2'b11:begin
                if(d1==d2)begin
                    mem[d1] = (d1==0)? 32'b0 : v1;
                end
                else begin
                    mem[d1] = (d1==0)? 32'b0 : v1;
                    mem[d2] = (d2==0)? 32'b0 : v2;
                end
            end
        endcase  
        end
    end
    
    assign rs1= ins_dec_out[19:15];
    assign rs2= ins_dec_out[24:20];
    
    always@(negedge clk)begin    
        ro1= mem[rs1];
        ro2= mem[rs2];
    end
        
    assign hz1 = wb_en == 1 ? (rs1==wb_reg ? wb_val : ro1 ) : ro1;
    assign hz2 = wb_en == 1 ? (rs2==wb_reg ? wb_val : ro2 ) : ro2;  
    assign alu_in1 = alu_reg_w_en == 1 ? (rs1==alu_rd ? alu_out : hz1 ) : ro1;
    assign alu_in2 = alu_reg_w_en == 1 ? (rs2==alu_rd ? alu_out : hz2 ) : ro2;  

endmodule
