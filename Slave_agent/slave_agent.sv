class slave_agent extends uvm_agent;
	`uvm_component_utils(slave_agent)
	conf cf;
	driver drv;
	monitor mon;
	seqr_s sqr;
	
	function new(string name="slave_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(conf)::get(this,"","conf",cf))
			`uvm_error("slave_agent","failed")
		mon=monitor::type_id::create("mon",this);
		if(cf.is_active)
		begin
			drv=driver::type_id::create("drv",this);
			sqr=seqr_s::type_id::create("sqr",this);
		end
	endfunction
	
	function void connect_phase(uvm_phase phase);
		drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction
endclass
