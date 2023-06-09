module DataPath(PcEn, AdrSrc, MemWrite, IrWrite, RegWrite, Immsrc, AluSrcA, AluSrcB, AluOp, ResultSrc, Zero, SignBit, rst, clk, RDS, Op, F3, F7);
    input PcEn, AdrSrc, MemWrite, RegWrite, IrWrite, rst, clk;
    input[1:0] AluSrcA, AluSrcB, ResultSrc, RDS;
    input[2:0] Immsrc, AluOp;
    output Zero, SignBit;
    output[6:0] F7, Op;
    output[2:0] F3;
    reg SignBitReg;
    wire SignBitOut;
    wire[31:0] PcOut, MemAdr, MemOut, Inst, OldPcOut, Rd1, Rd2, ImmOut, RegA, RegB, AluInA, AluInB, AluOut, AluOutRegOut, MdrRegOut, ResultOut, RegData;
    assign F3 = Inst[14:12];
    assign F7 = Inst[31:25];
    assign Op = Inst[6:0];
    assign SignBit = SignBitOut;
    Mux2 AdrSrcMux(PcOut, ResultOut, AdrSrc, MemAdr);
    Mux4 RegDataMux(ResultOut, ImmOut, AluOutRegOut, 32'b0, RDS, RegData);
    Mux4 AluSrcMuxA(PcOut, OldPcOut, RegA, 32'b0, AluSrcA, AluInA);
    Mux4 AluSrcMuxB(RegB, ImmOut, {29'b0, 3'b100}, 32'b0, AluSrcB, AluInB);
    Mux4 ResultSrcMux(AluOutRegOut, MdrRegOut, AluOut, {31'b0, SignBitReg}, ResultSrc, ResultOut);
    Alu alu(.Op(AluOp),.a(AluInA),.b(AluInB),.out(AluOut),.Zero(Zero),.SignBit(SignBitOut));
    RegMem regmem(.clk(clk),.rst(rst),.we(RegWrite),.a1(Inst[19:15]),.a2(Inst[24:20]),.a3(Inst[11:7]),.wd(RegData),.rd1(Rd1),.rd2(Rd2));
    Reg A(.clk(clk),.rst(rst),.inp(Rd1),.out(RegA));
    Reg B(.clk(clk),.rst(rst),.inp(Rd2),.out(RegB));
    always @(posedge rst, posedge clk) begin
        if(rst)
            SignBitReg <= 1'b0;
        else
            SignBitReg <= SignBitOut;
    end
    Reg AluOutReg(.clk(clk),.rst(rst),.inp(AluOut),.out(AluOutRegOut));
    Reg MDR(.clk(clk),.rst(rst),.inp(MemOut),.out(MdrRegOut));
    PC OldPc(.en(IrWrite),.clk(clk),.rst(rst),.inp(PcOut),.out(OldPcOut));
    PC IR(.en(IrWrite),.clk(clk),.rst(rst),.inp(MemOut),.out(Inst));
    Mem mem(.clk(clk),.rst(rst),.a(MemAdr),.we(MemWrite),.wd(Rd2),.out(MemOut));
    PC pc(.en(PcEn),.inp(ResultOut),.out(PcOut),.rst(rst),.clk(clk));
    ImmExtend immEx(.op(Immsrc),.inp(Inst),.out(ImmOut));
endmodule