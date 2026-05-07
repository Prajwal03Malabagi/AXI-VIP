class test extends uvm_test;
	`uvm_component_utils(test)
	env e;
	//seq_s sq_s;
	seq_m sq_m;
	conf cf;
	function new(string name="test",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		cf=conf::type_id::create("cf");
		if(!uvm_config_db#(virtual master_intf)::get(this,"","vif",cf.vif))
			`uvm_error("test","failed")
		e=env::type_id::create("e",this);
		sq_m=seq_m::type_id::create("sq_m");
		uvm_config_db#(conf)::set(this,"*","conf",cf);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction 
endclass

class test_fixed extends test;
		`uvm_component_utils(test_fixed)
		seq_fixed sf;
	function new(string name="test_fixed",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sf=seq_fixed::type_id::create("sf");
	endfunction

	task run_phase(uvm_phase phase);
				super.run_phase(phase);
		phase.raise_objection(this);
		sf.start(e.ag_m.sqr);
	#100;
		phase.drop_objection(this);
	endtask

endclass

class test_incr extends test;
		`uvm_component_utils(test_incr)
		seq_incr si;
	function new(string name="test_incr",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		si=seq_incr::type_id::create("si");
	endfunction

	task run_phase(uvm_phase phase);
				super.run_phase(phase);
		phase.raise_objection(this);
		si.start(e.ag_m.sqr);
	#10000000;
		phase.drop_objection(this);
	endtask

endclass

class test_wrap extends test;
		`uvm_component_utils(test_wrap)
		seq_wrap sw;
	function new(string name="test_wrap",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sw=seq_wrap::type_id::create("sw");
	endfunction

	task run_phase(uvm_phase phase);
				super.run_phase(phase);
		phase.raise_objection(this);
		sw.start(e.ag_m.sqr);
	#10000000;
		phase.drop_objection(this);
	endtask

endclass

