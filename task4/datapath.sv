module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);

// Card value registers
logic [3:0] new_card, pc1_value, pc2_value, pc3_value, dc1_value, dc2_value, dc3_value;

always_comb begin
    // Convert face cards to 0
    if (pc3_value >= 4'b1010) begin
        pcard3_out = 4'b0000;
    end
    else begin
        pcard3_out = pc3_value;
    end 
end

// The code describing your datapath will go here.  Your datapath 
// will hierarchically instantiate six card7seg blocks, two scorehand
// blocks, and a dealcard block.  The registers may either be instatiated
// or included as sequential always blocks directly in this file.
//
// Follow the block diagram in the Lab 1 handout closely as you write this code.

// Deal cards
dealcard dealCard (.clock(fast_clock), .resetb(resetb), .new_card(new_card));

// Card Registers
reg4 PCard1 (.d(new_card), .enable(load_pcard1), .clk(slow_clock), .reset(resetb), .q(pc1_value));
reg4 PCard2 (.d(new_card), .enable(load_pcard2), .clk(slow_clock), .reset(resetb), .q(pc2_value));
reg4 PCard3 (.d(new_card), .enable(load_pcard3), .clk(slow_clock), .reset(resetb), .q(pc3_value));
reg4 DCard1 (.d(new_card), .enable(load_dcard1), .clk(slow_clock), .reset(resetb), .q(dc1_value));
reg4 DCard2 (.d(new_card), .enable(load_dcard2), .clk(slow_clock), .reset(resetb), .q(dc2_value));
reg4 DCard3 (.d(new_card), .enable(load_dcard3), .clk(slow_clock), .reset(resetb), .q(dc3_value));

// Score Calculators
scorehand PScore_hand (.card1(pc1_value), .card2(pc2_value), .card3(pc3_value), .total(pscore_out));
scorehand DScore_hand (.card1(dc1_value), .card2(dc2_value), .card3(dc3_value), .total(dscore_out));

// 7-bit HEX displays for card values
card7seg PCard1_7seg (.SW(pc1_value), .HEX0(HEX0));
card7seg PCard2_7seg (.SW(pc2_value), .HEX0(HEX1));
card7seg PCard3_7seg (.SW(pc3_value), .HEX0(HEX2));
card7seg DCard1_7seg (.SW(dc1_value), .HEX0(HEX3));
card7seg DCard2_7seg (.SW(dc2_value), .HEX0(HEX4));
card7seg DCard3_7seg (.SW(dc3_value), .HEX0(HEX5));

endmodule

module reg4(input [3:0] d, input enable, input clk, input reset, output logic [3:0] q);
    always_ff @(posedge clk) begin
        if (!reset) begin
            q <= 4'b0000;
        end
        else if (enable) begin
            q <= d;
        end
        else begin
            q <= q;
        end
    end
endmodule