`timescale 1ns / 1ps
module mips_pipelined_processor(
    input clk,
    input reset
    );

//====================
//F stage
//====================
reg  [31:0] PC_F;
wire [31:0] instruction_F;
reg [31:0] PC_plus_4_F;

//====================
//IF/ID
//====================
wire [31:0] instruction_D;
wire [31:0] PC_plus_4_D;

//====================
//D stage
//====================
reg [5:0]  opcode_D, funct_D; 
reg [4:0]  reg3_D, shamt_D;
reg [4:0]  reg1_D, reg2_D;
reg [15:0] immediate_D;
reg [31:0] signExtImm_D;
wire [31:0] data1_D, data2_D;

// control from control unit
wire [1:0]  regDst_D;
wire        jump_D, branch_D, memRead_D, memWrite_D, memtoReg_D;
wire        alu_src_D, regWrite_D, jumpReg_D, link_D;
wire [1:0]  memSize_D;
wire        memUnsigned_D;
wire [3:0]  alu_op_D;

//====================
//X stage
//====================
wire [5:0]  opcode_X, funct_X;
wire [15:0] immediate_X;
wire [31:0] PC_plus_4_X;
wire [31:0] data1_X, data2_X, signExtImm_X;
wire [4:0]  reg1_X,reg2_X, reg3_X, shamt_X;

wire [1:0]  regDst_X;
wire        jump_X, branch_X, memRead_X, memWrite_X, memtoReg_X;
wire        alu_src_X, regWrite_X, jumpReg_X, link_X;
wire [1:0]  memSize_X;
wire        memUnsigned_X;
wire [3:0]  alu_op_X;
reg  [31:0] a, b;
wire [31:0] y;
wire zero, overflow, sign;
wire [3:0]  alu_control_X;
wire [31:0] instruction_X;
reg  [4:0]  write_reg_X;
reg [31:0] BTA;
reg [31:0] JTA;
reg  [31:0] PC_temp, nextPC,result_X;
reg  PCsrc;

reg [1:0]forward_A,forward_B;
reg[31:0]b_temp;
reg stall,flush;
//====================
//M stage
//====================
wire [31:0] result_M, data2_M;
wire [4:0]  write_reg_M;
wire  regWrite_M, memRead_M, memWrite_M, memtoReg_M, memUnsigned_M;
wire [1:0]  memSize_M;
wire [31:0] read_data_dmem;
reg [31:0] read_data_M;
reg [31:0] write_data_dmem;

//====================
// W stage
//====================
wire [31:0] result_W, read_data_W;
wire [4:0]  write_reg_W;
wire regWrite_W, memtoReg_W;
reg [31:0] write_data_regfile;

//instantiations
pr_F_D IF_ID(.clk(clk), .reset(reset),.stall(stall),.flush(flush), .PC_plus_4(PC_plus_4_F), .instruction(instruction_F), 
             .PC_plus_4_out(PC_plus_4_D), .instruction_out(instruction_D));
pr_D_X ID_EX(.clk(clk), .reset(reset),.stall(stall),.flush(flush), .regDst(regDst_D), .jump(jump_D), .branch(branch_D), 
             .memRead(memRead_D), .memWrite(memWrite_D), .memtoReg(memtoReg_D), .alu_src(alu_src_D), 
             .memUnsigned(memUnsigned_D), .regWrite(regWrite_D), .memSize(memSize_D), .alu_op(alu_op_D), .funct(funct_D),.link(link_D),.opcode(opcode_D),.PC_plus_4_out(PC_plus_4_X),
             .PC_plus_4(PC_plus_4_D), .data1(data1_D), .data2(data2_D), .signExtImm(signExtImm_D), 
             .reg1(reg1_D),.reg2(reg2_D), .reg3(reg3_D),.shamt(shamt_D),.immediate(immediate_D),.instruction(instruction_D),.jumpReg(jumpReg_D),
             .regDst_out(regDst_X),.link_out(link_X),.jump_out(jump_X),.branch_out(branch_X),.memRead_out(memRead_X),.memWrite_out(memWrite_X),.alu_src_out(alu_src_X),.memUnsigned_out(memUnsigned_X),.memSize_out(memSize_X),
             .regWrite_out(regWrite_X), .memtoReg_out(memtoReg_X), .data1_out(data1_X), .data2_out(data2_X), .alu_op_out(alu_op_X),.funct_out(funct_X),.opcode_out(opcode_X),
             .signExtImm_out(signExtImm_X), .reg1_out(reg1_X),.reg2_out(reg2_X), .reg3_out(reg3_X),.shamt_out(shamt_X),.immediate_out(immediate_X),.instruction_out(instruction_X),.jumpReg_out(jumpReg_X));
pr_X_M EX_MEM(.clk(clk), .reset(reset), .regWrite(regWrite_X), .memRead(memRead_X), .memWrite(memWrite_X), 
             .memtoReg(memtoReg_X), .memSize(memSize_X), .memUnsigned(memUnsigned_X), 
             .write_reg(write_reg_X), .result(result_X), .data2(b_temp),
             .regWrite_out(regWrite_M), .memtoReg_out(memtoReg_M), .write_reg_out(write_reg_M), 
             .result_out(result_M), .data2_out(data2_M),.memRead_out(memRead_M), .memWrite_out(memWrite_M),.memSize_out(memSize_M),.memUnsigned_out(memUnsigned_M));
pr_M_W MEM_WB(.clk(clk), .reset(reset), .regWrite(regWrite_M), .memtoReg(memtoReg_M), 
             .write_reg(write_reg_M), .read_data(read_data_dmem), .result(result_M),
             .regWrite_out(regWrite_W), .memtoReg_out(memtoReg_W), .write_reg_out(write_reg_W), 
             .read_data_out(read_data_W), .result_out(result_W));

imemory imem_inst(.PC(PC_F), .instruction(instruction_F));
dmemory dmem_inst(.clk(clk), .address(result_M), .write_data(data2_M), .memRead(memRead_M), .memWrite(memWrite_M), .read_data(read_data_dmem), .memSize(memSize_M), .memUnsigned(memUnsigned_M));
regfile regfile_inst(.clk(clk), .reg1(reg1_D), .reg2(reg2_D), .regWrite(regWrite_W), .write_reg(write_reg_W), .write_data(write_data_regfile), .data1(data1_D), .data2(data2_D));
control_unit control_unit_inst(.instruction(instruction_D), .regDst(regDst_D), .jump(jump_D), .branch(branch_D), .memRead(memRead_D), 
                             .memWrite(memWrite_D), .memtoReg(memtoReg_D), .alu_src(alu_src_D), .regWrite(regWrite_D), .jumpReg(jumpReg_D), 
                             .link(link_D), .alu_op(alu_op_D), .memSize(memSize_D), .memUnsigned(memUnsigned_D));
alu_control alu_conrol_inst(.funct(funct_X), .alu_control(alu_control_X), .alu_op(alu_op_X));
alu alu_inst(.a(a), .b(b), .alu_control(alu_control_X), .shamt(shamt_X), .immediate(immediate_X), .y(y), .zero(zero), .overflow(overflow), .sign(sign));


// everything combinational 
always @* begin
//F stage
    PC_plus_4_F=PC_F+4;

//D stage
    opcode_D=instruction_D[31:26];
    immediate_D=instruction_D[15:0];
    reg1_D=instruction_D[25:21];
    reg2_D=instruction_D[20:16];
    reg3_D = instruction_D[15:11];
    write_data_regfile= memtoReg_W? read_data_W : result_W;   //from the mem : alu result
    shamt_D=instruction_D[10:6];
    funct_D=instruction_D[5:0];

    if(opcode_D == 6'hc || opcode_D == 6'hd || opcode_D == 6'he )    //zero sign extension for andi, ori, xori
        signExtImm_D = {16'b0, immediate_D};
    else 
        signExtImm_D={{16{immediate_D[15]}}, immediate_D};
//X stage
    //forwarding unit(control signals)
    if(regWrite_M==1 && write_reg_M==reg1_X && write_reg_M!=0)   //(write_reg is destn register, output of mux in X stage)
        forward_A=2'b01; //from M stage(write data in register file)
    else if(regWrite_W==1 && write_reg_W==reg1_X && write_reg_W!=0)
        forward_A=2'b10; //from W stage(same)
    else
        forward_A=2'b00;  //default data1_X


    if(regWrite_M==1 && write_reg_M==reg2_X && write_reg_M!=0)
        forward_B=2'b01; //from M stage
    else if(regWrite_W==1 && write_reg_W==reg2_X && write_reg_W!=0)
        forward_B=2'b10; //from W stage
    else
        forward_B=2'b00;  //default data2_X

    //nextPC logic
    BTA = (signExtImm_X << 2) + PC_plus_4_X;
    JTA = {PC_plus_4_X[31:28], instruction_X[25:0], 2'b00};
    PCsrc = 1'b0;
    if(opcode_X==6'h4) PCsrc=zero&branch_X;    //beq
    else if(opcode_X==6'h5) PCsrc=!zero&branch_X; //bne
    PC_temp = PCsrc ? BTA : PC_plus_4_F;
    nextPC =jumpReg_X ? a : (jump_X ? JTA : PC_temp);

    result_X = (link_X)?PC_plus_4_X:y; //pass either the PC+4 value(jal to be written in register file) or y value
    case(regDst_X)
        2'b00:   write_reg_X = reg2_X;   //I(rt)
        2'b01:   write_reg_X = reg3_X;    //R(rd)
        2'b10:   write_reg_X = 5'd31;  //jal($ra)
        default: write_reg_X = 5'd0;    //no writing
    endcase
    //forwarding
    case(forward_A)
        2'b00: a=data1_X;
        2'b01: a=result_M; //memstage
        2'b10: a=write_data_regfile;       //mux output after W stage
        default: a = data1_X;
    endcase
    case(forward_B)
        2'b00: b_temp=data2_X;
        2'b01: b_temp=result_M;
        2'b10: b_temp=write_data_regfile;
        default: b_temp = data2_X;
    endcase
    b = alu_src_X?signExtImm_X : b_temp;
    
    //Hazard detection unit(lw->use type)
    if(memRead_X==1 &&((write_reg_X == reg1_D) || (write_reg_X == reg2_D)) && write_reg_X != 0) 
        stall=1;  //handle after effects now using this stall signal(PC--hold,pr_F_D--hold,pr_D_X--nop insertion)
    else stall=0;

    //control hazards (deterministic branch/j/jr)-- flush F/D and D/X pr, PC=nextPC
    flush = PCsrc || jump_X || jumpReg_X;  
//M stage
    //nothing


//W stage
    // already done in D stage
        
end

//PC update
always @(posedge clk) begin
    if(!stall || flush)begin  //update only when stall=0, same as single condition(!stall)
        if(reset) 
            PC_F <= 32'b0;
        else 
            PC_F <= nextPC;
    end
end

endmodule
