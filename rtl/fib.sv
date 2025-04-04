module fib #(
  parameter INPUT_WIDTH = 8,  // Width of input number
  parameter OUTPUT_WIDTH = 32 // Width of output result
)(
  input logic clk,           // Clock signal
  input logic rst_n,         // Active low synchronous reset
  input logic [INPUT_WIDTH-1:0] fib_in,  // Input number
  input logic vld_in,        // Input valid
  input logic rdy_out,       // Output ready
  output logic rdy_in,       // Input ready
  output logic [OUTPUT_WIDTH-1:0] fib_out, // Output result
  output logic vld_out       // Output valid
);

  // Define states for the FSM
  typedef enum logic [1:0] {
    IDLE,        // Waiting for input
    CALCULATING, // Calculating Fibonacci number
    DONE         // Result ready
  } state_t;

  // State registers
  state_t current_state, next_state;

  // Internal registers for calculation
  logic [OUTPUT_WIDTH-1:0] a, b;  // Previous two Fibonacci numbers
  logic [INPUT_WIDTH-1:0] counter; // Counter for calculation steps
  logic [INPUT_WIDTH-1:0] n;       // Store input number

  // State transition logic
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
      a <= 0;
      b <= 1;
      counter <= 0;
      n <= 0;
      fib_out <= 0;
    end else begin
      current_state <= next_state;
      
      // Update calculation registers
      case (current_state)
        IDLE: begin
          if (vld_in && rdy_in) begin
            n <= fib_in;
            counter <= 0;
            a <= 0;
            b <= 1;
          end
        end
        
        CALCULATING: begin
          if (counter < n) begin
            a <= b;
            b <= a + b;
            counter <= counter + 1;
          end
        end
        
        DONE: begin
          if (rdy_out) begin
            fib_out <= b;
          end
        end
      endcase
    end
  end

  // Define next state logic
  always_comb begin
    next_state = current_state;
    
    case (current_state)
      IDLE: begin
        if (vld_in && rdy_in) begin
          next_state = CALCULATING;
        end
      end
      
      CALCULATING: begin
        if (counter == n) begin
          next_state = DONE;
        end
      end
      
      DONE: begin
        if (rdy_out) begin
          next_state = IDLE;
        end
      end
    endcase
  end

  // Output assignments
  assign rdy_in = (current_state == IDLE);
  assign vld_out = (current_state == DONE);

endmodule
