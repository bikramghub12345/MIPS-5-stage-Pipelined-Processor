`timescale 1ns / 1ps
module alu_control(
    input [3:0]alu_op,
    input [5:0]funct,
    output reg [3:0]alu_control
    );

always@* begin
case(alu_op)
    4'b0000:    alu_control=4'b0000;   //add for lw,sw
    4'b0001:    alu_control=4'b0001;   //sub beq, bne, etc
    4'b0010:begin   //for R type instructions
    case(funct)
        6'h20: alu_control=4'b0000; //add funct
        6'h21: alu_control=4'b0000; //addu funct
        6'h22: alu_control=4'b0001; //sub funct
        6'h23: alu_control=4'b0001; //subu funct
        6'h24: alu_control=4'b0010; //and funct
        6'h27: alu_control=4'b0101; //nor funct
        6'h25: alu_control=4'b0011; //or funct
        6'h26: alu_control = 4'b0100; //xor funct
        6'h2a: alu_control=4'b0110; //slt funct
        6'h2b: alu_control=4'b0111; //sltu funct
        6'h00: alu_control=4'b1000; //sll funct
        6'h02: alu_control=4'b1001; //srl funct
        6'h03: alu_control = 4'b1010; //sra funct
        default: alu_control = 4'b0000;
        
        endcase
        end
     4'b0011: alu_control = 4'b0010;  //andi 
     4'b0100: alu_control = 4'b0011;  //ori
     4'b0101: alu_control = 4'b0100;  //xori
     4'b0110: alu_control = 4'b0110;  //slti
     4'b0111: alu_control = 4'b0111;  //sltiu
     4'b1000: alu_control = 4'b1011;  //lui
     
    
     default: alu_control = 4'b0000; //add for addi, addiu
endcase
end       
endmodule
