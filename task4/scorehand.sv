module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);

// The code describing scorehand will go here.  Remember this is a combinational
// block. The function is described in the handout. Be sure to review Verilog
// notes on bitwidth mismatches and signed/unsigned numbers.

logic [4:0] value; // 5 bits since max value to handle carry bit from addition before the modulus
assign value = card1 + card2 + card3;
assign total = value % 10;

endmodule

