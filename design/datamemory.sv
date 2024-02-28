`timescale 1ns / 1ps

module datamemory #(
    parameter DM_ADDRESS = 9,
    parameter DATA_W = 32
) (
    input logic clk,
    input logic MemRead,  // comes from control unit
    input logic MemWrite,  // Comes from control unit
    input logic [DM_ADDRESS - 1:0] a,  // Read / Write address - 9 LSB bits of the ALU output
    input logic [DATA_W - 1:0] wd,  // Write Data
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction
    output logic [DATA_W - 1:0] rd  // Read Data
);

  logic [31:0] raddress;
  logic [31:0] waddress;
  logic [31:0] Datain;
  logic [31:0] Dataout;
  logic [ 3:0] Wr;
  logic [7:0] auxOutS0; // sinal auxiliar carga de byte
  logic [7:0] auxInS0; // sinal auxiliar armazenamento de byte
  logic [15:0] aux2Out; // sinal auxiliar carga half-word
  logic [15:0] aux2In; // sinal auxiliar armazenamento halfword

  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Dataout(Dataout),
      .auxOutS0(auxOutS0), // conexão
      .auxInS0(auxInS0), // conexão
      .aux2In(aux2In), // conexão
      .aux2Out(aux2Out), // conexão
      .Wr(Wr)
  );

  always_ff @(*) begin
    raddress = {{22{1'b0}}, a}; // ajustado
    waddress = {{22{1'b0}}, {a[8:2], {2{1'b0}}}}; // ajustado
    Datain = wd;
    Wr = 4'b0000;

    f (MemRead) begin
      case (Funct3)
        // leitura
        3'b010:  //LW
        rd <= $signed(Dataout);
        3'b000: //LB
        rd <= $signed(auxOutS0);
        3'b100: //LBU
        rd <= {24'b0, auxOutS0};
        3'b001:  //LH
        rd <= $signed(aux2Out);

        default: rd <= Dataout;
      endcase
    end else if (MemWrite) begin
      //escrita
      case (Funct3)
        3'b010: begin  //SW
          Wr <= 4'b1111;
          Datain <= $signed(wd);
        end
        3'b000: begin // SB
          Wr <= 4'b0100;
          auxInS0 <= $signed(wd);
        end
        3'b001: begin //SH
          Wr <= 4'b1100;
          aux2In <= $signed(wd);
        end

        default: begin
          Wr <= 4'b1111;
          Datain <= wd;
        end
      endcase
    end
  end

endmodule