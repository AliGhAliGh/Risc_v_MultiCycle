module Reg(inp,out,rst,clk);
    input rst,clk;
    input[31:0] inp;
    output reg[31:0] out;
    always @(posedge clk, posedge rst) begin
        if(rst)
            out = 32'b0;
        else
            out = inp;
    end
endmodule