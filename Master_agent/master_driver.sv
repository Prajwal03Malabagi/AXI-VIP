class driver_m extends uvm_driver#(tx);
	`uvm_component_utils(driver_m)
	conf cf;
	virtual master_intf.mstr_DRV vif;
	semaphore wac=new(1);
	semaphore wdc=new(1);
	semaphore wrsp=new(1);
	semaphore rac=new(1);
	semaphore rdc=new(1);
	
	semaphore wac_wdc=new();
	semaphore wac_wrsp=new();
	semaphore rac_rdc=new();
		
	tx q1[$],q2[$],q3[$],q4[$],q5[$];
	
	function new(string name="driver_m",uvm_component parent);
		super.new(name,parent);
	endfunction 
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(conf)::get(this,"","conf",cf))
			`uvm_error("driver_m","failed")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif=cf.vif;
	endfunction

	task run_phase(uvm_phase phase);	
	forever begin
		seq_item_port.get_next_item(req);	
		q1.push_back(req);
		q2.push_back(req);
		q3.push_back(req);
		q4.push_back(req);
		q5.push_back(req);
	//	$display("hi hello");
		drive();
	//	$display("hi");
		seq_item_port.item_done;
	//	$display("master driver");
	//	req.print(); 
		end
	endtask
	
	task drive();
		fork
			begin 
				wac.get(1);
				write_addr(q1.pop_front());
				wac.put(1);
				wac_wdc.put(1);
			end
			begin
				wdc.get(1);
				wac_wdc.get(1);
				write_data(q2.pop_front());
				wdc.put(1);
				wac_wrsp.put(1);
			end
			begin
				wrsp.get(1);
				wac_wrsp.get(1);
				write_resp(q3.pop_front());
				wrsp.put(1);
			end
			begin
				rac.get(1);
				read_addr(q4.pop_front());
				rac.put(1);
				rac_rdc.put(1);
			end
			begin
				rdc.get(1);	
				rac_rdc.get(1);
				read_data(q5.pop_front());
				rdc.put(1);
			end
		join_any
//		$display("master driver");

	endtask 
	
	task write_addr(tx req);
		//$display($time,"write address channel");
		//@(vif.mstr_drv);
		vif.mstr_drv.AWVALID<=1'b1;
		vif.mstr_drv.AWID<=req.AWID;
		vif.mstr_drv.AWADDR<=req.AWADDR;
		vif.mstr_drv.AWSIZE<=req.AWSIZE;
		vif.mstr_drv.AWLEN<=req.AWLEN;
		vif.mstr_drv.AWBURST<=req.AWBURST;
		@(vif.mstr_drv);
		wait(vif.mstr_drv.AWREADY)
		vif.mstr_drv.AWVALID<=1'b0;
	
		repeat($urandom_range(1,5))
			@(vif.mstr_drv);
	//	$display($time,"write address channel completed");
	endtask
	
	task write_data(tx req);

		foreach(req.WDATA[i])
		begin
	//	$display($time,"write data channel");
		//	@(vif.mstr_drv);
			vif.mstr_drv.WVALID<=1'b1;
			vif.mstr_drv.WID<=req.WID;
			vif.mstr_drv.WDATA<=req.WDATA[i];
			vif.mstr_drv.WSTRB<=req.WSTRB[i];
			if(i==(req.AWLEN))begin
				req.WLAST<=1'b1;
				vif.mstr_drv.WLAST<=1'b1;end
			else begin
					//req.WLAST<=1'b0;
					vif.mstr_drv.WLAST<=1'b0;
			end
			@(vif.mstr_drv);
			wait(vif.mstr_drv.WREADY==1)
	//		$display($time,"********* after wait for wreAdy ************");
			vif.mstr_drv.WVALID<=1'b0;
		//	$display($time,"********* after delay ************");
			repeat($urandom_range(1,5))
				@(vif.mstr_drv);
		end
		 
	//	$display($time,"write data channel completed");
	endtask

	task write_resp(tx req);
		
		//	$display($time,"write resp");
		//	$display("master- bready=1");
			vif.mstr_drv.BREADY<=1'b1;
		//	$display("master- waiting bvalid");
			@(vif.mstr_drv);
			wait(vif.mstr_drv.BVALID);
			vif.mstr_drv.BREADY<=1'b0;
			repeat($urandom_range(1,5))
				@(vif.mstr_drv);
		//	$display($time,"write resp completed");
	endtask

	task read_addr(tx req);
	//	$display($time,"read address");
		//@(vif.mstr_drv);
		vif.mstr_drv.ARVALID<=1'b1;
		vif.mstr_drv.ARID<=req.ARID;
		vif.mstr_drv.ARADDR<=req.ARADDR;
		vif.mstr_drv.ARSIZE<=req.ARSIZE;
		vif.mstr_drv.ARLEN<=req.ARLEN;
		vif.mstr_drv.ARBURST<=req.ARBURST;
		@(vif.mstr_drv);
		wait(vif.mstr_drv.ARREADY);
		vif.mstr_drv.ARVALID<=1'b0;
	
		repeat($urandom_range(1,5))
			@(vif.mstr_drv);
	//	$display($time,"read address completed");
	endtask
	
	task read_data(tx req);
		
		for(int i=0;i<=req.ARLEN;i++)begin
		//	$display($time,"read data");
			vif.mstr_drv.RREADY<=1'b1;
			@(vif.mstr_drv);
			wait(vif.mstr_drv.RVALID);
			vif.mstr_drv.RREADY<=1'b0;
			repeat($urandom_range(1,5))
			@(vif.mstr_drv);
		end
		
	//	$display($time,"read data completed");
	endtask
	

endclass
