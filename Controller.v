module Controoler(Zero, PcEn, AdrSrc, MemWrite, IrWrite, RegWrite, Immsrc, AluSrcA, AluSrcB, AluOp, ResultSrc);
    input Zero;
    output PcEn, AdrSrc, MemWrite, IrWrite, RegWrite, AluOp;
    output[2:0] Immsrc, ResultSrc, AluSrcA, AluSrcB;
endmodule