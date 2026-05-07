class monitor extends uvm_monitor;
	`uvm_component_utils(monitor)
		uvm_analysis_port #(tx)port2;
	conf cf;
	tx q1[$],q2[$],q3[$];
	tx xtn;
	virtual master_intf.slave_MON vif;
	semaphore wac=new(1);
	semaphore wdc=new(1);
	semaphore wrsp=new(1);
	semaphore rac=new(1);
	semaphore rdc=new(1);
	
	semaphore wac_wdc=new();
	semaphore wac_wrsp=new();
	semaphore rac_rdc=new();

	function new(string name="monitor",uvm_component parent);
		super.new(name,parent);
		port2=new("port2",this);
	endfunction 
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(conf)::get(this,"","conf",cf))
			`uvm_error("monitor","failed")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif=cf.vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
		xtn=tx::type_id::create("xtn");
		mon();
		end
	//	$display("slave monitor");
	//	xtn.print();
	endtask

	task mon();	
		fork
			begin 
				wac.get(1);
				write_addr();
				wac.put(1);
				wac_wdc.put(1);
			end
			begin
				wdc.get(1);
				wac_wdc.get(1);
				write_data(q1.pop_front());
				wdc.put(1);
				wac_wrsp.put(1);
			end
			begin
				wrsp.get(1);
				wac_wrsp.get(1);
				write_resp(q2.pop_front());
				wrsp.put(1);
			end
			begin
				rac.get(1);
				read_addr();
				rac.put(1);
				rac_rdc.put(1);
			end
			begin
				rdc.get(1);	
				rac_rdc.get(1);
				read_data(q3.pop_front());
				rdc.put(1);
			end
		join
		//$display("slave monitor");
		//xtn.print();
	endtask 	
		

task write_addr();
		@(vif.slave_mon);
		
		wait(vif.slave_mon.AWVALID && vif.slave_mon.AWREADY);
		
		xtn.AWID=vif.slave_mon.AWID;
		xtn.AWADDR=vif.slave_mon.AWADDR;
		xtn.AWSIZE=vif.slave_mon.AWSIZE;
		xtn.AWLEN=vif.slave_mon.AWLEN;
		xtn.AWBURST=vif.slave_mon.AWBURST;
		xtn.AWVALID=vif.slave_mon.AWVALID;
		xtn.AWREADY=vif.slave_mon.AWREADY;
		q1.push_back(xtn);
		port2.write(xtn);
		@(vif.slave_mon);
		
	endtask

	task write_data(tx xtn);
		xtn.WDATA=new[xtn.AWLEN+1];
		xtn.WSTRB=new[xtn.AWLEN+1];
		foreach(xtn.WDATA[i])
		begin
			@(vif.slave_mon);
			wait(vif.slave_mon.WREADY && vif.slave_mon.WVALID);
				xtn.WID=vif.slave_mon.WID;
				xtn.WLAST=vif.slave_mon.WLAST;
				xtn.WSTRB[i]=vif.slave_mon.WSTRB;
				if(xtn.WSTRB[i] == 4'b0001)
					xtn.WDATA[i]=vif.slave_mon.WDATA[7:0];

				else if(xtn.WSTRB[i] == 4'b0010)
					xtn.WDATA[i]=vif.slave_mon.WDATA[15:8];

				else if(xtn.WSTRB[i] == 4'b0100)
					xtn.WDATA[i]=vif.slave_mon.WDATA[23:16];

				else if(xtn.WSTRB[i] == 4'b1000)
					xtn.WDATA[i]=vif.slave_mon.WDATA[31:24];

				else if(xtn.WSTRB[i] == 4'b0011)
					xtn.WDATA[i]=vif.slave_mon.WDATA[15:0];

				else if(xtn.WSTRB[i] == 4'b1100)
					xtn.WDATA[i]=vif.slave_mon.WDATA[31:24];

				else if(xtn.WSTRB[i] == 4'b1111)
					xtn.WDATA[i]=vif.slave_mon.WDATA[31:0];
				else
					xtn.WDATA[i]=0;
				xtn.WVALID=vif.slave_mon.WVALID;
				xtn.WREADY=vif.slave_mon.WREADY;
			q2.push_back(xtn);
			port2.write(xtn);
			@(vif.slave_mon);
		end	 
	endtask
	
	task write_resp(tx xtn);
		@(vif.slave_mon);
		wait(vif.slave_mon.BREADY && vif.slave_mon.BVALID);
		
		xtn.BID=vif.slave_mon.BID;
		xtn.BRESP=vif.slave_mon.BRESP;
	xtn.BREADY=vif.slave_mon.BREADY;
		xtn.BVALID=vif.slave_mon.BVALID;
		port2.write(xtn);
		@(vif.slave_mon);
	endtask

	task read_addr();
		@(vif.slave_mon);
		wait(vif.slave_mon.ARVALID && vif.slave_mon.ARREADY);
		xtn.ARID=vif.slave_mon.ARID;
		xtn.ARADDR=vif.slave_mon.ARADDR;
		xtn.ARSIZE=vif.slave_mon.ARSIZE;
		xtn.ARLEN=vif.slave_mon.ARLEN;
		xtn.ARBURST=vif.slave_mon.ARBURST;
		xtn.ARVALID=vif.slave_mon.ARVALID;
		xtn.ARREADY=vif.slave_mon.ARREADY;
		q3.push_back(xtn);
		port2.write(xtn);
		@(vif.slave_mon);
		
	endtask
	
	task read_data(tx xtn);
		xtn.RDATA=new[xtn.ARLEN+1];
		xtn.RRESP=new[xtn.ARLEN+1];
		for(int i=0;i<=xtn.ARLEN;i++)begin
			@(vif.slave_mon);
			wait(vif.slave_mon.RREADY && vif.slave_mon.RVALID);
			
			xtn.ARID=vif.slave_mon.RID;
			xtn.RDATA[i]=vif.slave_mon.RDATA;
			xtn.RRESP[i]=vif.slave_mon.RRESP;
			xtn.RLAST=vif.slave_mon.RLAST;
			xtn.RVALID=vif.slave_mon.RVALID;
			xtn.RREADY=vif.slave_mon.RREADY;
			port2.write(xtn);
			@(vif.slave_mon);
		end
				
	endtask

endclass
