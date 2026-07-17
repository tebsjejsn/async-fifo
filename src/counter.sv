module counter(
    input  logic [6:0] a,
    input  logic       s,
    output logic [6:0] y
);
    logic [6:0] binary;

    always_comb begin
        if (s)
            if (a != 7'd127)
                binary = a + 1;
            else
                binary = 0;
        else
            binary = a;

        y = binary ^ (binary >> 1);
    end
endmodule