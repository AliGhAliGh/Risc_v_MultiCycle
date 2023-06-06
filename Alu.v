module Alu(Op, a, b, out , Zero, SignBit);
    input [2:0] Op;
    input [31:0] a, b;
    output reg [31:0] out;
    output Zero;
    assign Zero = (out == 32'b0);
    assign SignBit = out[31];
    always @(Op, a, b)begin
        out = 32'b0;
        case (Op)
            3'b000: out = a+b;
            3'b001: out = a-b;
            3'b010: out = a&b;
            3'b011: out = a|b;
            3'b100: out = a^b;
            // must change to their equal
        endcase
    end

endmodule