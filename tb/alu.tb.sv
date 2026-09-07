`timescale 1ns/1ps
module alu_tb;
  localparam int WIDTH=32;
  logic [WIDTH-1:0] a,b,result; logic [2:0] op; logic zero,carry,overflow;
  int pass_count=0, fail_count=0, check_count=0;
  alu #(.WIDTH(WIDTH)) dut(.*);

`ifndef __ICARUS__
  class alu_txn;
    rand logic [WIDTH-1:0] a,b; rand logic [2:0] op;
    constraint valid_op_c { op inside {[3'b000:3'b111]}; }
    constraint corners_c {
      a dist { '0:=8, {WIDTH{1'b1}}:=8, 32'h7fff_ffff:=8, 32'h8000_0000:=8, [1:32'h7fff_fffe]:=1, [32'h8000_0001:32'hffff_fffe]:=1 };
      b dist { '0:=8, {WIDTH{1'b1}}:=8, 32'h7fff_ffff:=8, 32'h8000_0000:=8, [1:32'h7fff_fffe]:=1, [32'h8000_0001:32'hffff_fffe]:=1 };
    }
  endclass
  covergroup alu_cg;
    cp_op: coverpoint op;
    cp_a: coverpoint a { bins zero={'0}; bins ones={{WIDTH{1'b1}}}; bins maxpos={32'h7fff_ffff}; bins minneg={32'h8000_0000}; bins other=default; }
    cp_b: coverpoint b { bins zero={'0}; bins ones={{WIDTH{1'b1}}}; bins maxpos={32'h7fff_ffff}; bins minneg={32'h8000_0000}; bins other=default; }
    cp_carry: coverpoint carry; cp_overflow: coverpoint overflow;
    op_x_flags: cross cp_op,cp_carry,cp_overflow;
  endgroup
  alu_cg cov=new();
`endif

    task automatic ref_model(
    input  logic [WIDTH-1:0] ra,
    input  logic [WIDTH-1:0] rb,
    input  logic [2:0]       rop,
    output logic [WIDTH-1:0] rr,
    output logic             rz,
    output logic             rc,
    output logic             rv
  );
    logic [WIDTH:0] ext;
    localparam int SW = (WIDTH > 1) ? $clog2(WIDTH) : 1;

    begin
      rr  = '0;
      rc  = 1'b0;
      rv  = 1'b0;
      ext = '0;

      case (rop)
        3'b000: begin
          ext = {1'b0, ra} + {1'b0, rb};
          rr  = ext[WIDTH-1:0];
          rc  = ext[WIDTH];
          rv  = (ra[WIDTH-1] == rb[WIDTH-1]) &&
                (rr[WIDTH-1] != ra[WIDTH-1]);
        end

        3'b001: begin
          ext = {1'b0, ra} - {1'b0, rb};
          rr  = ext[WIDTH-1:0];
          rc  = ext[WIDTH];
          rv  = (ra[WIDTH-1] != rb[WIDTH-1]) &&
                (rr[WIDTH-1] != ra[WIDTH-1]);
        end

        3'b010: rr = ra & rb;
        3'b011: rr = ra | rb;
        3'b100: rr = ra ^ rb;
        3'b101: rr = ra << rb[SW-1:0];
        3'b110: rr = ra >> rb[SW-1:0];

        3'b111: begin
          rr = ($signed(ra) < $signed(rb))
             ? {{(WIDTH-1){1'b0}}, 1'b1}
             : '0;
        end

        default: rr = '0;
      endcase

      rz = (rr == '0);
    end
  endtask
  task automatic check_result(input logic[WIDTH-1:0] ta,tb,input logic[2:0] top,input string name);
    logic[WIDTH-1:0] er; logic ez,ec,ev; bit bad;
    begin a=ta;b=tb;op=top; #1; ref_model(ta,tb,top,er,ez,ec,ev); bad=0; check_count++;
      if(result!==er) begin bad=1;$error("%s result exp=%h got=%h",name,er,result);end
      if(zero!==ez) begin bad=1;$error("%s zero exp=%b got=%b",name,ez,zero);end
      if(carry!==ec) begin bad=1;$error("%s carry exp=%b got=%b",name,ec,carry);end
      if(overflow!==ev) begin bad=1;$error("%s overflow exp=%b got=%b",name,ev,overflow);end
      if(bad) fail_count++; else pass_count++;
`ifndef __ICARUS__
      cov.sample();
`endif
    end
  endtask
  initial begin
    $dumpfile("proof/alu_wave.vcd"); $dumpvars(0,alu_tb); a='0;b='0;op='0;
    check_result(32'd10,32'd5,3'b000,"Addition"); check_result(32'd10,32'd5,3'b001,"Subtraction");
    check_result(32'hF0,32'h0F,3'b010,"AND"); check_result(32'hF0,32'h0F,3'b011,"OR");
    check_result(32'hAA,32'hFF,3'b100,"XOR"); check_result(32'd1,32'd4,3'b101,"Shift Left");
    check_result(32'h80,32'd3,3'b110,"Shift Right"); check_result(32'hffff_ffff,32'd1,3'b111,"Signed Less Than");
    check_result('0,'0,3'b000,"Zero Result"); check_result(32'hffff_ffff,32'd1,3'b000,"Carry Test");
    check_result(32'h7fff_ffff,32'd1,3'b000,"Overflow Test"); check_result(32'd0,32'd1,3'b001,"Borrow Test");
`ifndef __ICARUS__
    begin alu_txn txn=new(); repeat(500) begin if(!txn.randomize()) $fatal(1,"alu_txn randomization failed"); check_result(txn.a,txn.b,txn.op,"Random"); end end
`else
    repeat(500) check_result($urandom,$urandom,$urandom_range(7,0),"Portable random");
`endif
    if(fail_count!=0) $fatal(1,"ALU_TEST_FAIL checks=%0d errors=%0d",check_count,fail_count);
    $display("ALU_TEST_PASS checks=%0d errors=0",check_count); $finish;
  end
endmodule
