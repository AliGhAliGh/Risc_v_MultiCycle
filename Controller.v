module Controller(Zero, SignBit, Op, F3, F7, PcEn, AdrSrc, MemWrite, IrWrite, RegWrite, Immsrc, AluSrcA, AluSrcB, AluIn, ResultSrc, RDS, clk, rst);
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
    parameter InstructionFetch = 4'b0;
    parameter InstructionDecode = 4'b0001;
    parameter EXECUTION_R = 4'b0010;
    parameter EXECUTION_L = 4'b0011;
    parameter EXECUTION_S = 4'b0100;
    parameter EXECUTION_I = 4'b0101;
    parameter EXECUTION_J = 4'b0110;
    parameter EXECUTION_B = 4'b0111;
    parameter MEMORY_ACCESS_L = 4'b1000;
    parameter MEMORY_ACCESS_S = 4'b1001;
    parameter WRITE_BACK_R = 4'b1010;
    parameter WRITE_BACK_L = 4'b1011;
    parameter WRITE_BACK_I = 4'b1100;
    parameter WRITE_BACK_J = 4'b1101;
    parameter WRITE_BACK_U = 4'b1110;
    parameter BUG = 4'b1111;
    input Zero, SignBit, clk, rst;
    input[6:0] Op,F7;
    input[2:0] F3;
    output reg AdrSrc, MemWrite, IrWrite, RegWrite;
    output PcEn;
    output reg[2:0] Immsrc;
    output[2:0] AluIn;
    output reg[1:0] ResultSrc, AluSrcA, AluSrcB, RDS;
    reg[2:0] AluOp;
    reg[3:0] ns, ps;
    reg PcUpdate;
    wire IsIType, IsJalr, IsSlt, IsSltI;
    assign IsSlt = Op == R_TYPE_OP & F3 == SLT_3 & F7 == SLT_7;
    assign IsSltI = (Op == I_TYPE_ARITHMATIC_OP & F3 == SLT_I_3);
    assign IsJalr = Op == JALR_OP;
    assign IsIType = Op == LW_OP | Op == I_TYPE_ARITHMATIC_OP | IsJalr;
    always @(posedge clk, posedge rst) begin
        if(rst)
            ps <= InstructionFetch;
        else
            ps <= ns;
    end
    always @(ps, Op, IsJalr) begin
        ns = BUG;
        case (ps)
            BUG: ns = BUG;
            InstructionFetch: ns <= InstructionDecode;
            InstructionDecode: ns <= Op == R_TYPE_OP ? EXECUTION_R : 
                                Op == LW_OP ? EXECUTION_L :
                                Op == SW_OP ? EXECUTION_S :
                                Op == I_TYPE_ARITHMATIC_OP ? EXECUTION_I :
                                Op == B_TYPE_OP ? EXECUTION_B :
                                Op == LU_I_OP ? WRITE_BACK_U :
                                Op == JAL_OP | IsJalr ? EXECUTION_J : BUG;
            EXECUTION_B: ns <= InstructionFetch;
            EXECUTION_R: ns <= WRITE_BACK_R;
            EXECUTION_I: ns <= WRITE_BACK_I;
            EXECUTION_J: ns <= WRITE_BACK_J;
            EXECUTION_L: ns <= MEMORY_ACCESS_L;
            EXECUTION_S: ns <= MEMORY_ACCESS_S;
            WRITE_BACK_R: ns <= InstructionFetch;
            WRITE_BACK_I: ns <= InstructionFetch;
            WRITE_BACK_J: ns <= InstructionFetch;
            WRITE_BACK_L: ns <= InstructionFetch;
            WRITE_BACK_U: ns <= InstructionFetch;
            MEMORY_ACCESS_L: ns <= WRITE_BACK_L;
            MEMORY_ACCESS_S: ns <= InstructionFetch;
        endcase
    end
    always @(ps, Op, IsIType, F3, IsJalr, IsSltI, IsSlt) begin
        {AdrSrc, MemWrite, IrWrite, RegWrite, RDS, AluOp, Immsrc, ResultSrc, AluSrcA, AluSrcB, PcUpdate} = 18'b0;
        case (ps)
        InstructionFetch: begin
            IrWrite <= 1'b1;
            AluSrcB <= 2'b10;
            ResultSrc <= 2'b10;
            PcUpdate <= 1'b1;
        end
        InstructionDecode: begin
            AluSrcA <= 2'b01;
            AluSrcB <= 2'b01;
            Immsrc <= 3'b010;
        end
        EXECUTION_R: begin
            AluSrcA = 2'b10;
            AluOp = 3'b010;
        end
        EXECUTION_L: begin
            AluSrcA = 2'b10;
            AluSrcB = 2'b01;
        end
        EXECUTION_S: begin
            AluSrcA = 2'b10;
            AluSrcB = 2'b01;
            Immsrc = 3'b001;
        end
        EXECUTION_I: begin
            AluSrcA = 2'b10;
            AluSrcB = 2'b01;
        end
        EXECUTION_B: begin
            AluSrcA = 2'b10;
            AluOp = 3'b001;
        end
        EXECUTION_J: begin
            AluSrcA = 2'b01;
            AluSrcB = 2'b10;
        end
        WRITE_BACK_R: begin
            RegWrite = 1'b1;
            ResultSrc = IsSlt ? 2'b11 : 2'b0;
        end
        WRITE_BACK_I: begin
            RegWrite = 1'b1;
            ResultSrc = IsSltI ? 2'b11 : 2'b0;
        end
        WRITE_BACK_U: begin
            Immsrc = 3'b100;
            RegWrite = 1'b1;
            RDS = 2'b01;
        end
        WRITE_BACK_L: begin
            RegWrite = 1'b1;
            ResultSrc = 2'b01;
        end
        WRITE_BACK_J: begin
            AluSrcA = IsJalr ? 2'b10 : 2'b01;
            PcUpdate = 1'b1;
            RDS = 2'b10;
            AluSrcB = 2'b01;
            RegWrite = 1'b1;
            ResultSrc = 2'b10;
            Immsrc = IsJalr ? 3'b0 : 3'b011;
        end
        MEMORY_ACCESS_L: begin
            AdrSrc = 1'b1;
        end
        MEMORY_ACCESS_S: begin
            MemWrite = 1'b1;
            AdrSrc = 1'b1;
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
            AluOp == 3'b100 ? ((F3 == XOR_I_3) ? XOR : (F3 == OR_I_3) ? OR :
            (F3 == ADD_I_3) ? ADD : (F3 == SLT_I_3) ? SUB : 3'b111) : 3'b111;
endmodule
