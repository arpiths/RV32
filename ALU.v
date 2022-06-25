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

module ALU(clk,rst,ins_dec_out,alu_in1,alu_in2,
        alu_out,   
        alu_reg_w_en,alu_rd,    
        f3,d_r_en,d_w_en,d_add);
    
    input[31:0] ins_dec_out,alu_in1, alu_in2;       
    input clk,rst;
    
    output reg [4:0] alu_rd;
    output reg [31:0] alu_out,d_add;
    output reg alu_reg_w_en, d_w_en, d_r_en;
    output reg [2:0] f3;
    
    reg[31:0]arg1,arg2;
    
    assign imm_str = $signed({f7,rd});       

    wire[31:0] sum,diff,shift_out,xor_out,and_out,or_out,imm_str;
    wire[31:0] s_comp, us_comp;
    
    shift    shf  (lr,al,arg1,arg2,shift_out);
    adder    add  (arg1,arg2,sum,diff);    
    compare  comp (arg1,arg2,s_comp,us_comp);
    gate_l   g1   (arg1,arg2,xor_out,or_out,and_out);
    
//    wire[31:0] mem_sel;
//    assign mem_sel = f3_w==3'b000 ? 32'h000F : (f3_w==3'b001 ? 32'h00FF : (f3_w==3'b000 ? 32'hFFFF :32'b0));     
//    wire [31:0] mem_str;
//    assign mem_str = alu_in2 & mem_sel;           

    reg [2:0] f3_w;
    reg[6:0] op,f7;    
    reg[4:0] rs1,rs2,rd;
    reg [31:0] imm1,imm2,imm3,imm4,imm5;
//    reg [31:0]ins;    
    wire lr,al;
    assign lr = f3==3'b001 ? 1'b1 : 1'b0;                                          
    assign al = f7==7'b0 ? 1'b0 : 1'b1;
    
    always@(posedge clk) begin 
