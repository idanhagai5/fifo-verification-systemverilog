module fifo_testbench;

// ---------------------- //
//    Clock and reset     //
//   Do not modify		  //
// ---------------------- //

	bit clk;
	bit rstn;
	int errors;
	
	// This initial block initializes clk, rstn, and 'turns on' the FIFO by driving 1 to rstn after 2 cycles.
	initial begin
		clk = 1'b0;
		rstn = 1'b0;
		
		@(posedge clk);
		@(posedge clk);
		rstn = 1'b1;
	end
	
	// This always block generates our clk
	always #5 clk = ~clk;
	
	// ---------------------- //
	//    Instantiations 	  //
	//  DO modify			  //
	// ---------------------- //
	
	// Interface Instantiation (2.2)

	fifo_if fifo_if(.clk(clk), .rstn(rstn));
	
	// Design Module Instantiation (2.3)
	
	fifo f1(.rd_req(fifo_if.rd_req), 
	.wr_req(fifo_if.wr_req),
	.r_data(fifo_if.rd_data),
	.w_data(fifo_if.wr_data),
	.full_o(fifo_if.full),
	.empty_o(fifo_if.empty),
	.clk(clk),
	.rstn(rstn)
	);
	

	// ---------------------- //
	//  Testbench components
	// ---------------------- // 
	
	mailbox #(fifo_item) generator_to_driver_mailbox;
	mailbox #(fifo_item) monitor_to_model_mailbox;
	
	// 3. Generator
	task Generator();
		fifo_item item;
		repeat (50) begin
			item=new();
			item.randomize();
			generator_to_driver_mailbox.put(item);
		end

	
	endtask : Generator
	
	
	// 4. Driver
	task Driver;
		fifo_item item;
		forever begin
			generator_to_driver_mailbox.get(item);
			fifo_if.wr_req<=item.wr_req;
			fifo_if.rd_req<=item.rd_req;
			fifo_if.wr_data<=item.wr_data;
			@(posedge clk);
			fifo_if.wr_req<=1'b0;
			fifo_if.rd_req<=1'b0;
			fifo_if.wr_data<=32'bx;
			repeat (item.delay) @(posedge clk);
						
		end

		
	endtask : Driver
	
	// 5. Monitor
	task Monitor();
	fifo_item item;
	forever begin
		item = new();
		@(posedge clk);
		if (fifo_if.wr_req || fifo_if.rd_req) begin 
			if (fifo_if.wr_req) begin 
				item.wr_req=fifo_if.wr_req;
				item.rd_req=fifo_if.rd_req;
				item.wr_data=fifo_if.wr_data;
				#1
				item.full=fifo_if.full;
				
			end
			else begin 
				item.wr_req=fifo_if.wr_req;
				item.rd_req=fifo_if.rd_req;
				item.empty=fifo_if.empty;
				#1
				item.empty=fifo_if.empty;
				item.rd_data=fifo_if.rd_data;
			end
			
		monitor_to_model_mailbox.put(item);
		
		end
	end 
	
	endtask : Monitor
	
	// 6. Model 
	task Model();
		fifo_item item;
		logic [WIDTH-1:0] model_fifo [$:DEPTH];
		logic [WIDTH-1:0] correct_data;
		errors=0;
		forever begin
			monitor_to_model_mailbox.get(item);
			if (item.wr_req) begin
				if (model_fifo.size()== DEPTH) begin // model is full
					if (item.full== 1'b0) begin
						$error ("Mismatch with full signal at time:%0t",$time);
						errors ++;
					end
				end else begin // model is not full 
					model_fifo.push_back(item.wr_data);
					if (model_fifo.size()== DEPTH) begin // after push,model is full
						if(item.full==1'b0) begin  // model is full and 'full' is off
							$error ("Mismatch with full signal at time:%0t",$time);
							errors++;
						end
					end else begin 
						if(item.full==1'b1) begin  // model is not full and 'full' is on
							$error ("Mismatch with full signal at time:%0t",$time);
							errors++;
						end
					end
				end
			end else begin // a read request
				if (model_fifo.size() == 0) begin
					if (item.empty==1'b0) begin // model is empty and 'empty' is off
						$error ("Mismatch with empty signal at time:%0t",$time);
						errors ++;
					end
				end else begin // model is not empty
					correct_data = model_fifo.pop_front();
					if (correct_data != item.rd_data) begin 
						$error ("Mismatch with rd_data signal at time:%0t,correct data: %h read data: %h  ",$time,correct_data,item.rd_data);	
						errors ++;
					end
					if (model_fifo.size()==0) begin
						if (item.empty==1'b0) begin // model is empty and 'empty' is off 
						$error ("Mismatch with empty signal at time:%0t",$time);
						errors++;
					end
					end else begin // model is not empty
						if (item.empty==1'b1) begin // model is not empty and 'empty' is on 
							$error ("Mismatch with empty signal at time:%0t",$time);
							errors++;
						end
					end
				end
			end
		end
	endtask
	
	// ---------------------- //
	//    Simulation start    //
	//    Do not modify       // 
	// ---------------------- //
	initial begin
		
		// Testbench component instantiation
		generator_to_driver_mailbox = new();
		monitor_to_model_mailbox    = new();
		
		@(rstn == '1);
		@(posedge clk);
		
		fork
			Generator();
			Driver();
			Monitor();
			Model();
		join
		
	end
	
	initial begin
		#10000;
		//$display("simulation ends with %d errors",errors);
		$finish();
		
	end

endmodule
