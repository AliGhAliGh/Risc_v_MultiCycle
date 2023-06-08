module TB3();
    reg clk=0, rst=0;
    CA3 ca(.clk(clk),.rst(rst));
    always
        #2 clk = ~clk;
    initial begin
        #1 rst = 1;
        #4 rst = 0;
        #10000 $stop;
    end
endmodule