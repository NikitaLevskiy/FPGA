module adder_uint #(parameter N = 8)
(
	input  logic [N-1:0] dataa, datab,
	input  logic         cin,
	
	output logic [N-1:0] s,
	output logic         cout
);

	assign {cout, s} = dataa + datab + cin;

endmodule