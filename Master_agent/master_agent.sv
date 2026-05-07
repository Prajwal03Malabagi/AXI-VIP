class master_agent extends uvm_agent;
	`uvm_component_utils(master_agent)
	conf cf;
	driver_m drv;
	monitor_m mon;
	seqr_m sqr;
	
	function new(string name="master_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(conf)::get(this,"","conf",cf))
			`uvm_error("master_agent","failed")
		mon=monitor_m::type_id::create("mon",this);
		if(cf.is_active)
		begin
			drv=driver_m::type_id::create("drv",this);
			sqr=seqr_m::type_id::create("sqr",this);
		end
	endfunction
	
	function void connect_phase(uvm_phase phase);
		if(cf.is_active)
			drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction
endclass
