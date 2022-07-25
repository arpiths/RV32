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


module Read(clk,PC,br_ctrl,rst,ins_dec_in,
            alu_out,alu_reg_w_en,alu_rd,
            wb_val,wb_en,wb_reg,
            alu_in1,alu_in2,alu_in3,ins_dec_out,pc2
            );
    input clk,rst,wb_en,alu_reg_w_en,br_ctrl;
    input [31:0]ins_dec_in,alu_out,wb_val,PC;
    input[4:0] wb_reg,alu_rd;
    output reg[31:0] ins_dec_out,alu_in3,pc2, alu_in1,alu_in2;
    
    wire[4:0] rs1,rs2;
    
    assign rs1=ins_dec_in[19:15];
    assign rs2=ins_dec_in[24:20]; 
    wire[31:0] rso1,rso2;
    regf regfile(clk,rst,wb_en,br_ctrl,
        rs1,rs2,wb_reg,
        wb_val,
        rso1,rso2);
    
    reg[31:0] nop;
    initial begin
        nop=32'h000033; 
    end
    reg[31:0] hz1,hz2;
    reg[4:0] d1,d2,r1,r2;  
    integer i;
    reg en1,en2,z;   
    reg[31:0] v1,v2,ro1,ro2,pc1,ins;      
    reg[6:0] op;
    reg [31:0] imm1,imm2,imm3,imm4,imm5;
    always@(posedge clk) begin
        ins_dec_out <= br_ctrl == 1 ? nop : ins_dec_in;
        v2 <=wb_val;
        d2 <=wb_reg;  
        pc2 <= PC;
        en2 <= wb_en;
        r1 <= ins_dec_in[19:15];
        r2 <= ins_dec_in[24:20];
        en1 <= alu_reg_w_en;
       imm1 = {ins_dec_in[31:12],12'b0}; // lui, auipc
       imm2 = $signed({ins_dec_in[31],ins_dec_in[19:12],ins_dec_in[20],ins_dec_in[30:21],1'b0});       //**JAL**//
       imm3 = $signed({ins_dec_in[31],ins_dec_in[7],ins_dec_in[30:25],ins_dec_in[11:8],1'b0});  //Branch //
       imm4 = $signed(ins_dec_in[31:20]);        //reg-imm , mem load  //jalr
       imm5 = $signed({ins_dec_in[31:25],ins_dec_in[11:7]});         //mem store
    end
    
    always@(*)begin
        casez(ins_dec_out[6:0])                
            7'b0110011:begin alu_in3 = 0 ; end   //integer r-r//                             
            7'b0010011:begin alu_in3 = imm4 ; end   //integer reg imm//
            7'b0000011:begin alu_in3 = imm4 ; end   //mem load//
            7'b0100011:begin alu_in3 = imm5 ; end //mem store//
            7'b0110111:begin alu_in3 = imm1 ;  end  //LUI AUIPC//               
            7'b1101111:begin alu_in3 = imm2 ;  end//JAL
            7'b0010111:begin alu_in3 = imm4 ; end //JALR          
            7'b1100011:begin alu_in3 = imm3 ; end //branch   
            default: begin  
                alu_in3 = 0;
            end
        endcase
     hz1  = r1 == 0 ? 0: (wb_en == 1 ? (wb_reg == r1 ? wb_val : rso1) : rso1 );
     hz2  = r2 == 0 ? 0: (wb_en == 1 ? (wb_reg == r2 ? wb_val : rso2) : rso2 );
     if(br_ctrl == 1)begin
        alu_in1=0;
        alu_in2=0;
     end
     else begin    
         alu_in1 = r1 == 0 ? 0 :(alu_reg_w_en == 1 ? (alu_rd == r1 ? alu_out : hz1) : hz1 );
         alu_in2 = r2 == 0 ? 0 :(alu_reg_w_en == 1 ? (alu_rd == r2 ? alu_out : hz2) : hz2 );
     end   
    end


endmodule

module regf( clk,rst,wen1,br_ctrl,
        rs1,rs2,wr1,
        wval1,
        rso1,rso2);
    
    input clk,rst,wen1,br_ctrl;
    input[4:0] rs1,rs2,wr1;
    input[31:0] wval1;
    output reg[31:0] rso1,rso2;
    
    reg[31:0] mem[0:31]; 
    integer i;
    
    always@(posedge clk)begin
        if(rst==1)begin
            for (i = 0; i < 32; i = i + 1)
                mem[i] <= 0;
    
        end
        
//        else if(br_ctrl)begin
//            mem[0] = mem[0];
//        end
        
        else begin
            if(wen1==1)begin 
                mem[wr1] <= wr1==0? 0: wval1;
            end
            else begin
                mem[0] <= 0;
            end
        end
    end
   
    always@(negedge clk)begin
        if(rst==1)begin
            rso1<=0;
            rso2<=0;
        end
        else begin
            rso1<=mem[rs1];
            rso2<=mem[rs2];        
        end
    end
endmodule

//module hazard(wb_en,alu_en,
//                wb_reg,alu_rd,rs1,rs2,
//                wb_val,alu_out,rso1,rso2,
//                out1,out2);
                
//    input wb_en,alu_en;
//    input[4:0]  wb_reg,alu_rd,rs1,rs2;
//    input[31:0] wb_val,alu_out,rso1,rso2;
//    output[31:0] out1,out2;
    
//    wire[31:0] hz1,hz2;
    
//    assign hz1  = wb_reg == 0 ? 0: (wb_en == 1 ? (wb_reg == rs1 ? wb_val : rso1) : rso1 );
//    assign hz2  = wb_reg == 0 ? 0: (wb_en == 1 ? (wb_reg == rs1 ? wb_val : rso2) : rso2 );

//    assign out1 = alu_rd == 0 ? 0 :(alu_en == 1 ? (alu_rd == rs1 ? alu_out : hz1) : hz1 );
//    assign out2 = alu_rd == 0 ? 0 :(alu_en == 1 ? (alu_rd == rs1 ? alu_out : hz2) : hz2 );
    
//endmodule
