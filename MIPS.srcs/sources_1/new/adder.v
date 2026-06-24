`timescale 1ns / 1ps
module adder(
    input [31:0]A,B,
    input C,
    output reg Cout,
    output reg [31:0]sum,
    output reg overflow
    );
    
always @* begin 
{Cout,sum}=A+B+C;
    
if(A[31]==B[31] && A[31]!=sum[31])
    overflow=1;
else 
    overflow=0;
end
endmodule
