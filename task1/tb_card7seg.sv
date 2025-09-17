// 7-segment display encoding macros to make case statements more readable, and to avoid mistakes in the bit encodings
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



module tb_card7seg();
    logic [3:0] SW;
    logic [6:0] HEX0;

    task  test_hex;
        input [3:0] sw_in;
        input [6:0] expected;
        begin
            SW = sw_in;

            #1;

            if (HEX0 == expected) begin
                $display("Test passed for input %b: got %b", sw_in, HEX0);
            end else begin
                $error("Test failed for input %b: expected %b, got %b", sw_in, expected, HEX0);
            end
            #1;
            SW = 4'b0000; // Reset to blank
            #1;
        end
    endtask 


    card7seg dut (.SW(SW), .HEX0(HEX0));

    initial begin
        // Test all possible inputs
        test_hex(4'b0000, `HEX_BLANK); // blank
        test_hex(4'b0001, `HEX_A);     // A
        test_hex(4'b0010, `HEX_2);     // 2
        test_hex(4'b0011, `HEX_3);     // 3
        test_hex(4'b0100, `HEX_4);     // 4
        test_hex(4'b0101, `HEX_5);     // 5
        test_hex(4'b0110, `HEX_6);     // 6
        test_hex(4'b0111, `HEX_7);     // 7
        test_hex(4'b1000, `HEX_8);     // 8
        test_hex(4'b1001, `HEX_9);     // 9
        test_hex(4'b1010, `HEX_10);     // 10
        test_hex(4'b1011, `HEX_J);     // J
        test_hex(4'b1100, `HEX_Q);     // Q
        test_hex(4'b1101, `HEX_K);     // K
        test_hex(4'b1110, `HEX_BLANK); // should default to blank
        test_hex(4'b1111, `HEX_BLANK); // should default to blank
        $stop;

    end



endmodule

