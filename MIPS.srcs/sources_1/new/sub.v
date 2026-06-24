`timescale 1ns / 1ps
module sub(
    input [31:0]A,B,
    output reg [31:0]diff,
    output reg overflow,
    output reg borrow
    );
    
always @* begin 
diff=A-B;

if(A[31]!=B[31] && B[31]==diff[31])
    overflow=1;
else 
    overflow=0;
    
borrow=(A<B);
end
endmodule
