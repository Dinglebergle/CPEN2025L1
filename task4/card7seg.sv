// 7-segment display encoding macros to make case statements more readable, and to avoid mistakes in the bit encodings
`define HEX_BLANK 7'b1111111
`define HEX_A     7'b0001000
`define HEX_2     7'b0010010
`define HEX_3     7'b0000110
`define HEX_4     7'b1001100
`define HEX_5     7'b0100100
`define HEX_6     7'b0100000
`define HEX_7     7'b0001111
`define HEX_8     7'b0000000
`define HEX_9     7'b0000100
`define HEX_0     7'b1000000 
`define HEX_J     7'b1100000
`define HEX_Q     7'b1110001
`define HEX_K     7'b1111001



module card7seg(input logic [3:0] SW, output logic [6:0] HEX0);
		
   always_comb begin
      case (SW) //0 off, 1-13 being playing cards A,2, etc, 9, 0, j, q, k, and default to blank
         4'b0000: HEX0 = `HEX_BLANK; //blank
         4'b0001: HEX0 = `HEX_A; //A
         4'b0010: HEX0 = `HEX_2; //2
         4'b0011: HEX0 = `HEX_3; //3
         4'b0100: HEX0 = `HEX_4; //4
         4'b0101: HEX0 = `HEX_5; //5
         4'b0110: HEX0 = `HEX_6; //6
         4'b0111: HEX0 = `HEX_7; //7
         4'b1000: HEX0 = `HEX_8; //8
         4'b1001: HEX0 = `HEX_9; //9
         4'b1010: HEX0 = `HEX_0; //(1)0
         4'b1011: HEX0 = `HEX_J; //J
         4'b1100: HEX0 = `HEX_Q; //Q
         4'b1101: HEX0 = `HEX_K; //K
         default: HEX0 = `HEX_BLANK; //blank
      endcase
   end
	
endmodule

