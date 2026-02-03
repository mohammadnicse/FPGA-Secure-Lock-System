`timescale 1ns / 1ps

module tb_secure_lock;

    // Inputs
    reg clk;
    reg rst;
    reg [3:0] entry;
    reg enter_btn;

    // Outputs
    wire unlock;
    wire alarm;

    // Instantiate the Unit Under Test (UUT)
    secure_lock uut (
        .clk(clk), 
        .rst(rst), 
        .entry(entry), 
        .enter_btn(enter_btn), 
        .unlock(unlock), 
        .alarm(alarm)
    );

    // Clock Generation
    always #5 clk = ~clk;

    // THIS IS THE RECORDER FOR THE WAVEFORM
    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
    end

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        entry = 0;
        enter_btn = 0;

        // Wait for global reset
        #10 rst = 0;

        // TEST CASE 1: Correct Password (1-2-3-4)
        $display("Test 1: Entering Correct Password...");
        
        #20 entry = 1; enter_btn = 1; #10 enter_btn = 0; // Press 1
        #20 entry = 2; enter_btn = 1; #10 enter_btn = 0; // Press 2
        #20 entry = 3; enter_btn = 1; #10 enter_btn = 0; // Press 3
        #20 entry = 4; enter_btn = 1; #10 enter_btn = 0; // Press 4
        
        #20;
        if (unlock) $display("SUCCESS: Door Unlocked!");
        else $display("FAIL: Door stayed locked.");

        // Reset for next test
        rst = 1; #20 rst = 0;

        // TEST CASE 2: Wrong Password (Brute Force Simulation)
        $display("Test 2: Simulating Brute Force Attack...");
        
        // We add delays (#20) here so the system has time to count the error
        #20 entry = 9; enter_btn = 1; #10 enter_btn = 0; 
        #20; 
        
        #20 entry = 8; enter_btn = 1; #10 enter_btn = 0; 
        #20; 

        #20 entry = 7; enter_btn = 1; #10 enter_btn = 0; 
        #20; 
        
        #20;
        if (alarm) $display("SUCCESS: Alarm Triggered!");
        else $display("FAIL: Alarm did not trigger.");

        $finish;
    end
endmodule