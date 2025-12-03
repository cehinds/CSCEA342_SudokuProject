module ram # (parameter N = 4, M = 16)
			(input		logic 			clk,		//clock
			input 		logic 			we,			//write enable
			input 		logic [N-1:0]	adr,		//address
			input 		logic [M-1:0]	din,		//data in
			output 	logic [M-1:0]	dout);		//data out

	logic [M-1:0] mem [2**N - 1:0];			//array of bits

	always @ (posedge clk)				
		if (we) mem [adr] <= din;				
	// if write enabled, then assign din to a row in memory

	assign dout = mem[adr];					//read memory

endmodule
