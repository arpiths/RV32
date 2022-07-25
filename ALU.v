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
    
    reg[31:0] arg1,arg2,arg3,ins,pc_in,in1,in2,in3;
           
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
//            f3<=0;   
            arg1=0;arg2=0;arg3=0;       
        end 
        else begin 
            ins  <= ins_dec_out;                        
            in1 <= alu_in1;
            in2 <= alu_in2;
            in3 <= alu_in3;
            pc_in <= pc2;

        end
   end
   
   always@(*)begin
     f3 = ins[14:12];
     op = ins[6:0];
     rd = ins[11:7];    
     rs1= ins[19:15];
     rs2= ins[24:20];
     f7 = ins[31:25];
       lr = f3==3'b001 ? 1'b1 : 1'b0;                                          
       al = f7==7'b0   ? 1'b0 : 1'b1;   
       
       alu_rd = rd;
       
       casez(op)
            /////////////////////integer r-r////////////////////////////
            7'b0110011:begin 
                arg1 = in1;
                arg2 = in2;
                d_r_en = 0;
                d_w_en = 0;
                br_ctrl=0;
                pc_out = 0;
                d_add = sum;
                alu_reg_w_en = 1'b1;               
                case(f3)
                    3'b000:begin alu_out = (f7==7'b0)?sum:diff; end        //add,sub
                    3'b001:begin alu_out=shift_out  ;end           //sll
                    3'b010:begin alu_out=s_comp;end   //slt
                    3'b011:begin alu_out=us_comp; end //sltu
                    3'b100:begin alu_out=xor_out ;end                      //xor
                    3'b101:begin alu_out=shift_out; end                     //srl,sra 
                    3'b110:begin alu_out=or_out ;end                       //or
                    3'b111:begin alu_out=and_out ;end
                    default:begin alu_out=sum;end                      //and
                endcase
            end
            /////////////////////integer reg imm/////////////////////////
            7'b0010011: begin
                arg1= in1;
                arg2= in3;                
                d_r_en =0;
                d_w_en =0;
                alu_reg_w_en = 1'b1;   
                br_ctrl=0; 
                
                pc_out = 0;            
                casez(f3)
                    3'b000:begin alu_out = sum; end //addi
                    3'b010:begin alu_out={31'b0,s_comp};end   //slt
                    3'b011:begin alu_out={31'b0,us_comp}; end //sltu
                    3'b100:begin alu_out=xor_out; end //xori
                    3'b110:begin alu_out=or_out; end  //ori
                    3'b111:begin alu_out=and_out; end //andi                                    
                    ///////////////// Constant shift/////////////////
                    3'b001:begin alu_out=shift_out;  end //sll
                    3'b101:begin alu_out=shift_out;  end  //srl,sra
                    default:begin alu_out =sum ; end
                endcase
            end
            ////////////////////////////mem load////////////////////////
            7'b0000011:begin   
                arg1=in1;
                arg2=in3;             
                d_r_en =1'b1;
                d_w_en =0;                
                alu_reg_w_en = 0;                 
                alu_out= 0;
                br_ctrl=0;
                pc_out = 0;
                
            end
            ///////////////////////////// mem store /////////////////////
            7'b0100011:begin 
                arg1=in1;
                arg2=in3;                                 
                d_r_en =0;
                d_w_en =1'b1;   
                alu_reg_w_en = 0; 
                br_ctrl=0; 
                pc_out = 0; 
                d_add = sum;                              
                casez(f3)
                    3'b000:begin 
                        alu_out = in2[7:0];
                    end
                    3'b001:begin 
                        alu_out = in2[15:0];
                    end
                    3'b010:begin 
                       alu_out = in2 ;
                   end
                    default: begin
                        alu_out = in2;
                    end 
                endcase                                  
            end
            //////////////////////////////***///////////////////////////
            7'b0110111:begin // LUI   
                arg1=in1;
                arg2=in2;             
                d_r_en = 0;
                d_w_en = 0;   
                alu_reg_w_en = 1;  
                alu_out = in3;
                br_ctrl=0;
                
            end
            7'b0010111:begin//AUIPC
                arg1=pc_in;
                arg2=in3;
                d_r_en =0;
                d_w_en =0;   
                alu_reg_w_en = 1;  
                alu_out = sum;  
                br_ctrl = 0;
                pc_out = 0;
                
             end
             7'b1101111:begin //JAL
             arg1=pc_in;
             arg2=in3;
             
                d_r_en =0;
                d_w_en =0;   
                alu_reg_w_en = 1;  
                alu_out = pc_in+4;//return address
                pc_out = sum;
                br_ctrl = 1; 
             end

             7'b100111:begin //JALR
             arg1=in1;
             arg2=in3;
                d_r_en =0;
                d_w_en =0;                   
                alu_reg_w_en = 1;  
                alu_out = pc_in+4;//return address
                pc_out = sum;
                br_ctrl = 1;
                
             end
             
             7'b1100011:begin //Branch
                arg1=pc_in;
                arg2=in3;
                pc_out = sum;                
                d_r_en =0;
                d_w_en =0;                   
                alu_reg_w_en = 0; 
                alu_out=0;
                
                case(f3)
                    3'b000:begin
                        br_ctrl = in1 == in2 ? 1: 0;
                    end
                    3'b001:begin
                        br_ctrl = $signed(in1) != $signed(in2)? 1: 0; 
                    end
                    3'b100:begin
                        br_ctrl = $signed(in1) < $signed(in2)? 1: 0;
                    end
                    3'b101:begin
                        br_ctrl = $signed(in1) >= $signed(in2)? 1: 0;
                    end
                    3'b110:begin
                        br_ctrl = in1 < arg2 ? 1: 0 ;  
                    end
                    3'b111:begin
                        br_ctrl = in1 >= alu_in2 ? 1: 0;  
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
                br_ctrl=0;
                
                pc_out=0;
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



