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

module tb_task5();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 100,000 ticks (equivalent to "initial #100000 $finish();").

    // Inputs
    logic CLOCK_50;
    logic [3:0] KEY;

    // Outputs
    logic [9:0] LEDR;
    logic [6:0] HEX5;
    logic [6:0] HEX4;
    logic [6:0] HEX3;
    logic [6:0] HEX2;
    logic [6:0] HEX1;
    logic [6:0] HEX0;

    // Helpers
    logic fast_clock;
    logic slow_clock;
    logic resetb;
    logic [3:0] pscore;
    logic [3:0] dscore;
    logic player_win_light;
    logic dealer_win_light;

    assign fast_clock = CLOCK_50;
    assign resetb = KEY[3];
    assign slow_clock = KEY[0];
    assign pscore = LEDR[3:0];
    assign dscore = LEDR[7:4];
    assign player_win_light = LEDR[8];
    assign dealer_win_light = LEDR[9];

    logic error_flag;
    integer error_count;

    task5 dut(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .LEDR(LEDR),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

    // Flips through the cards to deal
    task fast_clock_cycle();
        CLOCK_50 = 1;
        #1;
        CLOCK_50 = 0;
        #1;
    endtask

    // Cycle through states
    task slow_clock_cycle();
        KEY[0] = 1;
        #1;
        KEY[0] = 0;
        #1;
    endtask

    task reset();
        KEY[3] = 0; // Active-low reset
        slow_clock_cycle(); // Synchronous reset
        fast_clock_cycle(); // Synchronous reset
        #1;
        KEY[3] = 1;
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

    task check_led(input [9:0] LED, input [9:0] expected_LED);
        #1;
        if (LED == expected_LED) begin
            $display("LEDR test passed: got %b", LED);
        end else begin
            error_flag = 1;
            error_count++;
            $error("LEDR test failed: expected %b, got %b", expected_LED, LED);
            #1;
            error_flag = 0;
        end
    endtask

    initial begin
        // Initialize
        error_flag = 0;
        error_count = 0;

        reset();

        // Testing reset
        $display("Testing reset-------------------");
        check_hex(HEX0, `HEX_BLANK);
        check_hex(HEX1, `HEX_BLANK);
        check_hex(HEX2, `HEX_BLANK);
        check_hex(HEX3, `HEX_BLANK);
        check_hex(HEX4, `HEX_BLANK);
        check_hex(HEX5, `HEX_BLANK);
        check_led(LEDR, 10'b0000000000);

        reset();

        // Testing PC1 state
        $display("Testing PC1 state-------------------");
        // Cycle to state after PC1 to load card into register
        slow_clock_cycle();
        check_hex(HEX0, `HEX_A); // Check first player card is Ace
        check_led({dealer_win_light, player_win_light, dscore, pscore}, {1'b0, 1'b0, 4'b0000, 4'b0001}); // Check player score is 1

        reset();

        // Testing DC1 state
        $display("Testing DC1 state-------------------");
        // Get to DC1 state and load player card 1 (Ace)
        slow_clock_cycle();
        // Deal 4 card
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        // Cycle to state after DC1 to load card into register
        slow_clock_cycle();
        check_hex(HEX3, `HEX_4); // Check first dealer card is 4
        check_led({dealer_win_light, player_win_light, dscore, pscore}, {1'b0, 1'b0, 4'b0100, 4'b0001}); // Check dealer score is 4 and player score is 1

        reset();

        // Testing PC2 state
        $display("Testing PC2 state-------------------");
        // Get to PC2 state and load player card 1 (Ace) and dealer card 1 (Ace)
        slow_clock_cycle();
        slow_clock_cycle();
        // Deal 8 card
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        // Cycle to state after PC2 to load card into register
        slow_clock_cycle();
        check_hex(HEX1, `HEX_8); // Check second player card is 8
        check_led({dealer_win_light, player_win_light, dscore, pscore}, {1'b0, 1'b0, 4'b0001, 4'b1001}); // Check dealer score is 1 and player score is 9

        reset();
        
        // Testing DC2 state
        $display("Testing DC2 state-------------------");
        // Get to DC2 state and load player card 1 (Ace), dealer card 1 (Ace), player card 2 (Ace)
        slow_clock_cycle();
        slow_clock_cycle();
        slow_clock_cycle();
        // Deal King card
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
        fast_clock_cycle();
        fast_clock_cycle();
        // Cycle to state after DC2 to load card into register
        slow_clock_cycle();
        check_hex(HEX4, `HEX_K); // Check second dealer card is King
        check_led({dealer_win_light, player_win_light, dscore, pscore}, {1'b0, 1'b0, 4'b0001, 4'b0010}); // Check dealer score is 1 and player score is 2

        reset();

        // Testing PC3 state
        $display("Testing PC3 state-------------------");
        // Get to PC3 state and load player card 1 (Ace), dealer card 1 (Ace), player card 2 (Ace), dealer card 2 (Ace)
        slow_clock_cycle();
        slow_clock_cycle();
        slow_clock_cycle();
        slow_clock_cycle();
        // Deal 10 card
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        // Cycle to state after PC3 to load card into register
        slow_clock_cycle();
        check_hex(HEX2, `HEX_10); // Check third player card is 10
        check_led({dealer_win_light, player_win_light, dscore, pscore}, {1'b0, 1'b0, 4'b0010, 4'b0010}); // Check dealer score is 2 and player score is 2

        reset();

        // Testing DC3 state
        $display("Testing DC3 state-------------------");
        // Get to DC3 state and load player card 1 (Ace), dealer card 1 (Ace), player card 2 (Ace), dealer card 2 (Ace), player card 3 (Ace)
        slow_clock_cycle();
        slow_clock_cycle();
        slow_clock_cycle();
        slow_clock_cycle();
        slow_clock_cycle();
        // Cycle to state after DC3 to load card into register
        slow_clock_cycle();
        check_hex(HEX5, `HEX_A); // Check third dealer card is Ace
        check_led({dealer_win_light, player_win_light, dscore, pscore}, {1'b1, 1'b1, 4'b0011, 4'b0011}); // Check dealer_win_light and player_win_light is on, dealer score is 3 and player score is 3

        reset();

        // Testing player win
        $display("Testing player win-------------------");
        // Get to PC2 state and load player card 1 (Ace), dealer card 1 (Ace)
        slow_clock_cycle();
        slow_clock_cycle();
        // Deal 8 card to player card 2
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        // Go to DC2 state
        slow_clock_cycle();
        // Deal Jack card to dealer card 2
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        // Cycle to declareWinner state
        slow_clock_cycle();
        check_led({dealer_win_light, player_win_light, dscore, pscore}, {1'b0, 1'b1, 4'b0001, 4'b1001}); // Check player_win_light is on, dealer score is 1 and player score is 9

        reset();

        // Testing dealer win
        $display("Testing dealer win-------------------");
        // Get to DC1 state and load player card 1 (Ace)
        slow_clock_cycle();
        // Deal 8 card to dealer card 1
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        fast_clock_cycle();
        // Get to PC2 state and load dealer card 1 (8)
        slow_clock_cycle();
        // Deal 9 card to player card 2
        fast_clock_cycle();
        // Get to DC2 state and load player card 2 (9)
        slow_clock_cycle();
        // Deal 10 card to dealer card 2
        fast_clock_cycle();
        // Cycle to declareWinner state and load dealer card 2 (10)
        slow_clock_cycle();
        check_led({dealer_win_light, player_win_light, dscore, pscore}, {1'b1, 1'b0, 4'b1000, 4'b0000}); // Check dealer_win_light is on, dealer score is 8 and player score is 0

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
