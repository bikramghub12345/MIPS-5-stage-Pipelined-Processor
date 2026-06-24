`timescale 1ns / 1ps
module pr_F_D(
    input clk, reset, stall,flush,
    input [31:0]PC_plus_4,instruction,
    output reg [31:0]PC_plus_4_out,instruction_out
    
);
always@(posedge clk)begin

    if(reset || flush)begin
        PC_plus_4_out<=32'b0;
        instruction_out<=32'b0;
    end
    else if(!stall) begin
    PC_plus_4_out<=PC_plus_4;
    instruction_out<=instruction;
    end
end
endmodule