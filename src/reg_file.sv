module reg_file(
    input  logic        WCLK,
    input  logic        RCLK,
    input  logic [5:0]  A1,
    input  logic [5:0]  A2,
    input  logic        WE2,
    input  logic [31:0] WD2,
    input  logic        RE1,
    output logic [31:0] RD1
);
    logic [31:0] reg_type [63:0];

    always_ff @(posedge WCLK) 
    begin
        if (WE2)
            reg_type[A2] <= WD2;

    end

    always_ff @(posedge RCLK) begin
        if (RE1)
            RD1 <= reg_type[A1];
    end
endmodule
