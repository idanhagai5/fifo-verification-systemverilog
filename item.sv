class fifo_item;
	// 1. Transaction Definition
	
	rand bit wr_req;
	rand bit rd_req;
	rand bit [WIDTH-1:0] wr_data;
	bit [WIDTH-1:0] rd_data;
	bit full;
	bit empty;
	
	rand bit [2:0] delay;
		
	constraint no_parallel {rd_req ^ wr_req == 1'b1; }
	constraint delay_after_read {
	rd_req->delay>='1;solve rd_req before delay;}


endclass : fifo_item
