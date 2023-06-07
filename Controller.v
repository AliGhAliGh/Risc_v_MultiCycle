module Controller(Zero, SignBit, Op, F3, F7, PcEn, AdrSrc, MemWrite, IrWrite, RegWrite, Immsrc, AluSrcA, AluSrcB, AluIn, ResultSrc, RegDataSel, clk, rst);
    parameter ADD_I_3 = 3'b0;
    parameter XOR_I_3 = 3'b100;
    parameter OR_I_3 = 3'b110;
    parameter SLT_I_3 = 3'b010;
    parameter LU_I_OP =7'b0110111;
    parameter B_TYPE_OP = 7'b1100011;
    parameter SW_OP =7'b0100011;
    parameter JALR_OP =7'b1100111;
    parameter R_TYPE_OP = 7'b0110011;
    parameter I_TYPE_ARITHMATIC_OP = 7'b0010011;
    parameter LW_OP = 7'b0000011;
    parameter JAL_OP =7'b1101111;
    parameter SLT_7 = 7'b0;
    parameter SLT_3 = 3'b010;
    parameter InstructionFetch = 3'b0;
    parameter InstructionDecode = 3'b001;
    parameter EXECUTION = 3'b010;
    parameter MEMORY_ACCESS = 3'b011;
    parameter WRITE_BACK = 3'b100;
    parameter BUG = 3'b101;
    input Zero, SignBit, clk, rst;
    input[6:0] Op,F7;
    input[2:0] F3;
    output reg AdrSrc, MemWrite, IrWrite, RegWrite, RegDataSel;
    output PcEn;
    output reg[2:0] Immsrc;
    output[2:0] AluIn;
    output reg[1:0] ResultSrc, AluSrcA, AluSrcB;
    reg[2:0] ns, ps, AluOp;
    reg PcUpdate;
    wire IsIType, IsJalr, IsSlt, IsSltI;
    assign IsSlt = Op == R_TYPE_OP & F3 == SLT_3 & F7 == SLT_7;
    assign IsSltI = (Op == I_TYPE_ARITHMATIC_OP & F3 == SLT_I_3);
    assign IsJalr = Op == JALR_OP;
    assign IsIType = Op == LW_OP | Op == I_TYPE_ARITHMATIC_OP | IsJalr;
    always @(posedge clk, posedge rst) begin
        if(rst)
            ps = InstructionFetch;
        ps = ns;
    end
    always @(ps, Op) begin
        ns = BUG;
        case (ps)
            BUG: ns = BUG;
            InstructionFetch: ns = InstructionDecode;
            InstructionDecode: ns = Op == LU_I_OP ? WRITE_BACK : EXECUTION;
            EXECUTION: ns = Op == R_TYPE_OP | Op == I_TYPE_ARITHMATIC_OP ? WRITE_BACK :
                        Op == LW_OP | Op == SW_OP ? MEMORY_ACCESS :
                        Op == B_TYPE_OP | Op == JAL_OP | IsJalr ? InstructionFetch : BUG;
            WRITE_BACK: ns = InstructionFetch;
            MEMORY_ACCESS: ns = Op == LW_OP ? WRITE_BACK : Op == SW_OP ? InstructionFetch : BUG;
        endcase
    end
    always @(ns) begin
        {AdrSrc, MemWrite, IrWrite, RegWrite, RegDataSel, AluOp, Immsrc, ResultSrc, AluSrcA, AluSrcB, PcUpdate} = 18'b0;
        case (ns)
        InstructionFetch: begin
            IrWrite = 1'b1;
            AluSrcB = 2'b10;
            ResultSrc = 2'b10;
            PcUpdate = 1;
        end
        InstructionDecode: begin
            AluSrcA = 2'b01;
            AluSrcB = Op == JAL_OP | IsJalr ? 2'b10 : 2'b01;
            Immsrc = Op == JAL_OP ? 3'b011 : IsIType ? 3'b0 : 3'b010;
        end
        EXECUTION: begin
            Immsrc = IsIType ? 3'b000 : Op == SW_OP ? 3'b001 : Op == B_TYPE_OP ? 3'b010 :
                    Op == JAL_OP ? 3'b011 : Op == LU_I_OP ? 3'b100 : 3'b101;
            AluSrcA = Op == R_TYPE_OP | IsIType | Op == SW_OP | Op == B_TYPE_OP ? 2'b10 : 2'b01;
            AluSrcB = Op == R_TYPE_OP | Op == B_TYPE_OP ? 2'b0 : 2'b01;  
            AluOp = Op == R_TYPE_OP ? 3'b010 : (Op == LW_OP | (Op == I_TYPE_ARITHMATIC_OP & F3 == ADD_I_3) | IsJalr | Op == SW_OP) ? 3'b000 : 
            (IsSltI | Op == B_TYPE_OP) ? 3'b001 : Op == I_TYPE_ARITHMATIC_OP ? 3'b100 : 3'b111;
            ResultSrc = IsJalr | Op == JAL_OP ? 2'b10 : 2'b0;
            RegWrite = IsJalr | Op == JAL_OP;
            PcUpdate = IsJalr | Op == JAL_OP;
            RegDataSel = 2'b01;
        end
        MEMORY_ACCESS: begin
            AdrSrc = 1'b1;
            MemWrite = Op == SW_OP;
        end
        WRITE_BACK: begin
            RegWrite = 1'b1;
            RegDataSel = Op == LU_I_OP ? 2'b10 : IsSlt | IsSltI ? 2'b11 : 2'b0;
            ResultSrc = Op == LW_OP ? 2'b01 : 2'b0;
        end
       endcase 
    end
    PcController PC(.PcUpdate(PcUpdate),.BrOp(F3),.Zero(Zero),.SignBit(SignBit),.PcEn(PcEn));
    AluController AC(.AluOp(AluOp),.F3(F3),.F7(F7),.AluIn(AluIn));
