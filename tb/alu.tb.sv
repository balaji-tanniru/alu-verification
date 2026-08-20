`timescale 1ns/1ps

module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [2:0]  op;
    logic [31:0] result;
    logic        zero;
    logic        carry;
    logic        overflow;

    int pass_count;
    int fail_count;

    alu dut (
        .a        (a),
        .b        (b),
        .op       (op),
        .result   (result),
        .zero     (zero),
        .carry    (carry),
        .overflow (overflow)
    );

    task automatic check_result(
        input logic [31:0] test_a,
        input logic [31:0] test_b,
        input logic [2:0]  test_op,
        input logic [31:0] expected,
        input string       test_name
    );
        begin
            a  = test_a;
            b  = test_b;
            op = test_op;

            #10;

            assert (result === expected)
            begin
                pass_count++;
                $display("PASS: %s | result = %h",
                         test_name, result);
            end
            else
            begin
                fail_count++;
                $error("FAIL: %s | expected = %h, actual = %h",
                       test_name, expected, result);
            end

            assert (zero === (expected == 32'b0))
            else
            begin
                fail_count++;
                $error("ZERO FLAG ERROR in %s", test_name);
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;
        a           = 0;
        b           = 0;
        op          = 0;

        check_result(32'd10, 32'd5, 3'b000,
                     32'd15, "Addition");

        check_result(32'd10, 32'd5, 3'b001,
                     32'd5, "Subtraction");

        check_result(32'hF0, 32'h0F, 3'b010,
                     32'h00, "AND");

        check_result(32'hF0, 32'h0F, 3'b011,
                     32'hFF, "OR");

        check_result(32'hAA, 32'hFF, 3'b100,
                     32'h55, "XOR");

        check_result(32'd1, 32'd4, 3'b101,
                     32'd16, "Shift Left");

        check_result(32'h80, 32'd3, 3'b110,
                     32'h10, "Shift Right");

        check_result(32'hFFFF_FFFF, 32'd1, 3'b111,
                     32'd1, "Signed Less Than");

        check_result(32'd0, 32'd0, 3'b000,
                     32'd0, "Zero Result");

        check_result(32'hFFFF_FFFF, 32'd1, 3'b000,
                     32'd0, "Carry Test");

        assert (carry === 1'b1)
        else
        begin
            fail_count++;
            $error("CARRY ASSERTION FAILED");
        end

        check_result(32'h7FFF_FFFF, 32'd1, 3'b000,
                     32'h8000_0000, "Overflow Test");

        assert (overflow === 1'b1)
        else
        begin
            fail_count++;
            $error("OVERFLOW ASSERTION FAILED");
        end

        $display("---------------------------------------");
        $display("Tests Passed : %0d", pass_count);
        $display("Tests Failed : %0d", fail_count);
        $display("---------------------------------------");

        if (fail_count == 0)
            $display("FINAL RESULT: ALL TESTS PASSED");
        else
            $display("FINAL RESULT: TESTS FAILED");

        #10;
        $finish;
    end

endmodule