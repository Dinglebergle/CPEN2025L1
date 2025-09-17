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

    

    initial begin
        // Initialize
        error_flag = 0;
        error_count = 0;



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
