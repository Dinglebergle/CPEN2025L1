// States
`define PC1 3'b000
`define DC1 3'b001
`define PC2 3'b010
`define DC2 3'b011
`define PC3 3'b100
`define DC3 3'b101
`define declareWinner 3'b110

module tb_statemachine();

// Inputs
logic slow_clock;
logic resetb;   
logic [3:0] dscore;
logic [3:0] pscore;
logic [3:0] pcard3;

// Outputs
logic load_pcard1;
logic load_pcard2;
logic load_pcard3;
logic load_dcard1;
logic load_dcard2;
logic load_dcard3;
logic player_win_light;
logic dealer_win_light;

// Helpers
logic error_flag;
integer error_count;

statemachine dut (
    .slow_clock(slow_clock),
    .resetb(resetb),
    .dscore(dscore),
    .pscore(pscore),
    .pcard3(pcard3),
    .load_pcard1(load_pcard1),
    .load_pcard2(load_pcard2),
    .load_pcard3(load_pcard3),
    .load_dcard1(load_dcard1),
    .load_dcard2(load_dcard2),
    .load_dcard3(load_dcard3),
    .player_win_light(player_win_light),
    .dealer_win_light(dealer_win_light)
);

//goes through 1 clock cycle
task clk_tick;
    begin
        slow_clock = 0;
        #1;
        slow_clock = 1;
        #1;
    end
endtask

//checks if a value matches an expected value, and prints the result with a string input to identify what is being checked
task check_val(
    input string val_type,
    input expected,
    input actual
);
        if (expected == actual) begin
            $display("%s value correct: %d", val_type, actual);
        end 
        
        else begin
            $error("%s mismatch: expected %d, got %d", val_type, expected, actual);
            error_flag =1'bx;
            error_count++;
        end
endtask

//automates checking every output and the state of the statemachine
task check_statemachine(
    input [2:0] expected_state,
    input expected_load_pcard1,
    input expected_load_pcard2,
    input expected_load_pcard3,
    input expected_load_dcard1,
    input expected_load_dcard2,
    input expected_load_dcard3,
    input expected_player_win_light,
    input expected_dealer_win_light
);
        check_val("State", expected_state, dut.state);
        check_val("load_pcard1", expected_load_pcard1, load_pcard1);
        check_val("load_pcard2", expected_load_pcard2, load_pcard2);
        check_val("load_pcard3", expected_load_pcard3, load_pcard3);
        check_val("load_dcard1", expected_load_dcard1, load_dcard1);
        check_val("load_dcard2", expected_load_dcard2, load_dcard2);
        check_val("load_dcard3", expected_load_dcard3, load_dcard3);
        check_val("player_win_light", expected_player_win_light, player_win_light);
        check_val("dealer_win_light", expected_dealer_win_light, dealer_win_light);
endtask

task reset_test();
    begin
        resetb = 0;
        error_flag = 0;
        clk_tick();
    end
endtask

initial begin
    // Initialize inputs
    slow_clock = 0;
    resetb = 1;   
    dscore = 0;
    pscore = 0;
    pcard3 = 0;
    error_flag = 0;
    error_count = 0;

    // Reset the state machine
    resetb = 0;
    clk_tick();


    // Testing PC1 state
    $display("Testing PC1 state-------------------");
    resetb = 1;
    check_statemachine(`PC1, 1, 0, 0, 0, 0, 0, 0, 0); //should be in PC1 state

    reset_test();

    // Testing DC1 state
    $display("Testing DC1 state-------------------");
    resetb = 1;
    clk_tick();
    check_statemachine(`DC1, 0, 0, 0, 1, 0, 0, 0, 0); //should be in DC1 state

    reset_test();

    // Testing PC2 state
    $display("Testing PC2 state-------------------");
    resetb = 1;
    clk_tick();
    clk_tick();
    check_statemachine(`PC2, 0, 1, 0, 0, 0, 0, 0, 0); //should be in PC2 state

    reset_test();

    // Testing DC2 state
    $display("Testing DC2 state-------------------");
    resetb = 1;
    clk_tick();
    clk_tick();
    clk_tick();
    check_statemachine(`DC2, 0, 0, 0, 0, 1, 0, 0, 0); //should be in DC2 state

    reset_test();

    // Testing statemachine with player natural win
    $display("Testing statemachine with player natural win-------------------");
    resetb = 1;
    pscore = 8;
    dscore = 5;
    clk_tick();
    clk_tick();
    clk_tick();
    clk_tick();
    check_statemachine(`declareWinner, 0, 0, 0, 0, 0, 0, 1, 0); //player win light should be on
    clk_tick();
    check_statemachine(`declareWinner, 0, 0, 0, 0, 0, 0, 1, 0); //should stay in declare winner state
    
    reset_test();
    
    //Testing statemachine with dealer natural win
    $display("Testing statemachine with dealer natural win-------------------");
    resetb = 1;
    pscore = 5;
    dscore = 8;
    clk_tick();
    clk_tick();
    clk_tick();
    clk_tick();
    check_statemachine(`declareWinner, 0, 0, 0, 0, 0, 0, 0, 1); //dealer win light should be on
    clk_tick();
    check_statemachine(`declareWinner, 0, 0, 0, 0, 0, 0, 0, 1); //should stay in declare winner state

    reset_test();

    //Testing statemachine with cards: P 1, 2, 3| D 3, 4 (Player should get 3 cards, Dealer stays with 2, Dealer wins)
    $display("Testing statemachine with cards: P 1, 2, 3 | D 3, 4--------------");
    resetb = 1;
    pscore = 3;
    dscore = 7;
    pcard3 = 0;
    clk_tick();
    clk_tick();
    clk_tick();
    clk_tick();
    check_statemachine(`PC3, 0, 0, 1, 0, 0, 0, 0, 0); //should be in PC3 state
    pscore = 6; //player gets 3rd card, total score now 6
    clk_tick();
    clk_tick();
    check_statemachine(`declareWinner, 0, 0, 0, 0, 0, 0, 0, 1); //Dealer win

    reset_test();

    //Testing statemachine with cards: P 3, 1, 6 | D 2, 4, 8 (Dealer should get 3 cards, Player gets 3 cards, Dealer wins)
    $display("Testing statemachine with cards: P 3, 1, 6 | D 2, 4, 8--------------");
    resetb = 1;
    pscore = 4;
    dscore = 6;
    pcard3 = 0;
    clk_tick();
    clk_tick();
    clk_tick();
    clk_tick();
    check_statemachine(`PC3, 0, 0, 1, 0, 0, 0, 0, 0); //should be in PC3 state
    pscore = 0; //player gets 3rd card, total score now 0
    pcard3 = 6; //pcard3 is 6
    clk_tick();
    check_statemachine(`DC3, 0, 0, 0, 0, 0, 1, 0, 0); //should be in DC3 state
    clk_tick();
    dscore = 4; //dealer gets 3rd card, total score now 4
    check_statemachine(`declareWinner, 0, 0, 0, 0, 0, 0, 0, 1); //Dealer win

    reset_test();

    //Testing statemachine with cards: P 5, 2 | D 1, 4, 1 (Dealer should get 3 cards, Player stays with 2, player wins)
    $display("Testing statemachine with cards: P 5, 2 | D 1, 4, 1--------------");
    resetb = 1;
    pscore = 7;
    dscore = 5;
    pcard3 = 0;
    clk_tick();
    clk_tick();
    clk_tick();
    clk_tick();
    check_statemachine(`DC3, 0, 0, 0, 0, 0, 1, 0, 0); //DC3 state
    dscore = 6; //dealer gets 3rd card, total score now 6
    clk_tick();
    check_statemachine(`declareWinner, 0, 0, 0, 0, 0, 0, 1, 0); //Player win

    reset_test();
    

    //Testing statemachine with tie game: P 3, 4, 3 | D 2, 5, 3 (Dealer should get 3 cards, Player gets 3 cards, Tie)
    $display("Testing statemachine with tie game: P 1, 4, 6 | D 1, 5, 5--------------");
    resetb = 1;
    pscore = 5;
    dscore = 6;
    pcard3 = 0;
    clk_tick();
    clk_tick();
    clk_tick();
    clk_tick();
    check_statemachine(`PC3, 0, 0, 1, 0, 0, 0, 0, 0); //should be in PC3 state
    pscore = 1; //player gets 3rd card, total score now 8
    pcard3 = 6; //pcard3 is 3
    clk_tick();
    check_statemachine(`DC3, 0, 0, 0, 0, 0, 1, 0, 0); //should be in DC3 state
    dscore = 1; //dealer gets 3rd card, total score now 8
    clk_tick();
    check_statemachine(`declareWinner, 0, 0, 0, 0, 0, 0, 1, 1); //Tie

    reset_test();

    //End of testing
    $display("\n\nTEST SUMMARY");
    if (error_count == 0) begin
        $display("All tests passed!");
    end else begin
        $display("%d errors detected during testing.", error_count);
    end
    $stop;
end

endmodule
