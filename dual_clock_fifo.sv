module dual_clock_fifo #(parameter DSIZE = 8, ASIZE = 4)
(
	input  logic [DSIZE-1:0] wdata,
   input  logic             winc, wclk, wrst, rinc, rclk, rrst,
	
	output logic [DSIZE-1:0] rdata,
   output logic             wfull, rempty
);
	
	logic [ASIZE-1:0] waddr, raddr;
   logic   [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;
  
  
  sync_r2w sync_r2w
  (
		.wq2_rptr(wq2_rptr), 
		.rptr(rptr),
		.wclk(wclk),
		.wrst(wrst)
  );
									
  sync_w2r sync_w2r 
  (
		.rq2_wptr(rq2_wptr),
		.wptr(wptr),
      .rclk(rclk),
		.rrst(rrst)
  );
  
  fifomem #(DSIZE, ASIZE) fifomem
  (
		.rdata(rdata),
		.wdata(wdata),
      .waddr(waddr),
		.raddr(raddr),
      .wclken(winc),
		.wfull(wfull),
      .wclk(wclk)
  );
  
  rptr_empty #(ASIZE) rptr_empty
  (
		.rempty(rempty),
      .raddr(raddr),
      .rptr(rptr),
		.rq2_wptr(rq2_wptr),
      .rinc(rinc),
		.rclk(rclk),
      .rrst(rrst)
  );
  
  wptr_full #(ASIZE) wptr_full
  (
		.wfull(wfull),
		.waddr(waddr),
      .wptr(wptr),
		.wq2_rptr(wq2_rptr),
      .winc(winc),
		.wclk(wclk),
      .wrst(wrst)
  );

endmodule

module fifomem #(parameter  DATASIZE = 8, ADDRSIZE = 4)
(
   input  logic [DATASIZE-1:0] wdata,
   input  logic [ADDRSIZE-1:0] waddr, raddr,
   input  logic                wclken, wfull, wclk,
	
	output logic [DATASIZE-1:0] rdata
);

    localparam DEPTH = 1<<ADDRSIZE;
	 
    logic [DATASIZE-1:0] mem [0:DEPTH-1];
	 
	 
    assign rdata = mem[raddr];
	 
	 
    always_ff @(posedge wclk)
	 
      if (wclken && !wfull) mem[waddr] <= wdata;

endmodule

module sync_r2w #(parameter ADDRSIZE = 4)
(
   input  logic [ADDRSIZE:0] rptr,
   input  logic              wclk, wrst,
	
	output logic [ADDRSIZE:0] wq2_rptr
);
  
  logic [ADDRSIZE:0] wq1_rptr;
  
  always_ff @(posedge wclk, posedge wrst)
  
      if (wrst) {wq2_rptr,wq1_rptr} <= 0;
    
	 else        {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};

endmodule

module sync_w2r #(parameter ADDRSIZE = 4)
(
   input  logic [ADDRSIZE:0] wptr,
   input  logic              rclk, rrst,
	
	output logic [ADDRSIZE:0] rq2_wptr
);

  logic [ADDRSIZE:0] rq1_wptr;
  
  
  always_ff @(posedge rclk, posedge rrst)
  
      if (rrst) {rq2_wptr,rq1_wptr} <= 0;
    
	 else          {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};

endmodule

module rptr_empty #(parameter ADDRSIZE = 4)
(
   input  logic [ADDRSIZE  :0] rq2_wptr,
   input  logic                rinc, rclk, rrst,
	
	output logic                rempty,
   output logic [ADDRSIZE-1:0] raddr,
   output logic [ADDRSIZE  :0] rptr
);

  logic [ADDRSIZE:0] rbin;
  logic [ADDRSIZE:0] rgraynext, rbinnext;
  
  
  always_ff @(posedge rclk or posedge rrst)
  
      if (rrst) {rbin, rptr} <= 0;
    
	 else        {rbin, rptr} <= {rbinnext, rgraynext};
  
  
  assign raddr     = rbin[ADDRSIZE-1:0];
  assign rbinnext  = rbin + (rinc & ~rempty);
  assign rgraynext = (rbinnext>>1) ^ rbinnext;
  
  
  logic rempty_val;
  
  always_comb
  
	  if (rgraynext == rq2_wptr) rempty_val = 1'd1;
	
	else                         rempty_val = 1'd0;    
  
  
  always_ff @(posedge rclk or posedge rrst)
  
      if (rrst) rempty <= 1'b1;
	 
    else        rempty <= rempty_val;

endmodule

module wptr_full #(parameter ADDRSIZE = 4)
(
   input  logic [ADDRSIZE  :0] wq2_rptr,
   input                       winc, wclk, wrst,
	
	output logic                wfull,
   output logic [ADDRSIZE-1:0] waddr,
   output logic [ADDRSIZE  :0] wptr
);

  logic [ADDRSIZE:0] wbin;
  logic [ADDRSIZE:0] wgraynext, wbinnext;


  always_ff @(posedge wclk or posedge wrst)
  
      if (wrst) {wbin, wptr} <= 0;
	 
    else        {wbin, wptr} <= {wbinnext, wgraynext};


  assign waddr = wbin[ADDRSIZE-1:0];
  assign wbinnext  = wbin + (winc & ~wfull);
  assign wgraynext = (wbinnext>>1) ^ wbinnext;
  
  
  logic wfull_val;
  
  always_comb
  
		  if (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1],wq2_rptr[ADDRSIZE-2:0]}) wfull_val = 1'd1;
		
		else                                                                      wfull_val = 1'd0;
  
  
  always_ff @(posedge wclk or posedge wrst)
  
      if (wrst) wfull  <= 1'b0;
    else        wfull  <= wfull_val;

endmodule