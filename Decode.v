`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////

module Decode(clk, ins_dec_in,rst,
            alu_out,alu_rd,alu_reg_w_en,
            rso1,rso2,
            alu_in1,alu_in2,ins_dec_out
            );
    
    input rst,clk,alu_reg_w_en;
    input[31:0] ins_dec_in,alu_out,rso1,rso2;
    input[4:0] alu_rd;    
    output reg [31:0] alu_in1,alu_in2,ins_dec_out;
    
    wire[4:0] rs1,rs2,rd;       
    wire[6:0] op,f7;    
    wire [2:0] f3;
    
    assign f7=ins_dec_out[31:25];
    assign op=ins_dec_out[6:0];
    assign rd=ins_dec_out[11:7];
    assign rs1=ins_dec_out[19:15];
    assign rs2=ins_dec_out[24:20];
    assign f3= ins_dec_out[14:12];
       
    //data hazard
    wire [31:0] in1,in2;
    assign in1= (alu_reg_w_en==1'b1)?((rs1 == alu_rd)? alu_out : rso1) : rso1 ;
    assign in2= (alu_reg_w_en==1'b1)?((rs2 == alu_rd)? alu_out : rso2) : rso1 ;
   
    // generate and select immediate vals
    wire[31:0] imm1,imm2,imm3,imm4,imm5;
    assign imm1 = $signed({f7,rs2,rs1,f3}); // lui, auipc
    // assign imm2=$signed({f7,rs2}); //**JAL**//
    // assign imm3=$signed({f7,rd});  //Branch //
    assign imm4 = $signed({f7,rs2});    //reg-imm , mem load
    assign imm5 = $signed({f7,rd});     //mem store
    
    always@(posedge clk) begin 
        ins_dec_out = ins_dec_in;
    end
    always@(*) begin
        alu_in1 = in1;                  
        case(op)
            /////////////////////integer r-r////////////////////////////
            7'b0110011:begin                     
                alu_in2 <= in2;              
            end
            /////////////////////integer reg imm/////////////////////////
            7'b0010011: begin 
                alu_in2 <=  imm4;
            end
            ////////////////////////////mem load////////////////////////
            7'b0000011:begin 
                alu_in2 <= imm4;                
            end
            ///////////////////////////// mem store /////////////////////
            7'b0100011:begin 
                alu_in2 <= imm5;
            end            
            7'b0110111:begin // LUI
                alu_in2 <= {imm1,12'b0};
            end
            // 7'b0010111:begin //AUIPC
            // //enable pc overwrite
            // //write to pc val
            // end

            // 7'1101111:begin //JAL

            // end

            //7'b1100011:begin //Branch
                //PC_sel = 
                //PC_val = 
            // end

            // 7'b0010111:begin //JALR

            // end

        endcase
               
    end
    
endmodule

