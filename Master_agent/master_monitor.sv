class monitor_m extends uvm_monitor;
	`uvm_component_utils(monitor_m)
	uvm_analysis_port #(tx)port1;
	conf cf;
	tx q1[$],q2[$],q3[$];
	tx xtn;
	virtual master_intf vif;
	semaphore wac=new(1);
	semaphore wdc=new(1);
	semaphore wrsp=new(1);
	semaphore rac=new(1);
	semaphore rdc=new(1);
	
	semaphore wac_wdc=new();
	semaphore wac_wrsp=new();
	semaphore rac_rdc=new();

	
	function new(string name="monitor_m",uvm_component parent);
		super.new(name,parent);
		port1=new("port1",this);
	endfunction 

	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(conf)::get(this,"","conf",cf))
			`uvm_error("monitor_m","failed")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif=cf.vif;
	endfunction
		
	task run_phase(uvm_phase phase);
		forever begin
		xtn=tx::type_id::create("xtn");
		mon();
		end
	//	$display("master monitor");
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
	//	$display("master monitor");
	//	xtn.print();
		
	endtask 	
		

task write_addr();
		@(vif.mstr_mon);
		
		wait(vif.mstr_mon.AWVALID && vif.mstr_mon.AWREADY);
		
		xtn.AWID=vif.mstr_mon.AWID;
		xtn.AWADDR=vif.mstr_mon.AWADDR;
		xtn.AWSIZE=vif.mstr_mon.AWSIZE;
		xtn.AWLEN=vif.mstr_mon.AWLEN;
		xtn.AWBURST=vif.mstr_mon.AWBURST;
		xtn.AWVALID=vif.mstr_mon.AWVALID;
		xtn.AWREADY=vif.mstr_mon.AWREADY;
		q1.push_back(xtn);
		port1.write(xtn);
		@(vif.mstr_mon);
		
	endtask

	task write_data(tx xtn);
		xtn.WDATA=new[xtn.AWLEN+1];
		xtn.WSTRB=new[xtn.AWLEN+1];
		foreach(xtn.WDATA[i])
		begin
	//		$display("monito432188888888888888888888");
	//	$display($time,"wvalid=%0d",vif.mstr_mon.WVALID);
	//	$display($time,"wready=%0d",vif.mstr_mon.WREADY);
			@(vif.mstr_mon);
			wait(vif.mstr_mon.WVALID && vif.mstr_mon.WREADY);
	//			$display("monito43211111111111111");
			
			xtn.WID=vif.mstr_mon.WID;
			xtn.WSTRB[i]=vif.mstr_mon.WSTRB;
			if(xtn.WSTRB[i]==4'b0001)
				xtn.WDATA[i]={vif.mstr_mon.WDATA[7:0]};
			else if(xtn.WSTRB[i]==4'b0010)
				xtn.WDATA[i]={vif.mstr_mon.WDATA[15:8]};
			else if(xtn.WSTRB[i]==4'b0100)
				xtn.WDATA[i]={vif.mstr_mon.WDATA[23:16]};
			else if(xtn.WSTRB[i]==4'b1000)
				xtn.WDATA[i]={vif.mstr_mon.WDATA[31:24]};
			else if(xtn.WSTRB[i]==4'b0011)
				xtn.WDATA[i]={vif.mstr_mon.WDATA[15:0]};
			else if(xtn.WSTRB[i]==4'b1100)
				xtn.WDATA[i]={vif.mstr_mon.WDATA[31:16]};
			else if(xtn.WSTRB[i]==4'b1111)
				xtn.WDATA[i]={vif.mstr_mon.WDATA[31:0]};
		//	$display("WSTRB[%0d]=%0d,WDATA[%0d]=%0d",i,xtn.WSTRB[i],i,xtn.WDATA[i]);
				xtn.WLAST=vif.mstr_mon.WLAST;
				xtn.WVALID=vif.mstr_mon.WVALID;
			xtn.WREADY=vif.mstr_mon.WREADY;
			q2.push_back(xtn);
			port1.write(xtn);
			@(vif.mstr_mon);
			
		end	 
				
	endtask
	
	task write_resp(tx xtn);
	@(vif.mstr_mon);
		wait(vif.mstr_mon.BREADY && vif.mstr_mon.BVALID);
		
		xtn.BRESP=vif.mstr_mon.BRESP;
		xtn.BID=vif.mstr_mon.BID;
		xtn.BREADY=vif.mstr_mon.BREADY;
		xtn.BVALID=vif.mstr_mon.BVALID;
		port1.write(xtn);
		@(vif.mstr_mon);
	endtask

	task read_addr();
		@(vif.mstr_mon);
		wait(vif.mstr_mon.ARVALID && vif.mstr_mon.ARREADY);
		xtn.ARID=vif.mstr_mon.ARID;
		xtn.ARADDR=vif.mstr_mon.ARADDR;
		xtn.ARSIZE=vif.mstr_mon.ARSIZE;
		xtn.ARLEN=vif.mstr_mon.ARLEN;
		xtn.ARBURST=vif.mstr_mon.ARBURST;
		xtn.ARVALID=vif.mstr_mon.ARVALID;
		xtn.ARREADY=vif.mstr_mon.ARREADY;
		q3.push_back(xtn);
		port1.write(xtn);
		@(vif.mstr_mon);
		
	endtask
	
	task read_data(tx xtn);
		xtn.RDATA=new[xtn.ARLEN+1];
		xtn.RRESP=new[xtn.ARLEN+1];
		for(int i=0;i<=xtn.ARLEN;i++)begin
			@(vif.mstr_mon);
			wait(vif.mstr_mon.RREADY && vif.mstr_mon.RVALID);
			xtn.RID=vif.mstr_mon.RID;
			xtn.RDATA[i]=vif.mstr_mon.RDATA;
			xtn.RRESP[i]=vif.mstr_mon.RRESP;
			xtn.RLAST=vif.mstr_mon.RLAST;
			xtn.RVALID=vif.mstr_mon.RVALID;
			xtn.RREADY=vif.mstr_mon.RREADY;
			port1.write(xtn);
			@(vif.mstr_mon);
		end
		
	endtask
	
endclass
