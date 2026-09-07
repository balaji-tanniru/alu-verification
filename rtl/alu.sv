module alu #(
    parameter int WIDTH = 32
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [2:0]       op,
    output logic [WIDTH-1:0] result,
    output logic             zero,
    output logic             carry,
    output logic             overflow
);
    localparam int SHIFT_W = (WIDTH > 1) ? $clog2(WIDTH) : 1;
    logic [WIDTH:0] extended_result;
    always_comb begin
        result='0; carry=1'b0; overflow=1'b0; extended_result='0;
        case(op)
          3'b000: begin
            extended_result={1'b0,a}+{1'b0,b}; result=extended_result[WIDTH-1:0]; carry=extended_result[WIDTH];
            overflow=(a[WIDTH-1]==b[WIDTH-1])&&(result[WIDTH-1]!=a[WIDTH-1]);
          end
          3'b001: begin
            extended_result={1'b0,a}-{1'b0,b}; result=extended_result[WIDTH-1:0];
            carry=extended_result[WIDTH]; // high bit is the borrow indication on underflow
            overflow=(a[WIDTH-1]!=b[WIDTH-1])&&(result[WIDTH-1]!=a[WIDTH-1]);
          end
          3'b010: result=a&b; 3'b011: result=a|b; 3'b100: result=a^b;
          3'b101: result=a << b[SHIFT_W-1:0]; 3'b110: result=a >> b[SHIFT_W-1:0];
          3'b111: result=($signed(a)<$signed(b)) ? {{(WIDTH-1){1'b0}},1'b1} : '0;
          default: result='0;
        endcase
        zero=(result=='0);
    end
endmodule
