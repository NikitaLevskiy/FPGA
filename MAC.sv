module MAC #(parameter N = 8)
(
	input  logic                   clk, rst,
	input  logic signed    [N-1:0] dataa, datab,
	
	output logic signed  [2*N-1:0] result
);

	logic [N-1:0] x1,x2;

	always_ff @(posedge clk, posedge rst) begin
	
		if (rst) begin
		
			x1 <= 0;
			x2 <= 0;
			
		end else begin
		
			x1 <= dataa;
			x2 <= datab;
		
		end
		
	end
	
	
	
	logic [2*N-1:0] multiplier;
	
	always_ff @(posedge clk, posedge rst)
	
		  if (rst) multiplier <= 0;
		
		else       multiplier <= x1 * x2;
	
	
	
	//assign multiplier = x1 * x2;
	
	
	
	always_ff @(posedge clk, posedge rst)
	
		  if (rst) result <= 0;
		
		else       result <= multiplier + result;

endmodule