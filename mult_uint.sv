module mult_uint #(parameter N = 8)
(
	input  logic   [N-1:0] dataa, datab,
	
	output logic [2*N-1:0] result
);

	assign result = dataa * datab;

endmodule