//       ins=ins_dec_out;                            
       f3=ins_dec_out[14:12];
       op=ins_dec_out[6:0];
       rd=ins_dec_out[11:7];    
       rs1=ins_dec_out[19:15];
       rs2=ins_dec_out[24:20];
       f7=ins_dec_out[31:25];
       arg1 = alu_in1;
       imm1 = {f7,rs2,rs1,f3,12'b0}; // lui, auipc
       imm2 = $signed({ins_dec_out[31],ins_dec_out[19:12],ins_dec_out[20],ins_dec_out[30:21]});       //**JAL**//
       imm3 = $signed({f7[6],rd[0],f7[5:0],rd[4:1],1'b0});  //Branch //
       imm4 = $signed({f7,rs2});        //reg-imm , mem load  //jalr
       imm5 = $signed({f7,rd});         //mem store
           casez(op)                
            7'b0110011:begin arg2 = alu_in2 ; end   //integer r-r//                             
            7'b0010011:begin arg2 = imm4 ; end   //integer reg imm//
            7'b0000011:begin arg2 = imm4 ; end   //mem load//
            7'b0100011:begin arg2 = imm5 ; end //mem store//
            7'b0110111:begin arg2 = imm1 ;  end  //LUI//               
//            7'b0010111: in2 = imm1 ; //AUIPC
            7'b1101111:begin arg2 = imm2 ;  end//JAL
//            7'b0010111:begin  = imm4 ; end //JALR            
            default: begin  
                arg2 = alu_in2;
            end
            endcase   
        end
    
    always@(negedge clk) begin   
        if(rst) begin
//            f3<=0;            
            d_r_en <= 0;
            d_w_en <= 0;
            d_add  <= 0;
            alu_rd <= 0;
            alu_reg_w_en <= 0;
            alu_out<=0;               
        end 
        else begin     
//        f3<=f3_w;
        alu_rd <= rd;
        casez(op)
            /////////////////////integer r-r////////////////////////////
            7'b0110011:begin 
                d_r_en <= 0;
                d_w_en <= 0;
                d_add  <= 0;                
                alu_reg_w_en <= 1'b1;               
                case(f3)
                    3'b000:begin alu_out <= (f7==7'b0)?sum:diff; end        //add,sub
                    3'b001:begin alu_out<=shift_out  ;end           //sll
                    3'b010:begin alu_out<=s_comp;end   //slt
                    3'b011:begin alu_out<=us_comp; end //sltu
                    3'b100:begin alu_out<=xor_out ;end                      //xor
                    3'b101:begin alu_out<=shift_out; end                     //srl,sra 
                    3'b110:begin alu_out<=or_out ;end                       //or
                    3'b111:begin alu_out<=and_out ;end                      //and
                endcase
            end
            /////////////////////integer reg imm/////////////////////////
            7'b0010011: begin                
                d_r_en <=0;
                d_w_en <=0;
                d_add <=0;
                
                alu_reg_w_en <= 1'b1;                
                case(f3)
                    3'b000:begin alu_out <= sum; end //addi
                    3'b010:begin alu_out<={31'b0,s_comp};end   //slt
                    3'b011:begin alu_out<={31'b0,us_comp}; end //sltu
                    3'b100:begin alu_out<=xor_out; end //xori
                    3'b110:begin alu_out<=or_out; end  //ori
                    3'b111:begin alu_out<=and_out; end //andi                                    
                    ///////////////// Constant shift/////////////////
                    3'b001:begin alu_out=shift_out;  end //sll
                    3'b101:begin alu_out=shift_out;  end  //srl,sra
                endcase
            end
            ////////////////////////////mem load////////////////////////
            7'b0000011:begin                
                d_r_en <=1'b1;
                d_w_en <=0;                
                
                alu_reg_w_en <= 0;                 
                d_add <= sum; 
                alu_out<= 0;
            end
            ///////////////////////////// mem store /////////////////////
            7'b0100011:begin                  
                d_r_en <=0;
                d_w_en <=1'b1;   
                
                alu_reg_w_en <= 0;                 
                d_add <= sum ;
                case(f3)
                endcase
                alu_out<= alu_in2;                                     
            end
            //////////////////////////////***///////////////////////////
            7'b0110111:begin // LUI                
                d_r_en <=0;
                d_w_en <=0;   
                
                alu_reg_w_en <= 1;  
                d_add <= sum ;
                alu_out<= arg2;
            end

             7'b1101111:begin //JAL
                d_r_en <=0;
                d_w_en <=0;   
                alu_rd <= rd;
                alu_reg_w_en <= 1;  
                d_add <= sum ;
                alu_out<= arg2;
             end

             7'b0010111:begin //JALR
                d_r_en <=0;
                d_w_en <=0;   
                
                alu_reg_w_en <= 1;  
                d_add <= sum ;
                alu_out <= arg2;
             end
            
            default:begin                  
                d_r_en <= 0;
                d_w_en <= 0;
                d_add  <= 32'b00;
                
                alu_reg_w_en <= 1;
                alu_out<=32'h00;
            end                    
        endcase
        end
    end
       
endmodule


////////////////////////////////////////////////////////////////
module adder(arg1,arg2,sum,diff);
    input[31:0] arg1,arg2;
    output[31:0] sum,diff;
    assign sum  = $signed(($signed(arg1) + $signed(arg2)));
    assign diff = $signed(($signed(arg1) - $signed(arg2)));
endmodule 

module shift(lr,al,arg1,arg2,shift_out);
    input lr,al;
    input[31:0] arg1,arg2;
    output[31:0] shift_out;
    wire[31:0] sll,srl,sra;
    assign sll = arg1<<arg2[4:0];
    assign srl = arg1>>arg2[4:0];
    assign sra = $signed(arg1)>>>arg2[4:0];
    assign shift_out = (lr == 1'b1 ? sll : (al == 1'b0 ? srl : sra ) );
endmodule

module compare(arg1,arg2,s_comp,us_comp);
    input[31:0] arg1,arg2;
    output[31:0] s_comp, us_comp;    
    assign s_comp = ($signed(arg1) < $signed(arg2)) ? 1 : 0;
    assign us_comp = ($unsigned(arg1) < $unsigned(arg2)) ? 1 : 0;
endmodule

module gate_l(in1,in2,xor_out,or_out,and_out);
    input[31:0] in1,in2;
    output[31:0] xor_out,or_out,and_out;
    assign xor_out = in1 ^ in2;
    assign and_out = in1 & in2;
    assign or_out = in1 | in2;
endmodule



