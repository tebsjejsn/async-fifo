module datapath(
    input  logic        WCLK,
    input  logic        RCLK,
    input  logic        reset,
    input  logic        WR,
    input  logic        RD,
    input  logic [31:0] WD2,
    output logic        E,
    output logic        F,
    output logic [31:0] RD1Out
);
    logic [6:0]  A1Next;
    logic [6:0]  A1;
    logic [6:0]  A2Next;
    logic [6:0]  A2;
    logic        RE1;
    logic        WE2;
    logic [6:0]  A1Sync;
    logic [6:0]  A2Sync;
    logic [6:0]  A1Prev;
    logic [6:0]  A2Prev;
    logic [31:0] RD1Next;

    // Address flip-flops
    flopr #(.width(7)) rclk (
        .clk(RCLK),
        .reset,
        .d(A1Next),
        .q(A1)
    );

    flopr #(.width(7)) wclk (
        .clk(WCLK),
        .reset,
        .d(A2Next),
        .q(A2)
    );

    // Address counters
    counter a1count (
        .a(A1),
        .s(RE1),
        .y(A1Next)
    );

    counter a2count (
        .a(A2),
        .s(WE2),
        .y(A2Next)
    );

    // Synchronizer flip-flops
    flopr #(.width(7)) a1sync1 (
        .clk(WCLK),
        .reset,
        .d(A1),
        .q(A1Sync)
    );

    flopr #(.width(7)) a1sync2 (
        .clk(WCLK),
        .reset,
        .d(A1Sync),
        .q(A1Prev)
    );

    flopr #(.width(7)) a2sync1 (
        .clk(RCLK),
        .reset,
        .d(A2),
        .q(A2Sync)
    );

    flopr #(.width(7)) a2sync2 (
        .clk(RCLK),
        .reset,
        .d(A2Sync),
        .q(A2Prev)
    );

    // Address comparators
    comparator #(.width(7)) a1cmp (
        .addr(A1),
        .prevAddr(A2Prev),
        .s(1'b1),
        .flag(E)
    );

    comparator #(.width(7)) a2cmp (
        .addr(A2),
        .prevAddr(A1Prev),
        .s(1'b0),
        .flag(F)
    );

    // Register file
    reg_file rf (
        .WCLK,
        .RCLK,
        .A1(A1[5:0]),
        .A2(A2[5:0]),
        .WE2,
        .WD2,
        .RE1,
        .RD1(RD1Next)
    );

    // Read output flip-flop
    flopr #(.width(32)) rd1 (
        .clk(RCLK),
        .reset,
        .d(RD1Next),
        .q(RD1Out)
    );

    // Logic for enables
    assign RE1 = RD && !E;
    assign WE2 = WR && !F;
endmodule