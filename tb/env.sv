class env extends uvm_env;
	`uvm_component_utils(env)
	
	master_agent ag_m;
	slave_agent ag_s;
	scb scb1;
	conf cf;

	function new(string name="env",uvm_component parent);
		super.new(name,parent);
	endfunction
		
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(conf)::get(this,"","conf",cf))
			`uvm_error("env","failed")
		ag_m=master_agent::type_id::create("ag_m",this);
		ag_s=slave_agent::type_id::create("ag_s",this);
		scb1=scb::type_id::create("scb1",this);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		ag_m.mon.port1.connect(scb1.fifo1.analysis_export);
		ag_s.mon.port2.connect(scb1.fifo2.analysis_export);
	endfunction
endclass
