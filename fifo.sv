module fifo #(parameter DEPTH=4, WIDTH=32)
(
	output logic [WIDTH-1:0] r_data,
	output logic full_o,
	output logic empty_o,

	input  logic clk,
	input  logic rstn,
	input  logic rd_req,
	input  logic wr_req,
	input  logic [WIDTH-1:0] w_data
);

	localparam DEPTH_LOG  = $clog2(DEPTH);

	logic [DEPTH-1:0][WIDTH-1:0] i_fifo;  // Changed to logic
	logic [DEPTH_LOG:0] wr_ptr;               // 1 extra bit
	logic [DEPTH_LOG:0] rd_ptr;				 // 1 extra bit
	logic full_w;
	logic empty_w;

	// Data FF
	always_ff @(posedge clk or negedge rstn) begin  // Changed sensitivity list
		if (~rstn) begin
			i_fifo <= '{default:0};
			r_data <= '0;    // Fixed assignment
			wr_ptr <= '0;
			rd_ptr <= '0;
		end
		else begin
			if (rd_req && ~empty_w && ~wr_req) begin  // Added check for rd and wr in parallel
				r_data <= i_fifo[rd_ptr[DEPTH_LOG-1:0]];
				rd_ptr <= rd_ptr + 1;
			end
			if (wr_req && ~full_w && ~rd_req) begin  // Added check for rd and wr in parallel
				i_fifo[wr_ptr[DEPTH_LOG-1:0]] <= w_data;
				wr_ptr <= wr_ptr + 1;
			end
		end
	end

	// Empty and full signals

	assign full_w = (wr_ptr[DEPTH_LOG-1:0] == rd_ptr[DEPTH_LOG-1:0] && wr_ptr[DEPTH_LOG] != rd_ptr[DEPTH_LOG]);
	assign empty_w = (wr_ptr == rd_ptr);

	assign full_o = full_w;
	assign empty_o = empty_w;

endmodule
