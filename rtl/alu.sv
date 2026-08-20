module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [2:0]  op,
    output logic [31:0] result,
    output logic        zero,
    output logic        carry,
    output logic        overflow
);

    logic [32:0] extended_result;

    always_comb begin
        result          = 32'b0;
        carry           = 1'b0;
        overflow        = 1'b0;
        extended_result = 33'b0;

        case (op)
            3'b000: begin
                extended_result = {1'b0, a} + {1'b0, b};
                result = extended_result[31:0];
                carry  = extended_result[32];
                overflow = (a[31] == b[31]) &&
                           (result[31] != a[31]);
            end

            3'b001: begin
                result = a - b;
                overflow = (a[31] != b[31]) &&
                           (result[31] != a[31]);
            end

            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = a << b[4:0];
            3'b110: result = a >> b[4:0];
            3'b111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;

            default: result = 32'b0;
        endcase

        zero = (result == 32'b0);
    end

endmodule