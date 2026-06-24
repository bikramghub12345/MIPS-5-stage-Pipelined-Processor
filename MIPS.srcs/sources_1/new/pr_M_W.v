`timescale 1ns / 1ps
module pr_M_W(
    input clk,reset,
    input memtoReg,regWrite,

    input [4:0]write_reg,
    input [31:0]read_data,result,

    
    output reg memtoReg_out,regWrite_out,

    output reg[4:0]write_reg_out,
    output reg[31:0]read_data_out,result_out

    );

always@(posedge clk)begin
    if(reset)begin
        memtoReg_out=0;
        regWrite_out=0;

        write_reg_out=0;
        read_data_out=0;
        result_out=0;
    end
    else begin
        memtoReg_out<=memtoReg;
        regWrite_out<=regWrite;

        write_reg_out<=write_reg;
        read_data_out<=read_data;
        result_out<=result;
    end
end
endmodule
