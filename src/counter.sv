module counter(
    input  logic [6:0] a,
    input  logic       s,
    output logic [6:0] y,
    output logic [6:0] y_bin
);
    logic [6:0] bin;
    logic [6:0] binNext;

    always_comb begin
        bin[6] = a[6];
        bin[5] = a[5] ^ bin[6];
        bin[4] = a[4] ^ bin[5];
        bin[3] = a[3] ^ bin[4];
        bin[2] = a[2] ^ bin[3];
        bin[1] = a[1] ^ bin[2];
        bin[0] = a[0] ^ bin[1];

        if (s)
            binNext = bin + 1;
        else
            binNext = bin;

        y = binNext ^ (binNext >> 1);
        y_bin = binNext;
    end
endmodule