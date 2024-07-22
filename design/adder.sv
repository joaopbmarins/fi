`timescale 1ns / 1ps

module adder #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    b,
    input logic halt,
    output logic [WIDTH-1:0] y
);

  assign y = halt ? a : a + b;

endmodule
