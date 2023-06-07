module TB3();
    reg clk=0, rst=0;
    CA3 ca(.clk(clk),.rst(rst));
    always
        #10 clk = ~clk;
    initial begin
        rst = 1;
        #20 rst = 0;
        #10000 $stop;
    end
endmodule