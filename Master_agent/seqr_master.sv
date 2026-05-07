class seqr_m extends uvm_sequencer#(tx);
	`uvm_component_utils(seqr_m)

	function new(string name="seqr_m",uvm_component parent);
		super.new(name,parent);
	endfunction
	
endclass
