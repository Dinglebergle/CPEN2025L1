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

module tb_datapath();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

    // Inputs
    logic slow_clock;
    logic fast_clock;
    logic resetb;
    logic load_pcard1;
    logic load_pcard2;
    logic load_pcard3;
    logic load_dcard1;
    logic load_dcard2;
    logic load_dcard3;

    // Outputs
    logic [3:0] pcard3_out;
    logic [3:0] pscore_out;
    logic [3:0] dscore_out;
    logic [6:0] HEX5;
    logic [6:0] HEX4;
    logic [6:0] HEX3;
    logic [6:0] HEX2;
    logic [6:0] HEX1;
    logic [6:0] HEX0;

    // Helpers
    logic error_flag;
    integer error_count;

    datapath dut(
    .slow_clock(slow_clock),
    .fast_clock(fast_clock),
    .resetb(resetb),
    .load_pcard1(load_pcard1),
    .load_pcard2(load_pcard2),
    .load_pcard3(load_pcard3),
    .load_dcard1(load_dcard1),
    .load_dcard2(load_dcard2),
    .load_dcard3(load_dcard3),
    .pcard3_out(pcard3_out),
    .pscore_out(pscore_out),
    .dscore_out(dscore_out),
    .HEX5(HEX5),
    .HEX4(HEX4),
    .HEX3(HEX3),
    .HEX2(HEX2),
    .HEX1(HEX1),
    .HEX0(HEX0)
    );

    // Flips through the cards to deal
    task fast_clock_cycle();
        fast_clock = 1;
        #1;
        fast_clock = 0;
        #1;
    endtask

    // Ensures card registers load synchronously
    task slow_clock_cycle();
        slow_clock = 1;
        #1;
        slow_clock = 0;
        #1;
    endtask

    task reset();
        resetb = 0; // Active-low reset
        slow_clock_cycle(); // Synchronous reset
        fast_clock_cycle(); // Synchronous reset
        #1;
        resetb = 1;
        #1;
    endtask

    task check_hex(input [6:0] HEX, input [6:0] expected_HEX);
        #1;
        if (HEX == expected_HEX) begin
            $display("HEX display test passed: got %b", HEX);
        end else begin
            error_flag = 1;
            error_count++;
            $error("HEX display test failed: expected %b, got %b", expected_HEX, HEX);
            #1;
            error_flag = 0;
        end
    endtask

    task check_score(input [3:0] score, input [3:0] expected_score);
        #1;
        if (score == expected_score) begin
            $display("Score test passed: got %d", score);
        end else begin
            error_flag = 1;
            error_count++;
            $error("Score test failed: expected %d, got %d", expected_score, score);
            #1;
            error_flag = 0;
        end
    endtask

    task check_player_card3(input [3:0] expected_value);
        #1;
        if (pcard3_out == expected_value) begin
            $display("Player card 3 value test passed: got %d", pcard3_out);
        end else begin
            error_flag = 1;
            error_count++;
            $error("Player card 3 value test failed: expected %d, got %d", expected_value, pcard3_out);
            #1;
            error_flag = 0;
        end
    endtask

    initial begin
        // Initialize
        error_flag = 0;
        error_count = 0;
        fast_clock = 0;
        slow_clock = 0;
        resetb = 1;
        load_pcard1 = 0;
        load_pcard2 = 0;
        load_pcard3 = 0;
        load_dcard1 = 0;
        load_dcard2 = 0;
        load_dcard3 = 0;

        reset();

        $display("Testing reset-------------------");
        check_hex(HEX0, `HEX_BLANK); // Check HEX0 shows blank
        check_hex(HEX1, `HEX_BLANK); // Check HEX1 shows blank
        check_hex(HEX2, `HEX_BLANK); // Check HEX2 shows blank
        check_hex(HEX3, `HEX_BLANK); // Check HEX3 shows blank
        check_hex(HEX4, `HEX_BLANK); // Check HEX4 shows blank
        check_hex(HEX5, `HEX_BLANK); // Check HEX5 shows blank
        check_score(pscore_out, 4'd0); // Check player score is 0
        check_score(dscore_out, 4'd0); // Check dealer score is 0
        check_player_card3(4'd0); // Check player card 3 value is 0

        reset();

        $display("Testing load card player turn 1-------------------");
        load_pcard1 = 1;
        slow_clock_cycle(); // Player dealt Ace card on turn 1
        load_pcard1 = 0;
        check_player_card3(4'd0); // Check player card 3 value is 0
        check_hex(HEX0, `HEX_A); // Check HEX0 shows Ace
        check_score(pscore_out, 4'd1); // Check player score is 1

        reset();
        
        $display("Testing load card dealer turn 1-------------------");
        fast_clock_cycle();
        fast_clock_cycle();
        load_dcard1 = 1;
        slow_clock_cycle(); // Dealer dealt 3 card on turn 1
        load_dcard1 = 0;
        check_player_card3(4'd0); // Check player card 3 value is 0
        check_hex(HEX3, `HEX_3); // Check HEX3 shows 3
        check_score(dscore_out, 4'd3); // Check dealer score is 3

        reset();

        $display("Testing load card player turn 2-------------------");
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        load_pcard2 = 1;
        slow_clock_cycle(); // Player dealt 5 card on turn 2
        load_pcard2 = 0;
        check_player_card3(4'd0); // Check player card 3 value is 0
        check_hex(HEX1, `HEX_5); // Check HEX1 shows 5
        check_score(pscore_out, 4'd5); // Check player score is 5

        reset();

        $display("Testing load card dealer turn 2-------------------");
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        load_dcard2 = 1;
        slow_clock_cycle(); // Dealer dealt 7 card on turn 2
        load_dcard2 = 0;
        check_player_card3(4'd0); // Check player card 3 value is 0
        check_hex(HEX4, `HEX_7); // Check HEX3 shows 7
        check_score(dscore_out, 4'd7); // Check dealer score is 7

        reset();

        $display("Testing load card player turn 3-------------------");
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        load_pcard3 = 1;
        slow_clock_cycle(); // Player dealt 9 card on turn 3
        load_pcard3 = 0;
        check_player_card3(4'd9); // Check player card 3 value is 9
        check_hex(HEX2, `HEX_9); // Check HEX2 shows 9
        check_score(pscore_out, 4'd9); // Check player score is 9

        reset();

        $display("Testing load card dealer turn 3-------------------");
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        load_dcard3 = 1;
        slow_clock_cycle(); // Dealer dealt Jack card on turn 3
        load_dcard3 = 0;
        check_player_card3(4'd0); // Check player card 3 value is 0
        check_hex(HEX5, `HEX_J); // Check HEX5 shows Jack
        check_score(dscore_out, 4'd0); // Check dealer score is 0

        reset();

        // End of testing
        $display("\n\nTEST SUMMARY");
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d errors detected during testing.", error_count);
        end
        $stop;
    end

endmodule