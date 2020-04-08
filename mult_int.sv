module mult_int #(parameter N = 8)
(
	input  logic signed   [N-1:0] dataa, datab,
	
	output logic signed [2*N-1:0] result
);

	assign result = dataa * datab;

endmodule