module tb_scorehand();
    logic [3:0] card1, card2, card3, total;
    logic error_flag;
    integer error_count;

    scorehand dut(
        .card1(card1),
        .card2(card2),
        .card3(card3),
        .total(total)
    );

    task check_score(input logic [3:0] val1, input logic [3:0] val2, input logic [3:0] val3, input logic [3:0] expected);
            card1 = val1;
            card2 = val2;
            card3 = val3;
            #1; // padding to make values not instantaneous, allowing for inspection of waveform.
            if (total == expected) begin
                $display("Test passed for inputs %d, %d, %d: got %d", val1, val2, val3, total);
            end else begin
                error_flag = 1;
                error_count++;
                $error("Test failed for inputs %d, %d, %d: expected %d, got %d", val1, val2, val3, expected, total);
                #1;
                error_flag = 0;
            end
            #1; //extra padding on waveform between values
    endtask


    initial begin
        error_flag = 0;
        error_count = 0;
        
        // Testing 2 card inputs
        $display("Testing 2 card inputs-------------------");
        check_score(4'd1, 4'd2, 4'd0, 4'd3); // mod10(1 + 2) = 3
        check_score(4'd5, 4'd3, 4'd0, 4'd8); // mod10(5 + 3) = 8

        // Testing inputs that add up to less than 10
        $display("Testing inputs add up to less than 10------------");
        check_score(4'd1, 4'd2, 4'd3, 4'd6); // mod10(1 + 2 + 3) = 6
        check_score(4'd1, 4'd1, 4'd7, 4'd9); // mod10(1 + 1 + 7) = 9
        check_score(4'd6, 4'd2, 4'd1, 4'd9); // mod10(6 + 2 + 1) = 9


        // Testing inputs that add up to 10 or more
        $display("Testing inputs add up to 10 or more-----------");
        check_score(4'd5, 4'd5, 4'd1, 4'd1); // mod10(5 + 5 + 1) = 1
        check_score(4'd9, 4'd2, 4'd3, 4'd4); // mod10(9 + 2 + 3) = 4
        check_score(4'd8, 4'd7, 4'd6, 4'd1); // mod10(8 + 7 + 6) = 1

        // Testing inputs greater or equal to 10
        $display("Testing inputs greater or equal to 10---------");
        check_score(4'd10, 4'd3, 4'd4, 4'd7); // mod10(0 + 3 + 4) = 7
        check_score(4'd11, 4'd12, 4'd13, 4'd0); // mod10(0 + 0 + 0) = 0
        check_score(4'd9, 4'd10, 4'd11, 4'd9); // mod10(9 + 0 + 0) = 9
        check_score(4'd2, 4'd8, 4'd10, 4'd0); // mod10(2 + 8 + 10) = 0

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
