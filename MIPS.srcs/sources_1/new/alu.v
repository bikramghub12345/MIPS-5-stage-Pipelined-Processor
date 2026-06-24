`timescale 1ns / 1ps
module alu(
    input [31:0]a,b,
    input [3:0]alu_control,
    input [4:0]shamt, //shift amount
    input [15:0]immediate,
    output reg [31:0]y,
    output reg zero, overflow, sign
    );
    
wire [31:0]add_sum;
wire add_cout,add_overflow;

wire [31:0]sub_diff;
wire sub_borrow, sub_overflow;

adder adder_instance(.A(a),.B(b),.C(1'b0),.Cout(add_cout),.sum(add_sum),.overflow(add_overflow));
sub sub_instance(.A(a),.B(b),.diff(sub_diff),.borrow(sub_borrow),.overflow(sub_overflow));

always@* begin 
    overflow=1'b0;
    case (alu_control)
        4'b0000: begin       
                y=add_sum;         //add
                overflow=add_overflow;
               end
        4'b0001: begin
                y=sub_diff;         //sub
                overflow=sub_overflow;
               end
        4'b0010: y=a&b;
        4'b0011: y=a|b;
        4'b0100: y=a^b;
        4'b0101: y=~(a|b);
        4'b0110: y=($signed(a) < $signed(b))? 32'b1:32'b0;  //slt
        4'b0111: y=(a < b)? 32'b1:32'b0;  //sltu
        4'b1000: y=(b << shamt);  //1000 SLL
        4'b1001: y=(b>> shamt);  //1001 SRL
        4'b1010: y=($signed(b)>>> shamt);  //1010 SRA
        4'b1011: y=immediate<<16; //for lui
        default: y = 32'b0;
       endcase
sign=y[31];
zero=(y==0);
     end
endmodule
