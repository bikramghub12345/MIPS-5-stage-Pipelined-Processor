`timescale 1ns / 1ps
module regfile(
    input clk,regWrite,
    input [4:0]reg1,reg2,write_reg,
    input [31:0]write_data,
    output reg [31:0]data1,data2
    );
reg [31:0] registers[0:31]; //0 to 31 registers each of size 32 bit
    
integer i;  //initialize all the registers to 0, $0 may remain X, if not done.
initial begin
    for(i = 0; i < 32; i = i + 1) begin
        registers[i] = 32'b0;
    end
end

always@* begin       //async read
    data1=registers[reg1];
    data2=registers[reg2];
    end
always@(posedge clk)begin      //sync write
    if(regWrite==1 && write_reg!=5'b00000)begin
        registers[write_reg]<=write_data;
        end
    end
endmodule
