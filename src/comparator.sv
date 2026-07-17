module comparator
#(
    parameter width=7
) (
    input  logic [width-1:0] addr,
    input  logic [width-1:0] prevAddr,
    input  logic       s,
    output logic       flag
);
    always_comb begin
        flag = '0;

        // Checks if empty
        if (s && addr[width-1:0] == prevAddr[width-1:0])
            flag = '1;
        // Checks if full
        else if (!s && (addr[width-3:0] == prevAddr[width-3:0] && addr[width-1:width-2] == ~prevAddr[width-1:width-2]))
            flag = '1;
    end
endmodule