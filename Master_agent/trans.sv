class tx extends uvm_sequence_item;
	`uvm_object_utils(tx)
	function new(string name="tx");
		super.new(name);
	endfunction

	rand bit ARESET;
//write address channel signals 
	rand bit [3:0]AWID;
	rand bit [31:0]AWADDR;
	rand bit [3:0]AWLEN;
	rand bit [1:0]AWSIZE;
	rand bit [1:0]AWBURST;
	rand bit AWVALID;
	bit AWREADY;
	
	bit [31:0]ADDR[];

// write data channel signal
	rand bit [3:0]WID;
	rand bit [31:0]WDATA[];
	rand bit [3:0]WSTRB[];
	rand bit WLAST;
	rand bit WVALID;
	bit WREADY;

//write response channel signal
	rand bit BREADY;
	bit BVALID;
	bit [3:0]BID;
	bit [1:0]BRESP;
//read address channel signals
	rand bit [3:0]ARID;
	rand bit [31:0]ARADDR;
	rand bit [3:0]ARLEN;
	rand bit [1:0]ARSIZE;
	rand bit [1:0]ARBURST;
	rand bit ARVALID;
	bit ARREADY;

//read data channel signal
	bit [3:0]RID;
	bit [31:0]RDATA[];
	bit [3:0]RRESP[];
	bit RLAST;
	bit RVALID;
	rand bit RREADY;
	//internal signal
	bit [31:0] Start_Address;
	bit [2:0] Number_Bytes;
	bit [3:0] Burst_Length;
	bit [31:0] Aligned_Address;
	bit [31:0] Wrap_Boundary;
	bit [31:0] upper_Boundary;
		bit [31:0] Wrap_Boundaryw;
	bit [31:0] upper_Boundaryw;
	int data_bus_bytes;

	constraint wdata{WDATA.size==(AWLEN+1);} // no of write data
	//constraint rdata{RDATA.size==(ARLEN+1);} // no of write data

	constraint wburst_type{AWBURST inside{0,1,2};if(AWBURST==2'b10) AWLEN inside{1,3,7,15};} //burst type range
	constraint rburst_type{ARBURST inside{0,1,2};if(ARBURST==2'b10) ARLEN inside{1,3,7,15};} //burst type range
	constraint write_id{AWID==WID;WID==BID;}//ID
	constraint read_id{ARID==RID;}//ID
	constraint wsize{AWSIZE inside{0,1,2};}//size
	constraint rsize{ARSIZE inside{0,1,2};}
	constraint waddr{if(AWBURST==2'b00 || AWBURST==2'b10) 
											if(AWSIZE==2'b01) AWADDR%2==0;
											else if(AWSIZE==2'b10) AWADDR%4==0;}
	constraint raddr{if(ARBURST==2'b00 || ARBURST==2'b10) 
											if(ARSIZE==2'b01) ARADDR%2==0;
											else if(ARSIZE==2'b10) ARADDR%4==0;}
	constraint mem_size_write{(2**AWSIZE)*(AWLEN+1)<=4096;}
	constraint mem_size_read{(2**ARSIZE)*(ARLEN+1)<=4096;}

	function void post_randomize();
	
		Start_Address=AWADDR;
		Number_Bytes=2**AWSIZE;
		Aligned_Address = (int'(Start_Address/Number_Bytes))*Number_Bytes;			
		data_bus_bytes=4;
		Burst_Length = AWLEN + 1;
		WSTRB=new[AWLEN+1];
		ADDR=new[AWLEN+1];
		addr_write();
		strb();
		addr_read();
	endfunction

	function void addr_write();
		Wrap_Boundaryw = (int'(Start_Address / (Number_Bytes * Burst_Length)))* (Number_Bytes * Burst_Length);
		upper_Boundaryw=Wrap_Boundaryw + (Number_Bytes * Burst_Length);
		if(AWBURST==2'b00)
			for(int i=0;i<Burst_Length;i++)
				ADDR[i]=Aligned_Address;
		else if(AWBURST==2'b01) begin
			ADDR[0]=Start_Address;
			for(int i=1;i<Burst_Length;i++)
				ADDR[i]=ADDR[i-1]+Number_Bytes ;
			end
		else if(AWBURST==2'b10) begin
			ADDR[0]=Aligned_Address;
			for(int i=1;i<Burst_Length ;i++)begin 
				if(ADDR[i]<upper_Boundaryw)
					ADDR[i]=ADDR[i-1]+Number_Bytes;
				else
					ADDR[i]=Wrap_Boundaryw;
				end
			end
	endfunction

	function void strb();
		
		int lower_byte_lane,upper_byte_lane;
		int lower_byte_lane_0=Start_Address-((int'(Start_Address/data_bus_bytes))*data_bus_bytes);
		int upper_byte_lane_0=(Aligned_Address+(Number_Bytes-1))-((int'(Start_Address/data_bus_bytes))*data_bus_bytes);		
			for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
			begin
				WSTRB[0][j]=1;
			end
	
		for(int i=1;i<(AWLEN+1);i++)
		begin
			lower_byte_lane=ADDR[i]-(int'(ADDR[i]/data_bus_bytes))*data_bus_bytes;
			upper_byte_lane=lower_byte_lane+Number_Bytes-1;
			for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
				WSTRB[i][j]=1;
		end
	endfunction
	
	function void addr_read();
		Start_Address=ARADDR;
		Number_Bytes = 2**ARSIZE;
		Burst_Length = ARLEN + 1;
		ADDR=new[ARLEN+1];
		Aligned_Address = (int'(Start_Address/Number_Bytes))*Number_Bytes;
		Wrap_Boundary = ((int'(Start_Address / (Number_Bytes * Burst_Length)))* (Number_Bytes * Burst_Length));
		upper_Boundary=Wrap_Boundary + (Number_Bytes * Burst_Length);
		if(ARBURST==2'b00)
			for(int i=0;i<Burst_Length;i++)
				ADDR[i]=Aligned_Address;
		else if(ARBURST==2'b01) begin
			ADDR[0]=Start_Address;
			for(int i=1;i<Burst_Length;i++)
				ADDR[i]=ADDR[i-1]+Number_Bytes ;
			end
		else if(ARBURST==2'b10) begin
			ADDR[0]=Aligned_Address;
			for(int i=1;i<Burst_Length ;i++)begin 
				if(ADDR[i]<upper_Boundary)
					ADDR[i]=ADDR[i-1]+Number_Bytes;
				else
					ADDR[i]=Wrap_Boundary;
				end
			end
	endfunction

	function void do_print (uvm_printer printer);
super.do_print(printer);

//write address channel
printer.print_field( "AWID", AWID,04,UVM_DEC);
printer.print_field( "AWADDR", AWADDR,32,UVM_HEX);
printer.print_field( "AWLEN", AWLEN,04,UVM_DEC);
printer.print_field( "AWSIZE", AWSIZE,03,UVM_DEC);
printer.print_field( "AWBURST", AWBURST,02,UVM_DEC);
printer.print_field( "AWVALID", AWVALID,01,UVM_DEC);
printer.print_field( "AWREADY", AWREADY,01,UVM_DEC);


//write data channel
printer.print_field( "WID", WID,04,UVM_DEC);
for(int i=0;i<AWLEN+1;i++)
begin
	printer.print_field( "WDATA", WDATA[i],32 ,UVM_HEX);
	printer.print_field( "WSTRB", WSTRB[i],4,UVM_BIN);
	printer.print_field( "WLAST", WLAST,1,UVM_DEC);
	printer.print_field( "WVALID", WVALID,01,UVM_DEC);
	printer.print_field( "WREADY", WREADY,01,UVM_DEC);

end
//Write Response Channel
printer.print_field( "BID", BID,04,UVM_DEC);
printer.print_field( "BRESP", BRESP,02,UVM_DEC);
printer.print_field( "BVALID", BVALID,01,UVM_DEC);
printer.print_field( "BREADY", BREADY,01,UVM_DEC);



//read address channel
printer.print_field( "ARID", ARID,04,UVM_DEC);
printer.print_field( "ARADDR", ARADDR,32,UVM_HEX);
printer.print_field( "ARLEN", ARLEN,08,UVM_DEC);
printer.print_field( "ARSIZE", ARSIZE,03,UVM_DEC);
printer.print_field( "ARBURST", ARBURST,02,UVM_DEC);
printer.print_field( "ARVALID", ARVALID,01,UVM_DEC);
printer.print_field( "ARREADY", ARREADY,01,UVM_DEC);


//read data channel
printer.print_field( "RID", RID,04,UVM_DEC);
foreach( RDATA[i])
begin
	printer.print_field( "RDATA", RDATA[i],32,UVM_HEX);
	printer.print_field( "RRESP", RRESP[i],02,UVM_DEC);
	printer.print_field( "RVALID", RVALID,01,UVM_DEC);
printer.print_field( "RREADY", RREADY,01,UVM_DEC);

end
endfunction

	function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		tx rhs_;

		if(!$cast(rhs_, rhs))
			`uvm_fatal("In Compare","Casting is FAIL")

		return 
			//super.do_compare(tx1, comparer) &&
			this.AWID==rhs_.AWID &&
			this.AWADDR==rhs_.AWADDR &&
			this.AWLEN==rhs_.AWLEN &&
			this.AWSIZE==rhs_.AWSIZE &&
			this.AWBURST==rhs_.AWBURST &&

			this.WID==rhs_.WID &&
			this.WDATA==rhs_.WDATA &&
			this.WSTRB==rhs_.WSTRB &&
			this.WLAST==rhs_.WLAST &&

			this.BID==rhs_.BID &&
			this.BRESP==rhs_.BRESP &&

			this.ARID==rhs_.ARID &&
			this.ARADDR==rhs_.ARADDR &&
			this.ARLEN==rhs_.ARLEN &&
			this.ARSIZE==rhs_.ARSIZE &&
			this.ARBURST==rhs_.ARBURST &&

			this.RID==rhs_.RID &&
			this.RDATA==rhs_.RDATA &&
			this.RRESP==rhs_.RRESP &&
			this.RLAST==rhs_.RLAST;
	endfunction
	
endclass
