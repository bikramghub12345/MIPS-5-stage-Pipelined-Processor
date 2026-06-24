`timescale 1ns / 1ps

module sub_tb();
reg [31:0] a,b;
wire [31:0] diff;
wire overflow;
wire borrow;

sub uut(.A(a),.B(b),.diff(diff),.overflow(overflow),.borrow(borrow));

initial begin
    // Zero cases
    a = 32'h00000000; b = 32'h00000000; #10;
    a = 32'h00000001; b = 32'h00000000; #10;
    a = 32'h00000000; b = 32'h00000001; #10;

    // Small numbers
    a = 32'd12;       b = 32'd5;        #10;
    a = 32'd100;      b = 32'd200;      #10;

    // Borrow generation
    a = 32'h00000000; b = 32'h00000001; #10;
    a = 32'h000000FF; b = 32'h00000100; #10;
    a = 32'h0000FFFF; b = 32'h00010000; #10;

    // Alternating patterns
    a = 32'hAAAAAAAA; b = 32'h55555555; #10;
    a = 32'h55555555; b = 32'hAAAAAAAA; #10;

    // Random-looking patterns
    a = 32'h12345678; b = 32'h87654321; #10;
    a = 32'hDEADBEEF; b = 32'hCAFEBABE; #10;

    // Boundary values
    a = 32'h7FFFFFFF; b = 32'h00000001; #10;
    a = 32'h80000000; b = 32'h00000001; #10;
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; #10;

    // Positive overflow
    // +2147483647 - (-1)
    a = 32'h7FFFFFFF; b = 32'hFFFFFFFF; #10;

    // +2147483647 - (-2147483648)
    a = 32'h7FFFFFFF; b = 32'h80000000; #10;

    // Negative overflow
    // -2147483648 - 1
    a = 32'h80000000; b = 32'h00000001; #10;

    // -2147483648 - 2147483647
    a = 32'h80000000; b = 32'h7FFFFFFF; #10;

    $finish;

end

endmodule