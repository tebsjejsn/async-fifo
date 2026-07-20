module top(
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
    datapath dp (
        .WCLK,
        .RCLK,
        .reset,
        .WR,
        .RD,
        .WD2,
        .E,
        .F,
        .RD1Out
    );
endmodule