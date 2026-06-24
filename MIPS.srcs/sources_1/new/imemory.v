`timescale 1ns / 1ps
module imemory(
        input [31:0]PC,
        output reg [31:0]instruction
    );
 
reg [31:0]imem [0:255];   
integer i;
initial begin
    for (i = 0; i < 256; i = i + 1) begin
        imem[i] = 32'b0;
    end
end
always@*begin
    instruction=imem[PC>>2];
end
endmodule
