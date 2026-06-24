`timescale 1ns / 1ps
module dmemory(
    input [31:0]address,write_data,
    input memWrite, memRead,clk,
    input [1:0] memSize,    // 00: byte, 01: half, 10: word
    input memUnsigned,      // 1 for unsigned
    output reg [31:0]read_data
    );
    
reg [31:0]dmem [0:255];
integer i;
initial begin
    for (i = 0; i < 256; i = i + 1) begin
        dmem[i] = 32'b0;
    end
end
wire [1:0] byte_offset = address[1:0];
wire [31:0] current_word = dmem[address>>2];

always @* begin
    if (memRead) begin
        case (memSize)
            2'b00: begin // Byte
                case (byte_offset)
                    2'b00: read_data=memUnsigned ?{24'b0, current_word[7:0]}:{{24{current_word[7]}}, current_word[7:0]};
                    2'b01: read_data=memUnsigned ?{24'b0, current_word[15:8]}:{{24{current_word[15]}}, current_word[15:8]};
                    2'b10: read_data=memUnsigned ?{24'b0, current_word[23:16]}:{{24{current_word[23]}}, current_word[23:16]};
                    2'b11: read_data=memUnsigned ?{24'b0, current_word[31:24]}:{{24{current_word[31]}}, current_word[31:24]};
                endcase
            end
            2'b01: begin // Half-word(assuming aligned)  word=<00>,01,<10>,11
                if (byte_offset[1] ==0)
                    read_data=memUnsigned ?{16'b0, current_word[15:0]}:{{16{current_word[15]}}, current_word[15:0]};
                else
                    read_data=memUnsigned ?{16'b0, current_word[31:16]}:{{16{current_word[31]}}, current_word[31:16]};
            end
            default: read_data=current_word; //word
        endcase
        end
    else read_data=32'b0;
end

always @(posedge clk) begin
    //write data
    if (memWrite) begin
        case (memSize)
            2'b00: begin // sb
                case (byte_offset)
                    2'b00: dmem[address>>2][7:0] <= write_data[7:0];
                    2'b01: dmem[address>>2][15:8] <= write_data[7:0];
                    2'b10: dmem[address>>2][23:16]<= write_data[7:0];
                    2'b11: dmem[address>>2][31:24]<= write_data[7:0];
                endcase
            end
            2'b01: begin //sh
                if (byte_offset[1] == 0)
                    dmem[address>>2][15:0]  <= write_data[15:0];
                else
                    dmem[address>>2][31:16] <= write_data[15:0];
            end
            default: dmem[address>>2] <= write_data; //sw
        endcase
    end
end
endmodule
