`timescale 1ns/1ps

module tb();
    // Common values for bit and address length
    parameter DATA_WIDTH = 32;

    // Variables for top-level DUT
    logic        WCLK;
    logic        RCLK;
    logic        reset;
    logic        WR;
    logic        RD;
    logic [31:0] WD2;
    logic        E;
    logic        F;
    logic [31:0] RD1Out;

    // Variables to track program execution
    integer                trace_file;
    integer                scan_result;
    logic [DATA_WIDTH-1:0] ReadOut;
    logic [DATA_WIDTH-1:0] ExpectedRead;
    logic [DATA_WIDTH-1:0] WriteVal;
    integer                instr_count = 0;

    logic [DATA_WIDTH-1:0] queue [$];

    // Initialize top-level module
    top dut (
        .WCLK,
        .RCLK,
        .reset,
        .WR,
        .RD,
        .WD2,
        .RD1Out,
        .E,
        .F
    );

    task write(input logic [DATA_WIDTH-1:0] d);
        @(posedge WCLK)
        #1;

        if (!F)
            queue.push_back(d);
        else
            $display("\n[%0t] WARNING: WRITING TO FULL QUEUE", $time);

        WR = 1;
        WD2 = d;
    
        @(posedge WCLK)
        #1;

        WR = 0;
    endtask

    task read();
        logic ValidRead;

        @(posedge RCLK)
        #1;

        if (!E) begin
            ExpectedRead = queue.pop_front();
            ValidRead = 1;
        end
        else begin
            $display("\n[%0t] WARNING: READING FROM EMPTY QUEUE", $time);
            ValidRead = 0;
        end

        RD = 1;
        
        @(posedge RCLK)
        #1;

        RD = 0;
        ReadOut = RD1Out;

        if (ValidRead == 1)
            if (ReadOut !== ExpectedRead) begin
                $display("\n[%0t] ERROR: Expected %h, received %h", $time, ExpectedRead, ReadOut);
                $stop;
            end
            else
                $display("[%0t] PASS: Passed %h to the output", $time, ExpectedRead);
    endtask

    task readLine();
        scan_result = $fscanf(trace_file, "%h", WriteVal);
    endtask

    // Generate write clock
    always begin
        WCLK = 1;
        #5;
        WCLK = 0;
        #5;
    end

    // Generate read clock
    always begin
        RCLK = 1;
        #3.655;
        RCLK = 0;
        #3.655;
    end

    // Setup and reset
    initial begin
        trace_file = $fopen("data/wr_data.txt", "r");
        if (trace_file == 0) begin
            $display("\n[%0t] ERROR: Could not open trace file", $time);
            $stop;
        end

        WR = 0;
        RD = 0;
        WD2 = 0;

        reset = 1;
        #20;
        reset = 0;
    end

    initial begin
        $display("\n[%0t] Starting FIFO Directed Tests... ", $time);

        wait(reset == 0);
        #5;

        // TEST 1: Basic read and write
        $display("\n-----TEST 1: Basic read and write-----");
        readLine();
        write(WriteVal);
        readLine();
        write(WriteVal);

        wait(!E);
        @(posedge RCLK);

        read();
        read();

        // TEST 2: Fill FIFO
        $display("\n-----TEST 2: Fill FIFO-----");
        for (int i = 0; i < 64; i++) begin
            readLine();
            write(WriteVal);
        end

        if (F !== 1) begin
            $display("\n[%0t] ERROR: FIFO DID NOT FILL", $time);
            $stop;
        end

        // TEST 3: Overfill FIFO
        $display("\n-----TEST 3: Overfill FIFO-----");
        for (int j = 0; j < 3; j++) begin
            readLine();
            write(WriteVal);
        end

        // TEST 4: Empty FIFO
        $display("\n-----TEST 4: Empty FIFO-----");
        for (int k = 0; k < 64; k++)
            read();

        if (E !== 1) begin
            $display("\n[%0t] ERROR: FIFO DID NOT EMPTY", $time);
            $stop;
        end

        // TEST 5: Underfill FIFO
        $display("\n-----TEST 5: Underfill FIFO-----");
        for (int l = 0; l < 3; l++)
            read();

        // TEST 6: Simultaneous reads and writes
        $display("\n-----TEST 6: Simultaneous reads and writes");
        for (int m = 0; m < 10; m++) begin
            fork
                begin
                    readLine();
                    write(WriteVal);
                    readLine();
                    write(WriteVal);
                end
                begin
                    wait(!E);
                    read();
                end
            join
        end

        // Successful execution of all tests
        $display("\n\nSUCCESS: ALL TESTS PASSED\n");
        $finish;
    end
endmodule
