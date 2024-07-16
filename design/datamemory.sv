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

  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Wr(Wr)
  );

  always_ff @(*) begin
    raddress = {{22{1'b0}}, a[8:2], {2{1'b0}}};
    waddress = {{22{1'b0}}, a[8:2], {2{1'b0}}};
    Datain = wd;
    Wr = 4'b0000;

    if (MemRead) begin
      case (Funct3)
        3'b000: //LB 8bit
        rd <= a[1:0] == 2'b00 ? {Dataout[7] ? 24'hFFFFFFF : 24'b0, Dataout[7:0]} : a[1:0] == 2'b01 ? {Dataout[15] ? 24'hFFFFFFF : 24'b0, Dataout[15:8]} : a[1:0] == 2'b10 ? {Dataout[24] ? 24'hFFFFFFF : 24'b0, Dataout[23:16]} : {Dataout[31] ? 24'hFFFFFFF : 24'b0, Dataout[31:24]};
        3'b001: //LH 16bit
        rd <= a[1:0] == 2'b00 ? {Dataout[15] ? 16'hFFFFFFF : 16'b0, Dataout[15:0]} : a[1:0] == 2'b01 ? {Dataout[15] ? 16'hFFFFFFF : 16'b0, Dataout[15:0]} : a[1:0] == 2'b10 ? {Dataout[24] ? 16'hFFFFFFF : 16'b0, Dataout[31:16]} : {Dataout[31] ? 16'hFFFFFFF : 16'b0, Dataout[31:16]};
        3'b010:  //LW 32bit
        rd <= Dataout;
        3'b100:  //LBU
        rd <= a[1:0] == 2'b00 ? {24'b0, Dataout[7:0]} : a[1:0] == 2'b01 ? {24'b0, Dataout[15:8]} : a[1:0] == 2'b10 ? {24'b0, Dataout[23:16]} : {24'b0, Dataout[31:24]};
        default: rd <= Dataout;
      endcase
    end else if (MemWrite) begin
      case (Funct3)
        3'b010: begin  //SW
          Wr <= 4'b1111;
          Datain <= wd;
        end
        default: begin
          Wr <= 4'b1111;
          Datain <= wd;
        end
      endcase
    end
  end

endmodule
