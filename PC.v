module PC(en,inp,out,rst,clk);
    input rst,clk,en;
    input[31:0] inp;
    output reg[31:0] out;
    always @(posedge clk, posedge rst) begin
        if(rst)
            out = 32'b0;
        else if(en)
            out = inp;
    end
endmodule