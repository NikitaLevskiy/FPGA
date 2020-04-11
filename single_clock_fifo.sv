module single_clock_fifo #(parameter N = 4, M = 3)
(
	input  logic                rst, clk, r_en, w_en, 
	input  logic signed [N-1:0] data,
	
	output logic signed [N-1:0] result,
	output logic                empty, full
);

	logic [M-1:0] r_addr, w_addr;
	logic         r_enable, w_enable;
	
	assign r_enable = r_en & !empty;
	assign w_enable = w_en & !full;

	counter u0 (rst, clk, r_enable, r_addr);
	counter u1 (rst, clk, w_enable, w_addr);
	
	
	ram_dual_clock u2 (data, r_addr, w_addr, r_enable, w_enable, rst, clk, result);
	
	
	logic signed [M:0] sub;
	
	always_comb begin
	
		  if (r_addr == w_addr) empty = 1'd1;
		
		else                    empty = 1'd0;
		
		sub = w_addr - r_addr;
		
		  if ((sub == 2**M-1) || (sub == -2**M-1)) full = 1'd1;
		
		else                                       full = 1'd0;
	
	end

endmodule

module counter #(parameter N = 3)
(
	input  logic         rst, clk, en,
	
	output logic [N-1:0] counter
);

	always_ff @(posedge clk, posedge rst)
	
		     if (rst) counter <= 0;
		
		else if  (en) counter <= counter + 1'd1;

endmodule

module ram_dual_clock #(parameter N = 4, M = 3)
(
	input  logic signed [N-1:0] data,
	input  logic        [M-1:0] r_addr,
	input  logic        [M-1:0] w_addr,
	input  logic                re, we, rst, clk,
	
	output logic signed [N-1:0] result
);

	logic [N-1:0] ram [2**M-1:0];
	
	always_ff @(posedge clk)
	
		     if (rst) result <= 0;
	
		else if  (re) result <= ram[r_addr];
		
		
	always_ff @(posedge clk)
	
		if (we) ram[w_addr] <= data;

endmodule