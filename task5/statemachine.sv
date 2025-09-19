module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

// The code describing your state machine will go here.  Remember that
// a state machine consists of next state logic, output logic, and the 
// registers that hold the state.  You will want to review your notes from
// CPEN 211 or equivalent if you have forgotten how to write a state machine.

// Registers
logic [2:0] state, next_state;

// States
`define PC1 3'b000
`define DC1 3'b001
`define PC2 3'b010
`define DC2 3'b011
`define PC3 3'b100
`define DC3 3'b101
`define declareWinner 3'b110

// Set current state
always_ff @(posedge slow_clock) begin
    if(resetb == 0) begin //synchronous reset
        state <= `PC1;
        end
    else begin
        state <= next_state;
    end
end

// Determine next state
always_comb begin
    case (state) 

        `PC1: next_state = `DC1;
        `DC1: next_state = `PC2;
        `PC2: next_state = `DC2;
        `DC2: begin 
            // if dscore or pscore == 8 or 9, then we move to last state and declare winner
            if (dscore == 8 || dscore == 9 || pscore == 8 || pscore == 9) begin 
                next_state = `declareWinner;
            end
            //else if pscore is 0 (10, J, Q, K) - 5, we deal 3rd card to player
            else if (0 <= pscore && pscore <= 5 ) begin
                next_state = `PC3;
            end
            //else if pscore is 6 or 7, we check dscore to see if we deal 3rd card to dealer
            else if (pscore == 6 || pscore == 7) begin
                if (0 <= dscore && dscore <= 5) begin
                    next_state = `DC3;
                end
                else begin
                    next_state = `declareWinner;
                end
            end
            else begin //just in case we get an illegal value, we will declare winner as a default state for now
                next_state = `declareWinner;
            end
        end

        `PC3: begin //
            case(dscore)
                //if dscore is 6, pcard3 must be 6 or 7 to deal dealer 3rd card
                6: begin
                    if (6 <= pcard3 && pcard3 <= 7) begin
                        next_state = `DC3;
                    end
                    else begin
                        next_state = `declareWinner;
                    end
                end
                //if dscore is 5, pcard3 must be 4 - 7 to deal dealer 3rd card
                5: begin
                    if (4 <= pcard3 && pcard3 <= 7) begin
                        next_state = `DC3;
                    end
                    else begin
                        next_state = `declareWinner;
                    end
                end
                //if dscore is 4, pcard3 must be 2 - 7 to deal dealer 3rd card
                4: begin
                    if (2 <= pcard3 && pcard3 <= 7) begin
                        next_state = `DC3;
                    end
                    else begin
                        next_state = `declareWinner;
                    end
                end      
                //if dscore is 3, pcard3 must not be equal to 8 to deal dealer 3rd card
                3: begin
                    if (pcard3 != 8) begin
                        next_state = `DC3;
                    end
                    else begin
                        next_state = `declareWinner;
                    end
                end
                //else dealer gets 3rd card
                2: next_state = `DC3;
                1: next_state = `DC3;
                0: next_state =`DC3;
                default: next_state = `declareWinner; //if score is 7 then declare winner or in case we get an illegal value, we will declare winner as a default state for now
            endcase   
        end
        `DC3: next_state = `declareWinner;
        `declareWinner: next_state = `declareWinner; //after declaring winner, we reset to initial state
        default: next_state = `PC1; //just in case we get an illegal value, we will reset to initial state
    endcase
end


// Determine output
always_comb begin
    case (state)
        `PC1: begin
            load_pcard1 = 1;
            load_dcard1 = 0;
            load_pcard2 = 0;
            load_dcard2 = 0;
            load_pcard3 = 0;
            load_dcard3 = 0;
            player_win_light = 0;
            dealer_win_light = 0;
        end
        `DC1: begin
            load_pcard1 = 0;
            load_dcard1 = 1;
            load_pcard2 = 0;
            load_dcard2 = 0;
            load_pcard3 = 0;
            load_dcard3 = 0;
            player_win_light = 0;
            dealer_win_light = 0;
        end
        `PC2: begin
            load_pcard1 = 0;
            load_dcard1 = 0;
            load_pcard2 = 1;
            load_dcard2 = 0;
            load_pcard3 = 0;
            load_dcard3 = 0;
            player_win_light = 0;
            dealer_win_light = 0;
        end
        `DC2: begin
            load_pcard1 = 0;
            load_dcard1 = 0;
            load_pcard2 = 0;
            load_dcard2 = 1;
            load_pcard3 = 0;
            load_dcard3 = 0;
            player_win_light = 0;
            dealer_win_light = 0;
        end
        `PC3: begin
            load_pcard1 = 0;
            load_dcard1 = 0;
            load_pcard2 = 0;
            load_dcard2 = 0;
            load_pcard3 = 1;
            load_dcard3 = 0;
            player_win_light = 0;
            dealer_win_light = 0;
        end
        `DC3: begin
            load_pcard1 = 0;
            load_dcard1 = 0;
            load_pcard2 = 0;
            load_dcard2 = 0;
            load_pcard3 = 0;
            load_dcard3 = 1;
            player_win_light = 0;
            dealer_win_light = 0;
        end
        `declareWinner: begin
            load_pcard1 = 0;
            load_dcard1 = 0;
            load_pcard2 = 0;
            load_dcard2 = 0;
            load_pcard3 = 0;
            load_dcard3 = 0;
            if (pscore > dscore) begin
                player_win_light = 1;
                dealer_win_light = 0;
            end else if (pscore < dscore) begin
                player_win_light = 0;
                dealer_win_light = 1;
            end else begin
                player_win_light = 1;
                dealer_win_light = 1;
            end
        end
        default: begin
            load_pcard1 = 0;
            load_dcard1 = 0;
            load_pcard2 = 0;
            load_dcard2 = 0;
            load_pcard3 = 0;
            load_dcard3 = 0;
            player_win_light = 0;
            dealer_win_light = 0;
        end
    endcase
end

endmodule

