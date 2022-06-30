// `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 30.05.2022 16:22:12
//// Design Name: 
//// Module Name: adder
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
//////////////////////////////////////////////////////////////////////////////////

//module brnch(clk,ins_dec_in,rst,pc1,
//            in1,in2,
//            ins_dec_out,pc2,br_en
//            );
    
//    input rst,clk;
//    input[31:0] ins_dec_in,in1,in2,pc1;   
//    output reg [31:0] ins_dec_out,pc2;
//    output reg br_en;
    
//    wire[31:0] nop;
//    assign nop = 32'h00000033;    
        
//    wire[4:0] rs1,rs2,rd;       
//    wire[6:0] op,f7;    
//    wire [2:0] f3;
    
//    assign f7=ins_dec_out[31:25];
//    assign op=ins_dec_out[6:0];
//    assign rd=ins_dec_out[11:7];
//    assign rs1=ins_dec_out[19:15];
//    assign rs2=ins_dec_out[24:20];
//    assign f3= ins_dec_out[14:12];      
    
//    // generate and select immediate vals
//    wire signed [31:0] imm
//    assign imm = $signed({f7[6],rd[0],f7[5:0],rd[4:1],1'b0});  //Branch //
    
    
//    wire [31:0] in1,in2;   
     
//    reg [31:0] r_in;    
          
//    always @(posedge clk)begin       
//            ins_dec_out <= rst ? nop : (br_en ? nop : ins_dec_in);
//            if(br_en)begin
//                alu_in1 = 0;
//                alu_in2 = 0;
//                br_en = 0;
//            end                
//    end  
    
//    hazard hz( rs1,rs2,alu_rd,rso1,rso2,alu_out,in1,in2);
    
//    always@(*) begin       
//    if(rst == 1'b1)begin             
//            alu_in1 = 0;        
//            alu_in2 = 0;  
//            br_en = 0;
//            pc2= 0;       
//         end         
//    else 
//    else begin             
//            //data hazard 
//            alu_in1 = in1;               
//            casez(op)                
//            7'b0110011:begin alu_in2 = rso2 ; end   //integer r-r//                             
//            7'b0010011:begin alu_in2 = imm4 ; end   //integer reg imm//
//            7'b0000011:begin alu_in2 = imm4 ; end   //mem load//
//            7'b0100011:begin alu_in2 = imm5 + rso2 ; end //mem store//
//            7'b0110111:begin alu_in2 = imm1 ;  end//LUI//               
////            7'b0010111: in2 = imm1 ; //AUIPC
//            7'b1101111:begin alu_in2 = imm2 ;  end//JAL
////            7'b0010111:begin  = imm4 ; end //JALR
//            7'b1100011:begin      //Branch
//                alu_in2 = 1;
//                casez(f3)
//                    3'b000:begin  //beq
//                        if(alu_in1 == alu_in2) begin pc2 = ($signed(pc1) + $signed(imm3)); 
//                        br_en = 1;end
//                        else begin
//                            br_en = 0;
//                            pc2 = pc1;
//                        end                                 
//                    end
//                    3'b001:begin  //bne
//                        if(alu_in1 != alu_in2) begin pc2 = ($signed(pc1) + $signed(imm3)); 
//                        br_en = 1;end
//                        else begin
//                            br_en = 0;
//                            pc2 = pc1;
//                        end 
//                    end
//                    3'b100:begin  //blt
//                        if($signed(alu_in1) < $signed(alu_in2)) begin pc2 = ($signed(pc1) + $signed(imm3)); 
//                        br_en = 1;end
//                        else begin
//                            br_en = 0;
//                            pc2 = pc1;
//                        end 
//                    end
//                    3'b101:begin  //bge
//                        if($signed(alu_in1) >= $signed(alu_in2)) begin pc2 = ($signed(pc1) + $signed(imm3)); 
//                        br_en = 1;end
//                        else begin
//                            br_en = 0;
//                            pc2 = pc1;
//                        end 
//                    end 
//                    3'b110:begin  //bltu
//                        if(alu_in1 < alu_in2) begin pc2 = ($signed(pc1) + $signed(imm3));  
//                        br_en = 1;end
//                        else begin
//                            br_en = 0;
//                            pc2 = pc1;
//                        end 
//                    end
//                    3'b111:begin  //bgeu
//                        if(alu_in1 <= alu_in2) begin 
//                            pc2 = ($signed(pc1) + $signed(imm3)); 
//                            br_en = 1;
//                        end
//                        else begin
//                            br_en = 0;
//                            pc2 = pc1;
//                        end 
//                    end
//                    default: begin
//                        br_en = 0;
//                        pc2 = pc1;
//                    end 
//                endcase
//            end
//                7'b0010111 : begin //AUIPC
//                    alu_in2 = 0;
//                    pc2 = ($signed(pc1) + $signed(imm1)); 
//                    br_en = 1 ;             
//                end
//                 7'b1100111:begin //JALR
//                    pc2 = ($signed(alu_in1) + $signed(imm4)); 
//                    alu_in2 = pc1 + 32'd4;
//                    br_en =1;
//                 end
//                default: begin  
//                    alu_in2 = in2;
//                    pc2 = pc1;
//                    br_en = 0;
//                end
//            endcase           
//        end
//    end
//endmodule

//module hazard(input[4:0] rs1,rs2,alu_rd ,input[31:0] rso1,rso2,alu_out,
//    output [31:0] in1,in2
//    );
//    assign in1 = rs1==alu_rd? alu_out : rso1;
//    assign in2 = rs2==alu_rd? alu_out : rso2; 
//endmodule
