module tb_fib;

// Declare test variables
logic clk;

// Instantiate Design 
// fib Fib (.*);

// Sample to drive clock
localparam CLK_PERIOD = 10;
always begin
    #(CLK_PERIOD/2) 
    clk<=~clk;
end

// Test signals
logic rst_n;
logic [7:0] fib_in;
logic vld_in;
logic rdy_out;
logic rdy_in;
logic [31:0] fib_out;
logic vld_out;

// Instantiate the Fibonacci calculator
fib #(
  .INPUT_WIDTH(8),
  .OUTPUT_WIDTH(32)
) dut (
  .clk(clk),
  .rst_n(rst_n),
  .fib_in(fib_in),
  .vld_in(vld_in),
  .rdy_out(rdy_out),
  .rdy_in(rdy_in),
  .fib_out(fib_out),
  .vld_out(vld_out)
);

// Function to calculate expected Fibonacci number
function automatic [31:0] calculate_fibonacci(input [7:0] n);
  if (n == 0) return 0;
  if (n == 1) return 1;
  
  logic [31:0] a = 0;
  logic [31:0] b = 1;
  logic [31:0] temp;
  
  for (int i = 2; i <= n; i++) begin
    temp = b;
    b = a + b;
    a = temp;
  end
  
  return b;
endfunction

// Task to send a number to the calculator
task send_number(input [7:0] number);
  // Wait until calculator is ready
  while (!rdy_in) @(posedge clk);
  
  // Send the number
  fib_in = number;
  vld_in = 1;
  @(posedge clk);
  vld_in = 0;
endtask

// Task to receive result from calculator
task receive_result(output [31:0] result);
  // Wait until result is valid
  while (!vld_out) @(posedge clk);
  
  // Read the result
  result = fib_out;
  rdy_out = 1;
  @(posedge clk);
  rdy_out = 0;
endtask

// Necessary to create Waveform
initial begin
    // Name as needed
    $dumpfile("tb_fib.vcd");
    $dumpvars(0);
end

initial begin
    // Initialize signals
    clk = 0;
    rst_n = 0;
    fib_in = 0;
    vld_in = 0;
    rdy_out = 0;

    // Reset the design
    @(posedge clk);
    rst_n = 1;

    // Test cases
    for (int i = 0; i <= 10; i++) begin
      logic [31:0] expected_result;
      logic [31:0] actual_result;
      
      // Calculate expected result
      expected_result = calculate_fibonacci(i);
      
      // Send number to calculator
      send_number(i);
      
      // Receive result
      receive_result(actual_result);
      
      // Verify result
      $assert(actual_result == expected_result) 
        else $error("Fibonacci(%0d) = %0d, expected %0d", 
                    i, actual_result, expected_result);
      
      $display("Fibonacci(%0d) = %0d", i, actual_result);
    end

    $display("All tests passed!");
    $finish();
end

endmodule
