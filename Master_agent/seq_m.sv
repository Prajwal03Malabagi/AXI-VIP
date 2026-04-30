class seq_m extends uvm_sequence#(tx);
        `uvm_object_utils(seq_m)

        function new(string name="seq_m");
                super.new(name);
        endfunction
endclass

class seq_fixed extends seq_m;
        `uvm_object_utils(seq_fixed)

        function new(string name="seq_fixed");
                super.new(name);
        endfunction

        task body();
                req=tx::type_id::create("req");
                repeat(5) begin
                        start_item(req);
                        req.randomize() with{req.AWBURST==2'b00;req.AWLEN inside{[0:16'h5]};req.AWSIZE==2'b0;req.AWADDR inside{[32'h0:32'h0000ffff]};foreach(req.WDATA[i])req.WDATA[i] inside{[32'h0:32'h0000ffff]};req.ARADDR inside{[32'h0:32'h0000ffff]};req.ARLEN inside{[0:16'h5]};req.ARBURST==2'b00;req.ARSIZE==2'b0;};
                        finish_item(req);
                end
        endtask
endclass

class seq_incr extends seq_m;
        `uvm_object_utils(seq_incr)

        function new(string name="seq_incr");
                super.new(name);
        endfunction

        task body();
                req=tx::type_id::create("req");
                repeat(5) begin
                        start_item(req);
                        req.randomize() with{req.AWBURST==2'b01;req.AWLEN inside{[16'h5:16'ha]};req.AWSIZE==2'b1;req.AWADDR inside{[32'h0000ffff:32'hffff0000]};foreach(req.WDATA[i])req.WDATA[i] inside{[32'h000000ff:32'hffffff0000]};req.ARADDR inside{[32'h0000ffff:32'hffff0000]};req.ARLEN inside{[16'h5:16'ha]};req.ARBURST==2'b01;req.ARSIZE==2'b1;};
                        finish_item(req);
                end
        endtask
endclass

class seq_wrap extends seq_m;
        `uvm_object_utils(seq_wrap)

        function new(string name="seq_wrap");
                super.new(name);
        endfunction

        task body();
                req=tx::type_id::create("req");
                repeat(5) begin
                        start_item(req);
                        req.randomize() with{req.AWBURST==2'b10;req.AWLEN inside{[16'ha:16'hf]};req.AWSIZE==2'b10;req.AWADDR inside{[32'hffff0000:32'hffffffff]};foreach(req.WDATA[i])req.WDATA[i] inside{[32'hffff0000:32'hffffffff]};req.ARBURST==2'b10;req.ARLEN inside{[16'ha:16'hf]};ARSIZE==2'b10;req.ARADDR inside{[32'hffff0000:32'hffffffff]};};
                        finish_item(req);
                end
        endtask
endclass

