`timescale 1ns / 1ps
module pr_D_X(
    input clk, reset,stall,flush,
    //control signals
    input [1:0]regDst,
    input jump,branch,memRead,memWrite,memtoReg, alu_src,memUnsigned,
    input regWrite,link,jumpReg,
    input [1:0]memSize,
    input [3:0]alu_op,
    input [5:0]opcode,
    input [5:0]funct,
    input [4:0]shamt,
    input [15:0]immediate,
    //datapath signals
    input [31:0]PC_plus_4,data1,data2,signExtImm,instruction,
    input [4:0]reg1,reg2,reg3, 
    

    output reg [4:0]shamt_out,
    output reg [15:0]immediate_out,
    output reg [5:0]funct_out,
    output reg [5:0]opcode_out,
    output reg [1:0]regDst_out,
    output reg regWrite_out,link_out,jumpReg_out,
    output reg jump_out,branch_out,memRead_out,memWrite_out,memtoReg_out,alu_src_out,memUnsigned_out,
    output reg [1:0]memSize_out,
    output reg [3:0]alu_op_out,
    output reg [31:0]PC_plus_4_out,data1_out,data2_out,signExtImm_out,instruction_out,
    output reg [4:0]reg1_out,reg2_out,reg3_out
);
always@(posedge clk)begin
    if(reset || stall || flush)begin
        //default will be zero for all signals(nop in case of stall)
        shamt_out<=0;
        immediate_out<=0;
        opcode_out<=0;
        funct_out<=0;
        link_out<=0;
        jumpReg_out<=0;
        regWrite_out<=0;
        regDst_out<=0;
        jump_out<=0;
        branch_out<=0;
        memRead_out<=0;
        memWrite_out<=0;
        memtoReg_out<=0;
        alu_src_out<=0;
        alu_op_out<=0;
        memSize_out<=0;
        memUnsigned_out<=0;

        PC_plus_4_out<=0;
        data1_out<=0;
        data2_out<=0;
        signExtImm_out<=0;
        reg1_out<=0;
        reg2_out<=0;
        reg3_out<=0;
        instruction_out<=0;
    end
    else begin
        reg1_out<=reg1;
        instruction_out<=instruction;
        shamt_out<=shamt;
        immediate_out<=immediate;
        opcode_out<=opcode;
        funct_out<=funct;
        link_out<=link;
        jumpReg_out<=jumpReg;
        regWrite_out<=regWrite;
        regDst_out<=regDst;
        jump_out<=jump;
        branch_out<=branch;
        memRead_out<=memRead;
        memWrite_out<=memWrite;
        memtoReg_out<=memtoReg;
        alu_src_out<=alu_src;
        alu_op_out<=alu_op;
        memSize_out<=memSize;
        memUnsigned_out<=memUnsigned;

        PC_plus_4_out<=PC_plus_4;
        data1_out<=data1;
        data2_out<=data2;
        signExtImm_out<=signExtImm;
        reg2_out<=reg2;
        reg3_out<=reg3;
    end
end
endmodule