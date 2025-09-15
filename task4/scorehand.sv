module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);

// The code describing scorehand will go here.  Remember this is a combinational
// block. The function is described in the handout. Be sure to review Verilog
// notes on bitwidth mismatches and signed/unsigned numbers.
logic [3:0] card1_val, card2_val, card3_val;
always_comb begin
    // Convert face cards to 0
    if (card1 >= 4'b1010) begin
        card1_val = 4'b0000;
    end
    else begin
        card1_val = card1;
    end

    if (card2 >= 4'b1010) begin
        card2_val = 4'b0000;
    end
    else begin
        card2_val = card2;
    end

    if (card3 >= 4'b1010) begin
        card3_val = 4'b0000;
    end
    else begin
        card3_val = card3;
    end
end

logic [4:0] value; // 5 bits since max value to handle carry bit from addition before the modulus
assign value = card1_val + card2_val + card3_val;
assign total = value % 10;

endmodule

