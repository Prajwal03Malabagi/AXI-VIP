class scb extends uvm_scoreboard;
	`uvm_component_utils(scb)
	uvm_tlm_analysis_fifo #(tx)fifo1;
	uvm_tlm_analysis_fifo #(tx)fifo2;
	tx xtn1,xtn2;
	tx wr,rd;
	bit[3:0]rresp;
	bit[31:0]Data;
	bit[31:0]RData;
	bit[3:0]strb;
covergroup master_cov;
		araddr:coverpoint xtn1.ARADDR{bins low={[32'h0000:32'h00ffff]};
																	bins mid={[32'h00ffff:32'hffff0000]};
																	bins hid={[32'hffff0000:32'hffffffff]};}
		arlen :coverpoint xtn1.ARLEN{bins low={[16'h0:16'h5]};
																	bins mid={[16'h5:16'ha]};
																	bins high={[16'ha:16'h10]};}
		arsize:coverpoint xtn1.ARSIZE{bins size[]={0,1,2};}
		arburst:coverpoint xtn1.ARBURST{bins burst[]={0,1,2};}

		awaddr:coverpoint xtn1.AWADDR{bins low={[32'h0000:32'h00ffff]};
																	bins mid={[32'hfffffff:32'h0ffff0000]};
																	bins hid={[32'hffff0000:32'hffffffff]};}
		awlen :coverpoint xtn1.AWLEN{bins low={[16'h0:16'h5]};
																	bins mid={[16'h5:16'ha]};
																	bins high={[16'ha:16'h10]};}
		awsize:coverpoint xtn1.AWSIZE{bins size[]={0,1,2};}
		awburst:coverpoint xtn1.AWBURST{bins burst[]={0,1,2};}
		wdat:coverpoint Data{bins low={[32'h0000:32'h00ffffff]};
																	bins mid={[32'h00ffffff:32'hffffffff]};
																	bins hid={[32'hffff0000:32'hffffffff]};}
		wstrb:coverpoint strb{bins low={1,2,4,8,3,12,15};}
	endgroup
covergroup slave_cov;
	resp:coverpoint xtn2.BRESP{bins Resp={0};}
	rr:coverpoint rresp{bins RResp={0};}
	rdata:coverpoint RData{bins low={[32'h0000:32'h00ffff]};
																	bins mid={[32'h00ffff:32'hffff0000]};
																	bins hid={[32'hffff0000:32'hffffffff]};}
endgroup
	
	function new(string name="scb",uvm_component parent);
			super.new(name,parent);
			fifo1=new("fifo1",this);
			fifo2=new("fifo2",this);
			master_cov=new;
			slave_cov=new();
	endfunction

	task run_phase(uvm_phase phase);
	forever 
		begin
	//	xtn1=tx::type_id::create("xtn1");
	//	xtn2=tx::type_id::create("xtn2");

		fifo1.get(xtn1);
		fifo2.get(xtn2);
	//	$display("xtn1");
	//	xtn1.print();
	//	$display("xtn2");
	//	xtn2.print();

		foreach(xtn2.RDATA[i])
			begin
				rresp=xtn2.RRESP[i];
				RData=xtn2.RDATA[i];
			slave_cov.sample();
			end
		foreach(xtn1.WDATA[i])
			begin
				Data=xtn1.WDATA[i];
				strb=xtn1.WSTRB[i];
				master_cov.sample();
			end

		if(xtn2.compare(xtn1))
			$display("--------------------******************************Pass");
		else 
			$display("--------------------******************************fail");
		end
	endtask

endclass
