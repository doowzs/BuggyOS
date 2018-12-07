module sign_ex(
  in, out
);
  parameter INPUT_WIDTH  = 16;
  parameter OUTPUT_WIDTH = 32;

  input  [INPUT_WIDTH-1:0]  in;
  output [OUTPUT_WIDTH-1:0] out;

  localparam MSB_POSITION = INPUT_WIDTH - 1;
  localparam MSB_REP_COUNT = OUTPUT_WIDTH - INPUT_WIDTH;

  assign out = {{MSB_REP_COUNT{in[MSB_POSITION]}}, in[INPUT_WIDTH-1:0]};

endmodule 
