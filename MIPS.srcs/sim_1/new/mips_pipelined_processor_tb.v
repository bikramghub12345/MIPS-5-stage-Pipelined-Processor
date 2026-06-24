`timescale 1ns / 1ps
module mips_pipelined_processor_tb();

reg clk;
reg reset;

mips_pipelined_processor uut(.clk(clk), .reset(reset));

// 10ns clock period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// safety timeout
initial begin
    #1500;
    $display("Simulation timed out!");
    $finish;
end

// for monitoring on tcl console
// initial begin
//     #12;
//     forever begin
//         @(posedge clk);
//         $display("t=%0t PC_F=%0d instr_D=%h instr_X=%h stall=%b flush=%b fwdA=%b fwdB=%b result_M=%h wreg_W=%0d",
//             $time, uut.PC_F, uut.instruction_D, uut.instruction_X,
//             uut.stall, uut.flush, uut.forward_A, uut.forward_B,
//             uut.result_M, uut.write_reg_W);
//     end
// end

initial begin
    reset = 1;

    // GROUP 1: Empty pipeline / basic R-type & I-type
    uut.imem_inst.imem[0]  = 32'h20080005; // addi $t0, $zero, 5
    uut.imem_inst.imem[1]  = 32'h20090003; // addi $t1, $zero, 3
    uut.imem_inst.imem[2]  = 32'h00000000; // nop
    uut.imem_inst.imem[3]  = 32'h00000000; // nop
    uut.imem_inst.imem[4]  = 32'h00000000; // nop
    uut.imem_inst.imem[5]  = 32'h01095020; // add  $t2, $t0, $t1   -> 8
    uut.imem_inst.imem[6]  = 32'h01095822; // sub  $t3, $t0, $t1   -> 2
    uut.imem_inst.imem[7]  = 32'h01096024; // and  $t4, $t0, $t1   -> 1
    uut.imem_inst.imem[8]  = 32'h01096825; // or   $t5, $t0, $t1   -> 7
    uut.imem_inst.imem[9]  = 32'h01097026; // xor  $t6, $t0, $t1   -> 6
    uut.imem_inst.imem[10] = 32'h0109802A; // slt  $s0, $t0, $t1   -> 0 (5<3 false)
    uut.imem_inst.imem[11] = 32'h00000000; // nop
    uut.imem_inst.imem[12] = 32'h00000000; // nop
    uut.imem_inst.imem[13] = 32'h00000000; // nop

    // GROUP 2: Forwarding (M->X and W->X, both operands)
    uut.imem_inst.imem[14] = 32'h20040064; // addi $a0, $zero, 100
    uut.imem_inst.imem[15] = 32'h00841020; // add  $v0, $a0, $a0   -> 200 (M->X fwd both operands)
    uut.imem_inst.imem[16] = 32'h00501020; // add  $v0, $v0, $s0   -> 200 (W->X fwd, $s0=0)
    uut.imem_inst.imem[17] = 32'h00000000; // nop
    uut.imem_inst.imem[18] = 32'h00000000; // nop

    // GROUP 3: Load-use hazard + sw/lw forwarding
    uut.imem_inst.imem[19] = 32'h2003004D; // addi $v1, $zero, 77
    uut.imem_inst.imem[20] = 32'hAC030000; // sw   $v1, 0($zero) (data2 must be forwarded)
    uut.imem_inst.imem[21] = 32'h00000000; // nop
    uut.imem_inst.imem[22] = 32'h00000000; // nop
    uut.imem_inst.imem[23] = 32'h00000000; // nop
    uut.imem_inst.imem[24] = 32'h8C0D0000; // lw   $t5, 0($zero)    -> 77
    uut.imem_inst.imem[25] = 32'h01A07020; // add  $t6, $t5, $zero  -> needs stall, -> 77

    // GROUP 4: Immediate ops (andi, ori, xori, slti, lui)
    uut.imem_inst.imem[26] = 32'h00000000; // nop
    uut.imem_inst.imem[27] = 32'h31110001; // andi $s1, $t0, 1     -> 1   ($t0=5)
    uut.imem_inst.imem[28] = 32'h35120008; // ori  $s2, $t0, 8     -> 13
    uut.imem_inst.imem[29] = 32'h39130007; // xori $s3, $t0, 7     -> 2
    uut.imem_inst.imem[30] = 32'h2914000A; // slti $s4, $t0, 10    -> 1
    uut.imem_inst.imem[31] = 32'h3C151234; // lui  $s5, 0x1234     -> 0x12340000
    uut.imem_inst.imem[32] = 32'h00000000; // nop
    uut.imem_inst.imem[33] = 32'h00000000; // nop
    uut.imem_inst.imem[34] = 32'h00000000; // nop

    // GROUP 5: Shifts
    uut.imem_inst.imem[35] = 32'h0008B100; // sll $s6, $t0, 4      -> 80
    uut.imem_inst.imem[36] = 32'h00000000; // nop
    uut.imem_inst.imem[37] = 32'h00000000; // nop
    uut.imem_inst.imem[38] = 32'h00000000; // nop
    uut.imem_inst.imem[39] = 32'h0016B882; // srl $s7, $s6, 2      -> 20

    // GROUP 6: Branch taken (beq) and not-taken (bne)
    uut.imem_inst.imem[40] = 32'h00000000; // nop (drain)
    uut.imem_inst.imem[41] = 32'h00000000; // nop
    uut.imem_inst.imem[42] = 32'h00000000; // nop
    // $t0=5, $t1=3 still hold from group 1
    uut.imem_inst.imem[43] = 32'h11090002; // beq $t0,$t1,+2  -> NOT taken (5!=3)
    uut.imem_inst.imem[44] = 32'h2018002A; // addi $t8, $zero, 0x2A -> executed (42)
    uut.imem_inst.imem[45] = 32'h00000000; // nop
    uut.imem_inst.imem[46] = 32'h00000000; // nop
    uut.imem_inst.imem[47] = 32'h00000000; // nop
    uut.imem_inst.imem[48] = 32'h15090002; // bne $t0,$t1,+2  -> taken (5!=3), skip 49,50
    uut.imem_inst.imem[49] = 32'h201900AA; // addi $t9,$zero,0xAA  (SKIPPED)
    uut.imem_inst.imem[50] = 32'h201900BB; // addi $t9,$zero,0xBB  (SKIPPED)
    uut.imem_inst.imem[51] = 32'h201A00CC; // addi $k0,$zero,0xCC  -> executed (target)

    // GROUP 7: jal / jr subroutine call+return
    uut.imem_inst.imem[52] = 32'h00000000; // nop
    uut.imem_inst.imem[53] = 32'h00000000; // nop
    uut.imem_inst.imem[54] = 32'h00000000; // nop
    uut.imem_inst.imem[55] = 32'h0C00003C; // jal 60               -> $ra = PC+4 = 56*4=224
    uut.imem_inst.imem[56] = 32'h341B0AAA; // ori $k1,$zero,0xAAA  (executes AFTER return)
    uut.imem_inst.imem[57] = 32'h08000040; // j 64 -> infinite loop (self)
    uut.imem_inst.imem[58] = 32'h00000000; // nop (delay/filler)
    uut.imem_inst.imem[59] = 32'h00000000; // nop
    //subroutine at word 60
    uut.imem_inst.imem[60] = 32'h2010002A; // addi $s0, $zero, 42  -> $s0=42 (overwritten from grp1's slt result, fine)
    uut.imem_inst.imem[61] = 32'h00000000; // nop
    uut.imem_inst.imem[62] = 32'h00000000; // nop
    uut.imem_inst.imem[63] = 32'h03E00008; // jr $ra               -> back to word 56

    // word 64: final infinite loop target for the j above
    uut.imem_inst.imem[64] = 32'h08000040; // j 64 -> infinite loop (self)

    #12;
    reset = 0;
    #800;

    //checks
    $display("=================================================");
    $display("GROUP 1 - Basic ALU/R-type:");
    $display("  t0=%0d t1=%0d t2=%0d t3=%0d t4=%0d t5=%0d t6=%0d s0=%0d",
        $signed(uut.regfile_inst.registers[8]),
        $signed(uut.regfile_inst.registers[9]),
        $signed(uut.regfile_inst.registers[10]),
        $signed(uut.regfile_inst.registers[11]),
        $signed(uut.regfile_inst.registers[12]),
        $signed(uut.regfile_inst.registers[13]),
        $signed(uut.regfile_inst.registers[14]),
        $signed(uut.regfile_inst.registers[16]));
    $display("  expect t0=5 t1=3 t2=8 t3=2 t4=1 (t5/t6/s0 overwritten by later groups)");

    $display("GROUP 2 - Forwarding:");
    $display("  a0=%0d v0=%0d  (expect 100, 200)",
        uut.regfile_inst.registers[4], uut.regfile_inst.registers[2]);

    $display("GROUP 3 - Load-use stall + sw/lw forwarding:");
    $display("  t5=%0d t6=%0d  (expect 77, 77)",
        uut.regfile_inst.registers[13], uut.regfile_inst.registers[14]);

    $display("GROUP 4 - Immediate ops:");
    $display("  s1=%0d s2=%0d s3=%0d s4=%0d s5=%h",
        uut.regfile_inst.registers[17],
        uut.regfile_inst.registers[18],
        uut.regfile_inst.registers[19],
        uut.regfile_inst.registers[20],
        uut.regfile_inst.registers[21]);
    $display("  expect s1=1 s2=13 s3=2 s4=1 s5=12340000");

    $display("GROUP 5 - Shifts:");
    $display("  s6=%0d s7=%0d  (expect 80, 20)",
        uut.regfile_inst.registers[22], uut.regfile_inst.registers[23]);

    $display("GROUP 6 - Branches:");
    $display("  t8=%0h t9=%0h k0=%0h  (expect t8=2a, t9=0 (skipped), k0=cc)",
        uut.regfile_inst.registers[24],
        uut.regfile_inst.registers[25],
        uut.regfile_inst.registers[26]);

    $display("GROUP 7 - jal/jr:");
    $display("  s0=%0d ra=%0d k1=%h  (expect s0=42, ra=224, k1=aaa)",
        uut.regfile_inst.registers[16],
        uut.regfile_inst.registers[31],
        uut.regfile_inst.registers[27]);
    $display("=================================================");

    $finish;
end

endmodule