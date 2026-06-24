`timescale 1ns / 1ps
module control_unit(
    input [31:0]instruction,
//    input [5:0]opcode,
    output reg [1:0]regDst,
    output reg jump,branch,memRead,memWrite,memtoReg,alu_src,regWrite,jumpReg, //jumpReg is for 'jr', PC source from a register
    output reg link, //for 'jal', when link=1 --> write PC+4 into $ra
    output reg [3:0]alu_op,
    output reg [1:0]memSize, //00:byte, 01:half, 10:word
    output reg memUnsigned   //1 for lbu, lhu
    );
    
wire [5:0]opcode=instruction[31:26];
wire [5:0]funct=instruction[5:0]; //funct not needed
always@* begin
    regDst=2'b00;
    jump=0;
    branch=0;
    memRead=0;
    memWrite=0;
    memtoReg=0;
    alu_src=1;
    regWrite=0; //default 'rt'
    jumpReg=0; //take either the PC+4,BTA,JTA
    link=0;
    alu_op=4'b0000;  //default add for lw, sw, etc
    memSize=2'b10;   //default word
    memUnsigned=0;
    if(opcode==6'h2)jump=1;  // 'j'
    else if(opcode==6'h3) begin  //handle 'jal'
        jump = 1;
        link = 1;
        regWrite = 1;
        regDst = 2'b10;
        end
    else if(opcode==6'hf) begin  //for 'lui' handling;
        regWrite = 1;
        alu_op=4'b1000;
        regDst=2'b00;  //rt
        end
    else if(opcode==6'h0)begin    //R-type
            regDst=2'b01;
            alu_src=0;
            alu_op=4'b0010;
            regWrite=1;
            if(funct==6'h8)begin  //for 'jr'
                jumpReg=1; //now the next PC will be from a register
                regWrite=0;
                end
            end
    else begin     //I-type
        if(opcode==6'h4 || opcode==6'h5)begin  //beq,bne
            branch=1;alu_op=4'b0001;
            alu_src=0;
            end
        else if(opcode[5:3] == 3'b100) begin //Load instructions(0x20 to 0x25)
            memRead=1; memtoReg=1; regWrite=1;
            case(opcode[2:0])
                3'b000: begin memSize=2'b00; memUnsigned=0; end // lb (opcode=0x20) (sign extension)
                3'b001: begin memSize=2'b01; memUnsigned=0; end // lh (opcode=0x21) (sign extension)
                3'b011: begin memSize=2'b10; end                // lw (opcode=0x23) (no extension)
                3'b100: begin memSize=2'b00; memUnsigned=1; end // lbu (opcode=0x24) (zero extension)
                3'b101: begin memSize=2'b01; memUnsigned=1; end // lhu (opcode=0x25) (zero extension)
            endcase
        end
        else if(opcode[5:3] == 3'b101) begin //Store instructions(0x28 to 0x2B)
            memWrite=1;
            case(opcode[2:0])
                3'b000: memSize=2'b00; // sb (opcode=0x28)
                3'b001: memSize=2'b01; // sh (opcode=0x29)
                3'b011: memSize=2'b10; // sw (opcode=0x2B)
            endcase
        end
        else if(opcode==6'hc)begin 
            alu_op=4'b0011;  //andi
            regWrite=1;
            end
        else if(opcode==6'hd)begin
            alu_op=4'b0100;  //ori
            regWrite=1;
            end
        else if(opcode==6'h0e)begin
            alu_op=4'b0101;  //xori, what is the opcode
            regWrite=1;
            end
        else if(opcode==6'ha)begin
            alu_op=4'b0110;  //slti
            regWrite=1;
            end
        else if(opcode==6'hb)begin
            alu_op=4'b0111;  //sltiu
            regWrite=1;
            end
        else if(opcode==6'h8 || opcode==6'h9) begin  //addi,addiu
                regWrite = 1'b1;
                alu_op   = 4'b0000;
            end
    end
end
endmodule
