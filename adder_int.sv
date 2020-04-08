module adder_int #(parameter N = 8)
(
	input  logic signed [N-1:0] dataa, datab,
	
	output logic signed   [N:0] s
);

	assign s = dataa + datab;

endmodule