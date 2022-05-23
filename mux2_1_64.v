module mux2_1_32(sel,in1,in2,m_out);
    input[31:0] in1,in2;
    input sel;
    output[31:0] m_out;
    assign m_out = sel ? in2 : in1;
endmodule