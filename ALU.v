module ALU(ins_dec_out,alu_in1,alu_in2,
        ALU_out,zero,   
        alu_reg_w_en,alu_rd,    
        f3,d_r_en,d_w_en,d_add);
    
    input[31:0] ins_dec_out,alu_in1, alu_in2;
    
    output reg [4:0] alu_rd;
    output reg [31:0] ALU_out,d_add;
    output reg zero, alu_reg_w_en, d_w_en, d_r_en;
    output reg[2:0] f3;

    wire[31:0] ins;
    assign ins = ins_dec_out;

    wire[6:0] op,f7;
    
    wire[4:0] rs1,rs2,rd;

    assign op=ins[6:0];
    assign rd=ins[11:7];
    
    assign rs1=ins[19:15];
    assign rs2=ins[24:20];
    assign f7=ins[31:25];

    reg [31:0] arg1,arg2;
    // wire [31:0] slt,sltu;
    reg lr,al;
    wire[31:0] sum,diff,shift_out,xor_out,and_out,or_out;
    wire[2:0] s_comp, us_comp;
    
    shift    shift(lr,al,arg1,arg2,shift_out);
    adder    add  (arg1,arg2,sum,diff);
    compare  comp (arg1,arg2,s_comp,us_comp);
    xor_gate g1   (xor_out,arg1,arg2);
    and_gate g2   (and_out,arg1,arg2);
    or_gate  g3   (or_out,arg1,arg2);
    
    wire[31:0] imm1,imm2,imm3,imm4,imm5;
    assign imm1 = $signed({f7,rs2,rs1});
    // assign imm1=$signed({f7,rs2}); //**JAL**//
    // assign imm1=$signed({f7,rd});  //Branch //
    assign imm4 = $signed({f7,rs2});    //reg-imm , mem load
    assign imm5 = $signed({f7,rd});     //mem store
   
    always@(clk) begin
        f3=ins[14:12];
        case(op)
            /////////////////////integer r-r////////////////////////////
            7'b0110011:begin   
                zero   <= 0;
                d_r_en <= 0;
                d_w_en <= 0;
                d_add  <= 0;
                alu_rd <= rd;
                alu_reg_w_en <= 1'b1;                 
                
                arg1 <= alu_in1;
                arg2 <= alu_in2;
                case(f3)
                    3'b000:begin ALU_out <= (f7==7'b0)?sum:diff; end        //add,sub
                    3'b001:begin lr=1'b1; ALU_out=shift_out  ;end           //sll
                    3'b010:begin ALU_out<=(s_comp==3'b100)?32'b01:32'b0;end   //slt
                    3'b011:begin ALU_out<=(us_comp==3'b100)?32'b01:32'b0; end //sltu
                    3'b100:begin ALU_out<=xor_out ;end                        //xor
                    3'b101:begin              //srl,sra 
                        lr=1'b0;
                        al=(f7==7'b0)? 1'b0:1'b1; 
                        ALU_out=shift_out; end
                    3'b110:begin ALU_out<=or_out ;end                       //or
                    3'b111:begin ALU_out<=and_out ;end                      //and
                endcase
            end
            /////////////////////integer reg imm/////////////////////////
            7'b0010011: begin 
                zero <= 0;
                d_r_en <=0;
                d_w_en <=0;
                d_add <=0;
                alu_rd <= rd;
                alu_reg_w_en <= 1'b1;
                
                arg1 = alu_in1;
                arg2 = imm4;
                case(f3)
                    3'b000:begin ALU_out <= sum; end //addi
                    3'b010:begin ALU_out<=(s_comp==3'b100)?32'b01:32'b0; end  //slti
                    3'b011:begin ALU_out<=(us_comp==3'b100)?32'b01:32'b0; end //sltiu
                    3'b100:begin ALU_out<=xor_out; end //xori
                    3'b110:begin ALU_out<=or_out; end  //ori
                    3'b111:begin ALU_out<=and_out; end //andi
                                    
                    ///////////////// Constant shift/////////////////
                    3'b001:begin lr=1'b1; ALU_out=shift_out;  end //sll
                    3'b101:begin //srl,sra
                        lr =1'b0;
                        al = (f7==7'b0) ? 1'b0:1'b1; 
                        ALU_out=shift_out; 
                        end
                endcase
            end
            ////////////////////////////mem load////////////////////////
            7'b0000011:begin 
                zero <= 0;
                d_r_en <=1'b1;
                d_w_en <=0;                
                alu_rd <= rd;
                alu_reg_w_en <= 1'b1; 
                arg1 <= alu_in1;
                arg2 = imm4;
                d_add = sum; 
                ALU_out<= 0;
            end
            ///////////////////////////// mem store /////////////////////
            7'b0100011:begin  
                zero <= 0;
                d_r_en <=0;
                d_w_en <=1'b1;   
                alu_rd <= 0;
                alu_reg_w_en <= 0; 
                arg1 <= alu_in1;
                arg2 = imm5;
                d_add = sum ;
                ALU_out = alu_in2;
                casez(f3)
                    3'b000:begin //sb
                        ALU_out<= alu_in2 & 32'h000F;
                    end
                    3'b001:begin //sh
                        ALU_out<=alu_in2[15:0] & 32'h00FF;
                    end
                    3'b010:begin //sw
                        ALU_out<=alu_in2;
                end                    
                endcase
            end
            //////////////////////////////***///////////////////////////
            // 7'b0110111:begin // LUI
            //     alu_rd = rd;
            //     alu_reg_w_en <= 1'b1; 
            //     d_w <= 1'b0;
            //     ALU_out <= {ins[31:12],12'b0};
            // end

            // 7'b0010111:begin //AUIPC
            // //enable pc overwrite
            // //write to pc val
            // end

            // 7'1101111:begin //JAL

            // end

            // 7'b1100011:begin //Branch

            // end

            // 7'b0010111:begin //JALR

            // end

        endcase
               
    end
       
endmodule


////////////////////////////////////////////////////////////////
module adder(arg1,arg2,sum,diff);
    input[31:0] arg1,arg2;
    output[31:0] sum,diff;
    assign sum = $signed(arg1)+$signed(arg2);
    assign diff = $signed(arg1)-$signed(arg2);
endmodule 

module shift(lr,al,arg1,arg2,shift_out);
    input lr,al;
    input[31:0] arg1,arg2;
    output[31:0] shift_out;
    assign shift_out = (lr == 1'b1 ?  arg1<<arg2[4:0] : (al ==1'b1 ? arg1>>>arg2[4:0] : arg1>>arg2[4:0]));
