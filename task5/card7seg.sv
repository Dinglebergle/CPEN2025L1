`define HEX_BLANK 7'b1111111
`define HEX_A     7'b0001000
`define HEX_2     7'b0100100
`define HEX_3     7'b0110000
`define HEX_4     7'b0011001
`define HEX_5     7'b0010010
`define HEX_6     7'b0000010
`define HEX_7     7'b1111000
`define HEX_8     7'b0000000
`define HEX_9     7'b0010000
`define HEX_10    7'b1000000 
`define HEX_J     7'b1100001
`define HEX_Q     7'b0011000
`define HEX_K     7'b0001001

module card7seg(input logic [3:0] SW, output logic [6:0] HEX0);
		
   // your code goes here
	always_comb begin
		case(SW)
			4'b0: HEX0 = `HEX_BLANK;
			4'b0001: HEX0 = `HEX_A;
			4'b0010: HEX0 = `HEX_2;
			4'b0011: HEX0 = `HEX_3;
			4'b0100: HEX0 = `HEX_4;
			4'b0101: HEX0 = `HEX_5;
			4'b0110: HEX0 = `HEX_6;
			4'b0111: HEX0 = `HEX_7;
			4'b1000: HEX0 = `HEX_8;
			4'b1001: HEX0 = `HEX_9;
			4'b1010: HEX0 = `HEX_10;
			4'b1011: HEX0 = `HEX_J;
			4'b1100: HEX0 = `HEX_Q;
			4'b1101: HEX0 = `HEX_K;
			default: HEX0 = `HEX_BLANK;
		endcase
	end
	
endmodule

