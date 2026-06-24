`timescale 1ns / 1ps
module pr_X_M(
    input clk, reset,
    input memRead,memWrite,memtoReg,memUnsigned,regWrite,
    input [1:0]memSize,
    input [4:0]write_reg,
    input [31:0]result,data2,

    output reg [1:0]memSize_out,
    output reg regWrite_out,memRead_out,memWrite_out,memtoReg_out,memUnsigned_out,
    output reg [4:0]write_reg_out,
    output reg [31:0]result_out,data2_out
    );

always@(posedge clk)begin
    if(reset)begin
        regWrite_out=0;
        write_reg_out=0;
        memRead_out=0;
        memWrite_out=0;
        memtoReg_out=0;
        memSize_out=0;
        memUnsigned_out=0;

        result_out=0;
        data2_out=0;
    end
    else begin
        regWrite_out<=regWrite;
        write_reg_out<=write_reg;
        memRead_out<=memRead;
        memWrite_out<=memWrite;
        memtoReg_out<=memtoReg;
        memSize_out<=memSize;
        memUnsigned_out<=memUnsigned;
       
        result_out<=result;
        data2_out<=data2;
    end

end
endmodule
