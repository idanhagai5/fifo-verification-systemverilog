interface fifo_if(input logic clk, input logic rstn);
// 2. Interface Definition
logic wr_req;
logic rd_req;
logic [WIDTH-1:0] wr_data;
logic [WIDTH-1:0] rd_data;
logic full;
logic empty;


endinterface : fifo_if

