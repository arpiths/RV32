`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2022 16:22:12
// Design Name: 
// Module Name: adder
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
///////////////////////////////////////////////////////////////////////////////

module ALU(clk,rst,ins_dec_out,alu_in1,alu_in2,alu_in3,pc2,
        alu_out,alu_reg_w_en,alu_rd,    
        f3,d_r_en,d_w_en,d_add,
        br_ctrl,pc_out);
    
    input[31:0] ins_dec_out,alu_in1, alu_in2,pc2,alu_in3 ;       
    input clk,rst;
    
    output reg [4:0] alu_rd;
    output reg [31:0] alu_out,d_add,pc_out;
    output reg alu_reg_w_en, d_w_en, d_r_en,br_ctrl;
    output reg [2:0] f3;
    
    reg[31:0] arg1,arg2,arg3,ins,pc_in;
           
    reg [2:0] f3_w;
    reg[6:0] op,f7;    
    reg[4:0] rs1,rs2,rd;
    
    reg lr,al;
    
    wire[31:0] sum,diff,shift_out,xor_out,and_out,or_out,imm_str;
    wire[31:0] s_comp, us_comp;
    shift    shf   (lr,al,arg1,arg2,shift_out);
    adder    add12 (arg1,arg2,sum,diff);    
    compare  comp  (arg1,arg2,s_comp,us_comp);
    gate_l   g1    (arg1,arg2,xor_out,or_out,and_out);
    
    wire[31:0] sum2,diff2,shift_out2,xor_out2,and_out2,or_out2,imm_str2;
    wire[31:0] s_comp2, us_comp2;
    shift    shf2  (lr,al,arg1,arg2,shift_out2);
    adder    add13 (arg1,arg3,sum2,diff2);    
    compare  comp2 (arg1,arg3,s_comp2,us_comp2);
    gate_l   g2    (arg1,arg3,xor_out2,or_out2,and_out2);
    
    wire[31:0] pc_sum1,pc_sum2;
    PCadder pca(pc_in,arg3,pc_sum1,pc_sum2);
    
    reg[31:0] nop;
    initial begin 
        nop <= 32'h0033 ; 
    end
    
    always@(posedge clk) begin 
    if(rst==1 || br_ctrl ==1) begin   
            ins <=nop;
            pc_in=0;     
            f3<=0;
            op<=nop[6:0];
            rd<=nop[11:7];    
            rs1<=nop[19:15];
            rs2<=nop[24:20];
            f7<=nop[31:25];   
            arg1=0;arg2=0;arg3=0;       
        end 
        else begin 
            ins  <= ins_dec_out;                        
            arg1 <= alu_in1;
            arg2 <= alu_in2;
            arg3 <= alu_in3;
            pc_in <= pc2;
            f3 <=ins_dec_out[14:12];
            op <=ins_dec_out[6:0];
            rd <=ins_dec_out[11:7];    
            rs1<=ins_dec_out[19:15];
            rs2<=ins_dec_out[24:20];
            f7 <=ins_dec_out[31:25];
        end
   end
   
   always@(*)begin
       lr = f3==3'b001 ? 1'b1 : 1'b0;                                          
       al = f7==7'b0   ? 1'b0 : 1'b1;   
       
       alu_rd = rd;
       d_add = sum2;
       casez(op)
            /////////////////////integer r-r////////////////////////////
            7'b0110011:begin 
                d_r_en = 0;
                d_w_en = 0;
                br_ctrl=0;
                pc_out = 0;
                alu_reg_w_en = 1'b1;               
                case(f3)
                    3'b000:begin alu_out = (f7==7'b0)?sum:diff; end        //add,sub
                    3'b001:begin alu_out=shift_out  ;end           //sll
                    3'b010:begin alu_out=s_comp;end   //slt
                    3'b011:begin alu_out=us_comp; end //sltu
                    3'b100:begin alu_out=xor_out ;end                      //xor
                    3'b101:begin alu_out=shift_out; end                     //srl,sra 
                    3'b110:begin alu_out=or_out ;end                       //or
                    3'b111:begin alu_out=and_out ;end                      //and
                endcase
            end
            /////////////////////integer reg imm/////////////////////////
            7'b0010011: begin                
                d_r_en =0;
                d_w_en =0;
                alu_reg_w_en = 1'b1;   
                br_ctrl=0; 
                pc_out = 0;            
                casez(f3)
                    3'b000:begin alu_out = sum2; end //addi
                    3'b010:begin alu_out={31'b0,s_comp2};end   //slt
                    3'b011:begin alu_out={31'b0,us_comp2}; end //sltu
                    3'b100:begin alu_out=xor_out2; end //xori
                    3'b110:begin alu_out=or_out2; end  //ori
                    3'b111:begin alu_out=and_out2; end //andi                                    
                    ///////////////// Constant shift/////////////////
                    3'b001:begin alu_out=shift_out2;  end //sll
                    3'b101:begin alu_out=shift_out2;  end  //srl,sra
                    default:begin alu_out =sum2 ; end
                endcase
            end
            ////////////////////////////mem load////////////////////////
            7'b0000011:begin                
                d_r_en =1'b1;
                d_w_en =0;                
                alu_reg_w_en = 0;                 
                alu_out= 0;
                br_ctrl=0;
                pc_out = 0;
            end
            ///////////////////////////// mem store /////////////////////
            7'b0100011:begin                  
                d_r_en =0;
                d_w_en =1'b1;   
                alu_reg_w_en = 0; 
                br_ctrl=0; 
                pc_out = 0;                               
                casez(f3)
                    3'b000:begin 
                        alu_out = arg2[7:0];
                    end
                    3'b001:begin 
                        alu_out = arg2[15:0];
                    end
                    3'b010:begin 
                       alu_out = arg2 ;
                   end
                    default: begin
                        alu_out = arg2;
                    end 
                endcase                                  
            end
            //////////////////////////////***///////////////////////////
            7'b0110111:begin // LUI                
                d_r_en = 0;
                d_w_en = 0;   
                alu_reg_w_en = 1;  
                alu_out = arg3;
                br_ctrl=0;
            end
            7'b0010111:begin//AUIPC
                d_r_en =0;
                d_w_en =0;   
                alu_reg_w_en = 1;  
                alu_out = pc_sum1;  
                br_ctrl = 0;
                pc_out = 0;
             end
             7'b1101111:begin //JAL
                d_r_en =0;
                d_w_en =0;   
                alu_reg_w_en = 1;  
                alu_out = pc_sum2;//return address
                pc_out = pc_sum1;
                br_ctrl = 1; 
             end

             7'b100111:begin //JALR
                d_r_en =0;
                d_w_en =0;                   
                alu_reg_w_en = 1;  
                alu_out = pc_sum2;//return address
                pc_out = sum2;
                br_ctrl = 1;
             end
             
             7'b1100011:begin
                pc_out = pc_sum1;
                d_r_en =0;
                d_w_en =0;                   
                alu_reg_w_en = 0; 
                alu_out=0;
                case(f3)
                    3'b000:begin
                        br_ctrl = arg1 == arg2 ? 1: 0;
                    end
                    3'b001:begin
                        br_ctrl = $signed(arg1) != $signed(arg2)? 1: 0; 
                    end
                    3'b100:begin
                        br_ctrl = $signed(arg1) < $signed(arg2)? 1: 0;
                    end
                    3'b101:begin
                        br_ctrl = $signed(arg1) >= $signed(arg2)? 1: 0;
                    end
                    3'b110:begin
                        br_ctrl = arg1 < arg2 ? 1: 0 ;  
                    end
                    3'b111:begin
                        br_ctrl = arg1 >= alu_in2 ? 1: 0;  
                    end
                    default:begin
                        br_ctrl = 0;
                    end
                endcase
            end
                         
            default:begin                  
                d_r_en = 0;
                d_w_en = 0;                   
                alu_reg_w_en = 0;
                alu_out=0;
            end                    
        endcase
       
    end
       
endmodule


////////////////////////////////////////////////////////////////
module adder(arg1,arg2,sum,diff);
    input[31:0] arg1,arg2;
    output[31:0] sum,diff;
    assign sum  = $signed(($signed(arg1) + $signed(arg2)));
    assign diff = $signed(($signed(arg1) - $signed(arg2)));
endmodule 

module PCadder(PC,arg,sum1,sum2);
    input[31:0] PC,arg;
    output[31:0] sum1,sum2;
    assign sum1  = $signed(($signed(PC) + $signed(arg)));
    assign sum2 = $signed(($signed(PC) + 4));
endmodule

module shift(lr,al,arg1,arg2,shift_out);
    input lr,al;
    input[31:0] arg1,arg2;
    output[31:0] shift_out;
    wire[31:0] sll,srl,sra;
    assign sll = arg1 << arg2[4:0];
    assign srl = arg1 >> arg2[4:0];
    assign sra = $signed(arg1)>>>arg2[4:0];
    assign shift_out = (lr == 1'b1 ? sll : (al == 1'b0 ? srl : sra ) );
endmodule

module compare(arg1,arg2,s_comp,us_comp);
    input[31:0] arg1,arg2;
    output[31:0] s_comp, us_comp;    
    assign s_comp = ($signed(arg1) < $signed(arg2)) ? 1 : 0;
    wire[31:0] a1,a2;
    assign a1=($signed(arg1) < 0) ? -$signed(arg1) : arg1;
    assign a2=($signed(arg2) < 0) ? -$signed(arg2) : arg2;
    assign us_comp = a1 < a2 ? 1 : 0;
endmodule

module gate_l(in1,in2,xor_out,or_out,and_out);
    input[31:0] in1,in2;
    output[31:0] xor_out,or_out,and_out;
    assign xor_out = in1 ^ in2;
    assign and_out = in1 & in2;
    assign or_out = in1 | in2;
endmodule



