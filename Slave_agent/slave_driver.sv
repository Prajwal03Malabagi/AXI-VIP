class driver extends uvm_driver#(tx);
	`uvm_component_utils(driver)
	conf cf;
	tx xtn;
	virtual master_intf.slave_DRV vif;
	semaphore wac=new(1);
	semaphore wdc=new(1);
	semaphore wrsp=new(1);
	semaphore rac=new(1);
	semaphore rdc=new(1);
	
	semaphore wac_wdc=new();
	semaphore wac_wrsp=new();
	semaphore rac_rdc=new();
	tx q1[$],q2[$],q3[$],q4[$],q5[$];

	function new(string name="driver",uvm_component parent);
		super.new(name,parent);
	endfunction 
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(conf)::get(this,"","conf",cf))
			`uvm_error("driver","failed")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif=cf.vif;
	endfunction

	task run_phase(uvm_phase phase);		
		forever begin
		xtn=tx::type_id::create("xtn");
//		xtn=tx::type_id::create("xtn");
		q1.push_back(xtn);
		q2.push_back(xtn);
		q3.push_back(xtn);
		q4.push_back(xtn);
		
		driv();
	end
					//$display("master driver");
			//xtn.print();
	endtask
	
	task driv();
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
	//		$display("slave driver");
	//	xtn.print(uvm_default_table_printer);
	endtask 

	task write_addr(tx xtn);
	//	$display($time,"slave:-write address channel");
		vif.slave_drv.AWREADY<=1'b1;
		
		@(vif.slave_drv);
		wait(vif.slave_drv.AWVALID)
		xtn.AWID=vif.slave_drv.AWID;
		xtn.AWADDR=vif.slave_drv.AWADDR;
		xtn.AWSIZE=vif.slave_drv.AWSIZE;
		xtn.AWLEN=vif.slave_drv.AWLEN;
		xtn.AWBURST=vif.slave_drv.AWBURST;
	//	$display("-===1111 AwLEN=%0d,AwLEN0=%0d",xtn.AWLEN,vif.slave_drv.AWLEN);
		vif.slave_drv.AWREADY<=1'b0;
		
		repeat($urandom_range(1,5))
			@(vif.slave_drv);
	//	$display($time,"slave:-write address channel completed");
	endtask
		
	task write_data(tx xtn);
		
		for(int i=0;i<=xtn.AWLEN;i++)
   // foreach(xtn.WDATA[i])
		begin
	//		$display($time,"slave:-write data channel");
			vif.slave_drv.WREADY<=1'b1;
			@(vif.slave_drv);
			wait(vif.slave_drv.WVALID)
			vif.slave_drv.WREADY<=1'b0;
			repeat($urandom_range(1,5))
				@(vif.slave_drv);
		end
		
	//	$display($time,"slave:-write data channel completed");
	endtask
	
	task write_resp(tx xtn);

	//		$display($time,"slave:-write resp");
	//		$display("slave- bvalid=1");
			vif.slave_drv.BVALID<=1'b1;
			vif.slave_drv.BID<=xtn.AWID;
			vif.slave_drv.BRESP<=2'b00;
			@(vif.slave_drv);
		//	$display("slave- waiting bready");
			wait(vif.slave_drv.BREADY);
		//			$display("slave- bvalid=0");
			vif.slave_drv.BVALID<=1'b0;
			repeat($urandom_range(1,5))
				@(vif.slave_drv);
	
	//			$display($time,"slave:-write resp completed");
	endtask

	task read_addr(tx xtn1);
		//	$display ($time,"slave:-read address");
			vif.slave_drv.ARREADY<=1'b1;
			
			@(vif.slave_drv);
			wait(vif.slave_drv.ARVALID)
			xtn.ARID=vif.slave_drv.ARID;
			xtn.ARADDR=vif.slave_drv.ARADDR;
			xtn.ARSIZE=vif.slave_drv.ARSIZE;
			xtn.ARLEN=vif.slave_drv.ARLEN;
		//		$display("-===1111 ARLEN=%0d,ARLEN0=%0d",xtn.ARLEN,vif.slave_drv.ARLEN);
			xtn.ARBURST=vif.slave_drv.ARBURST;
			vif.slave_drv.ARREADY<=1'b0;
			repeat($urandom_range(1,5))
				@(vif.slave_drv);
	//				$display($time,"slave:-read address completed");
			q5.push_back(xtn);
	endtask

	task read_data(tx xtn);
		xtn.RDATA=new[xtn.ARLEN+1];
//		$display("-===00000 ARLEN=%0d",xtn.ARLEN);
		for(int i=0;i<=xtn.ARLEN;i++)begin
	//			$display($time,"slave:-read data");
			vif.slave_drv.RVALID<=1;
			vif.slave_drv.RID<=xtn.ARID;
			xtn.RDATA[i] =$urandom;
			vif.slave_drv.RDATA<=xtn.RDATA[i];
			vif.slave_drv.RRESP<=2'b00;
			if(i==(xtn.ARLEN))
				vif.slave_drv.RLAST<=1'b1;
      else
				vif.slave_drv.RLAST<=1'b0;
			@(vif.slave_drv);
			wait(vif.slave_drv.RREADY)
			vif.slave_drv.RVALID<=1'b0;
			repeat($urandom_range(1,5))
				@(vif.slave_drv);
		end
		
		//		$display($time,"slave:-read data completed");
	endtask			
endclass
