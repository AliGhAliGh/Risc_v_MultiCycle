module CA3(rst, clk);
    input rst, clk;
    wire Zero, SignBit, PcEn, AdrSrc, MemWrite, IrWrite, RegWrite;
    wire[6:0] Op, F7;
    wire[2:0] F3, Immsrc, AluIn;
    wire[1:0] ResultSrc, AluSrcA, AluSrcB, RDS;
    Controller C(.Zero(Zero),.SignBit(SignBit),.Op(Op),.F3(F3),.F7(F7),.PcEn(PcEn),
                .AdrSrc(AdrSrc),.MemWrite(MemWrite),.IrWrite(IrWrite),.RegWrite(RegWrite),
                .Immsrc(Immsrc),.AluSrcA(AluSrcA),.AluSrcB(AluSrcB),.AluIn(AluIn),
                .ResultSrc(ResultSrc),.RDS(RDS),.clk(clk),.rst(rst));
    DataPath DP(.Zero(Zero),.SignBit(SignBit),.Op(Op),.F3(F3),.F7(F7),.PcEn(PcEn),
                .AdrSrc(AdrSrc),.MemWrite(MemWrite),.IrWrite(IrWrite),.RegWrite(RegWrite),
                .Immsrc(Immsrc),.AluSrcA(AluSrcA),.AluSrcB(AluSrcB),.ResultSrc(ResultSrc),
                .RDS(RDS),.clk(clk),.rst(rst),.AluOp(AluIn));
endmodule