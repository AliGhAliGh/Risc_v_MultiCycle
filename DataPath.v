module DataPath(PcEn, AdrSrc, MemWrite, IrWrite, RegWrite, Immsrc, AluSrcA, AluSrcB, AluOp, ResultSrc, Zero, rst, clk);
    input PcEn, AdrSrc, MemWrite, RegWrite, IrWrite, rst, clk;
    input[1:0] AluSrcA, AluSrcB, ResultSrc;
    input[2:0] Immsrc, AluOp;
    output Zero;
    wire[31:0] PcOut, MemAdr, MemOut, Inst, OldPcOut, Rd1, Rd2, ImmOut, RegA, RegB, AluInA, AluInB, AluOut, AluOutRegOut, MdrRegOut, ResultOut;


    Mux2 AdrSrcMux(PcOut, ResultOut, AdrSrc, MemAdr);
    Mux4 AluSrcMuxA(PcOut, OldPcOut, RegA, 32'b0, AluSrcA, AluInA);
    Mux4 AluSrcMuxA(RegB, ImmOut, {29'b0, 3'b100}, 32'b0, AluSrcB, AluInB);
    Mux4 ResultSrcMux(AluOutRegOut, MdrRegOut, AluOut, 32'b0, ResultSrc, ResultOut);
    Alu alu(.op(AluOp),.a(AluInA),.b(AluInB),.out(AluOut),.zero(Zero));
    RegMem regmem(.clk(clk),.rst(rst),we(RegWrite),.a1(Inst[19:15]),.a2(Inst[24:20]),.a3(Inst[11:7]),.wd(ResultOut),.rd1(Rd1),.rd2(Rd2));
    Reg A(.clk(clk),.rst(rst),.inp(Rd1),.out(RegA));
    Reg A(.clk(clk),.rst(rst),.inp(Rd2),.out(RegB));
    Reg AluOutReg(.clk(clk),.rst(rst),.inp(AluOut),.out(AluOutRegOut));
    Reg MDR(.clk(clk),.rst(rst),.inp(MemOut),.out(MdrRegOut));
    Reg OldPc(.clk(clk),.rst(rst),.inp(PcOut),.out(OldPcOut));
    Reg IR(.clk(clk),.rst(rst),.inp(MemOut),.out(Inst));
    Mem mem(.clk(clk),.rst(rst),.a(MemAdr),.we(MemWrite),.wd(Rd2),.out(MemOut));
    PC pc(.en(PcEn),.inp(ResultOut),.out(PcOut),.rst(rst),.clk(clk));
    ImmExtend immEx(.op(Immsrc),.inp(Inst),.out(ImmOut));
endmodule