endmodule

module PcController(PcUpdate, BrOp, Zero, SignBit, PcEn);
    parameter BEQ_3 = 3'b0;
    parameter BNE_3 = 3'b001;
    parameter BGE_3 = 3'b101;
    parameter BLT_3 = 3'b100;
    input SignBit, Zero, PcUpdate;
    input[2:0] BrOp;
    output PcEn;
    assign PcEn = PcUpdate | (BrOp == BEQ_3 & Zero) | (BrOp == BNE_3 & ~Zero) | (BrOp == BLT_3 & SignBit) | (BrOp == BGE_3 & ~SignBit);
endmodule

module AluController (AluOp, F3, F7, AluIn);
    parameter ADD_3 = 3'b000;
    parameter SUB_3 = 3'b000;
    parameter AND_3 = 3'b111;
    parameter OR_3 = 3'b110;
    parameter SLT_3 = 3'b010;
    parameter ADD_7 = 7'b0;
    parameter SUB_7 = 7'b0100000;
    parameter AND_7 = 7'b0;
    parameter OR_7 = 7'b0;
    parameter SLT_7 = 7'b0;
    parameter ADD = 3'b000;
    parameter SUB = 3'b001;
    parameter AND = 3'b010;
    parameter OR = 3'b011;
    parameter XOR = 3'b100;
    parameter ADD_I_3 = 3'b0;
    parameter XOR_I_3 = 3'b100;
    parameter OR_I_3 = 3'b110;
    parameter SLT_I_3 = 3'b010;
    input[2:0] F3;
    input[6:0] F7;
    input[2:0] AluOp;
    output[2:0] AluIn;
    assign AluIn = AluOp == 3'b0 ? ADD : AluOp == 3'b001 ? SUB : AluOp == 3'b010 ?
            ((F3 == ADD_3 & F7 == ADD_7) ? ADD :
            (F3 == SUB_3 & F7 == SUB_7) ? SUB :
            (F3 == AND_3 & F7 == AND_7) ? AND :
            (F3 == OR_3 & F7 == OR_7) ? OR :
            (F3 == SLT_3 & F7 == SLT_7) ? SUB : 3'b111) :
            AluOp == 3'b100 ? ((F3 == XOR_I_3) ? XOR : (F3 == OR_I_3) ? OR : 3'b111) : 3'b111;
endmodule