endmodule

module compare(arg1,arg2,s_comp,us_comp);
    input[31:0] arg1,arg2;
    output[2:0] s_comp, us_comp;
    
    assign a1= $signed(arg1);
    assign a2 = $signed(arg2);
    assign a1= $signed(arg1);
    assign a2 = $signed(arg2);

    assign s_comp = {{$signed(arg1)<$signed(arg2) ? 32'b01 : 32'b0},
                    {$signed(arg1)==$signed(arg2) ? 32'b01 : 32'b0},
                    {$signed(arg1)>$signed(arg2) ? 32'b01 : 32'b0}};

    assign us_comp ={{$unsigned(arg1)<$signed(arg2) ? 32'b01 : 32'b0},
                    {$unsigned(arg1)==$unsigned(arg2) ? 32'b01 : 32'b0},
                    {$unsigned(arg1)>$unsigned(arg2) ? 32'b01 : 32'b0}};

endmodule

module xor_gate(out,in1,in2);
    input[31:0] in1,in2;
    output[31:0] out;
    assign out = in1 ^ in2;
endmodule

module and_gate(out,in1,in2);
    input[31:0] in1,in2;
    output[31:0] out;
    assign out = in1 & in2;
endmodule

module or_gate(out,in1,in2);
    input[31:0] in1,in2;
    output[31:0] out;
    assign out = in1 | in2;
endmodule

