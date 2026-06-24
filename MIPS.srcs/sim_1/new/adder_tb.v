`timescale 1ns / 1ps
module adder_tb();
reg [31:0]a,b;
reg c;
wire Cout;
wire [31:0]sum;
wire overflow;

adder uut(.A(a),.B(b),.C(c),.Cout(Cout),.sum(sum),.overflow(overflow));
initial begin
    // Zero cases
    c=0;
    a = 32'h00000000; b = 32'h00000000; #10;
    a = 32'h00000000; b = 32'h00000001; #10;
    a = 32'h00000001; b = 32'h00000000; #10;

    // Small numbers
    a = 32'd5;         b = 32'd7;         #10;
    a = 32'd100;       b = 32'd200;       #10;

    // Carry generation
    a = 32'h0000000F;  b = 32'h00000001;  #10;
    a = 32'h000000FF;  b = 32'h00000001;  #10;
    a = 32'h0000FFFF;  b = 32'h00000001;  #10;
    a = 32'hFFFFFFFF;  b = 32'h00000001;  #10;

    // Alternating patterns
    a = 32'hAAAAAAAA;  b = 32'h55555555;  #10;
    a = 32'h55555555;  b = 32'hAAAAAAAA;  #10;

    // Random-looking patterns
    a = 32'h12345678;  b = 32'h87654321;  #10;
    a = 32'hDEADBEEF;  b = 32'hCAFEBABE;  #10;

    // MSB carry
    a = 32'h80000000;  b = 32'h80000000;  #10;

    // Maximum values
    a = 32'h7FFFFFFF;  b = 32'h00000001;  #10;
    a = 32'hFFFFFFFF;  b = 32'hFFFFFFFF;  #10;
    
    // Positive overflow
    a = 32'h7FFFFFFF; b = 32'h00000001; #10;
    a = 32'h7FFFFFFF; b = 32'h7FFFFFFF; #10;

    // Negative overflow
    a = 32'h80000000; b = 32'hFFFFFFFF; #10;
    a = 32'h80000000; b = 32'h80000000; #10;

    $finish;
    end
endmodule
