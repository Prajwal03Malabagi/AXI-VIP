class conf extends uvm_object;
	`uvm_object_utils(conf)
	int num=1;
	virtual master_intf vif;
	uvm_active_passive_enum is_active=UVM_ACTIVE;

	function new(string name="conf");
		super.new(name);
	endfunction
endclass
