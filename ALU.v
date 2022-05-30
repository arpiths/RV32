module ALU(clk,rst,ins,alu_in1,alu_in2,
        alu_out,zero,   
        alu_reg_w_en,alu_rd,    
        f3,d_r_en,d_w_en,d_add);
    
    input[31:0] ins,alu_in1, alu_in2;       
    input clk,rst;
    
    output reg [4:0] alu_rd;
    output reg [31:0] alu_out,d_add;
    output reg zero, alu_reg_w_en, d_w_en, d_r_en;
    output reg [2:0] f3;
    
    wire [2:0] f3_w;
    wire[6:0] op,f7;    
    wire[4:0] rs1,rs2,rd;
    assign f3_w=ins[14:12];
    assign op=ins[6:0];
    assign rd=ins[11:7];    
    assign rs1=ins[19:15];
    assign rs2=ins[24:20];
    assign f7=ins[31:25];

    
    wire[31:0] sum,diff,shift_out,xor_out,and_out,or_out,arg1,arg2;
    wire[2:0] s_comp, us_comp;
    
    assign arg1 = alu_in1;
    assign arg2 = alu_in2;  
            
    wire lr,al;
    assign lr = f3_w==3'b001 ? 1'b1 : 1'b0;                                          
    assign al = f7==7'b0 ? 1'b0 : 1'b1;
    
    shift    shf  (lr,al,arg1,arg2,shift_out);
    adder    add  (arg1,arg2,sum,diff);
    compare  comp (arg1,arg2,s_comp,us_comp);
    gate_l   g1   (arg1,arg2,xor_out,or_out,and_out);
    
    wire[31:0] mem_sel;
    assign mem_sel = f3_w==3'b000 ? 32'h000F : (f3_w==3'b001 ? 32'h00FF : (f3_w==3'b000 ? 32'hFFFF :32'b0));     
    wire [31:0] mem_str;
    assign mem_str = alu_in2 & mem_sel;           

    
    always@(posedge clk) begin
        if(rst) begin
            f3<=0;
                zero   <= 0;
                d_r_en <= 0;
                d_w_en <= 0;
                d_add  <= 0;
                alu_rd <= 0;
                alu_reg_w_en <= 0;
                alu_out<=0;               
        end
               
        else begin        
        f3<=f3_w;
        casez(op)
            /////////////////////integer r-r////////////////////////////
            7'b0110011:begin   
                zero   <= 0;
                d_r_en <= 0;
                d_w_en <= 0;
                d_add  <= 0;
                alu_rd <= rd;
                alu_reg_w_en <= 1'b1;               
                case(f3)
                    3'b000:begin alu_out <= (f7==7'b0)?sum:diff; end        //add,sub
                    3'b001:begin alu_out=shift_out  ;end           //sll
                    3'b010:begin alu_out<={31'b0,s_comp[2]};end   //slt
                    3'b011:begin alu_out<={31'b0,us_comp[2]}; end //sltu
                    3'b100:begin alu_out<=xor_out ;end                      //xor
                    3'b101:begin alu_out<=shift_out; end                     //srl,sra 
                    3'b110:begin alu_out<=or_out ;end                       //or
                    3'b111:begin alu_out<=and_out ;end                      //and
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
                case(f3)
                    3'b000:begin alu_out <= sum; end //addi
                    3'b010:begin alu_out<={31'b0,s_comp[2]};end   //slt
                    3'b011:begin alu_out<={31'b0,us_comp[2]}; end //sltu
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
                zero <= 0;
                d_r_en <=1'b1;
                d_w_en <=0;                
                alu_rd <= rd;
                alu_reg_w_en <= 1'b1;                 
                d_add <= sum; 
                alu_out<= 0;
            end
            ///////////////////////////// mem store /////////////////////
            7'b0100011:begin  
                zero <= 0;
                d_r_en <=0;
                d_w_en <=1'b1;   
                alu_rd <= 0;
                alu_reg_w_en <= 0;                 
                d_add <= sum ;
                alu_out<= mem_str;                                     
            end
            //////////////////////////////***///////////////////////////
            7'b0110111:begin // LUI
                zero <= 0;
                d_r_en <=0;
                d_w_en <=0;   
                alu_rd <= 0;
                alu_reg_w_en <= 1;  
                d_add <= sum ;
                alu_out<= arg2;
            end

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
            
            default:begin                
                f3<=3'b010;  
                zero   <= 1;
                d_r_en <= 1;
                d_w_en <= 1;
                d_add  <= 32'b01111;
                alu_rd <= 5'b0111;
                alu_reg_w_en <= 0;
                alu_out<=32'h011111;
            end
                
                    
        endcase
        end
    end
       
endmodule


////////////////////////////////////////////////////////////////
module adder(arg1,arg2,sum,diff);
    input[31:0] arg1,arg2;
    output[31:0] sum,diff;
    assign sum = $signed(arg1) + $signed(arg2);
    assign diff = $signed(arg1) - $signed(arg2);
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

module gate_l(in1,in2,xor_out,or_out,and_out);
    input[31:0] in1,in2;
    output[31:0] xor_out,or_out,and_out;
    assign xor_out = in1 ^ in2;
    assign and_out = in1 & in2;
    assign or_out = in1 | in2;
endmodule



