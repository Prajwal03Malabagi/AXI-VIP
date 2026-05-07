module top;
	import pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	bit clk;
	master_intf vif(clk);
	always #5 clk=~clk;
	
	initial begin
		clk=0;
		`ifdef VCS
		$fsdbDumpvars(0,top);
		`endif 
		uvm_config_db#(virtual master_intf)::set(null,"*","vif",vif);
		run_test();
	end
endmodule
