module flopr
#(
    parameter width=6
) (
    input  logic        clk,
    input  logic        reset,
    input  logic [width-1:0] d,
    output logic [width-1:0] q
);
    always_ff @(posedge clk, posedge reset)
    begin
        if (reset)
            q <= '0;
        else
            q <= d;
    end
endmodule