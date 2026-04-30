interface master_intf(input bit clk);
        bit ARESET;
//write address channel signals 
        bit [3:0]AWID;
        bit [31:0]AWADDR;
        bit [3:0]AWLEN;
        bit [2:0]AWSIZE;
        bit [1:0]AWBURST;
        bit AWVALID;
        bit AWREADY;

// write data channel signal
        bit [3:0]WID;
        bit [31:0]WDATA;
        bit [3:0]WSTRB;
        bit WLAST;
        bit WVALID;
        bit WREADY;

//write response channel signal
        bit BREADY;
        bit BVALID;
        bit [3:0]BID;
        bit BRESP;
//read address channel signals
        bit [3:0]ARID;
        bit [31:0]ARADDR;
        bit [3:0]ARLEN;
        bit [2:0]ARSIZE;
        bit [1:0]ARBURST;
        bit ARVALID;
        bit ARREADY;

//read data channel signal
        bit [3:0]RID;
        bit [31:0]RDATA;
        bit [3:0]RRESP;
        bit RLAST;
        bit RREADY;
        bit RVALID;


        clocking mstr_drv@(posedge clk);
                default input #1 output #1;
                //read address channel
                output ARID,ARADDR,ARLEN,ARBURST,ARVALID,ARSIZE,ARESET;
                input ARREADY;
                //read data channel
                output RREADY;
                input RVALID,RLAST,RID,RDATA,RRESP;
                //write address channel
                output AWID,AWADDR,AWLEN,AWBURST,AWVALID,AWSIZE;
                input AWREADY;
                //write data channel
                output WID,WDATA,WSTRB,WLAST,WVALID;
                input WREADY;
                //write response channel
                output BREADY;
                input BID,BVALID,BRESP;
        endclocking

        clocking mstr_mon@(posedge clk);
                default input #1 output #1;
                //read address channel
                input ARID,ARADDR,ARLEN,ARBURST,ARVALID,ARSIZE;
                input ARREADY;
                //read data channel
                input RREADY;
                input RID,RDATA,RRESP,RLAST,RVALID;
                //write address channel
                input AWID,AWADDR,AWLEN,AWBURST,AWVALID,AWSIZE;
                input AWREADY;
                //write data channel
                input WID,WDATA,WSTRB,WLAST,WVALID;
                input WREADY;
                //write response channel
                input BREADY;
                input BID,BVALID,BRESP;
        endclocking
        clocking slave_drv@(posedge clk);
                default input #1 output #1;
                //read address channel
                input ARID,ARADDR,ARLEN,ARBURST,ARVALID,ARSIZE;
                output ARREADY;
                //read data channel
                input RREADY;
                output RID,RDATA,RRESP,RLAST,RVALID;
                //write address channel
                input AWID,AWADDR,AWLEN,AWBURST,AWVALID,AWSIZE;
                output AWREADY;
                //write data channel
                input WID,WDATA,WSTRB,WLAST,WVALID;
                output WREADY;
                //write response channel
                input BREADY;
                output BID,BVALID,BRESP;
        endclocking

        clocking slave_mon@(posedge clk);
                default input #1 output #1;
                //read address channel
                input ARID,ARADDR,ARLEN,ARBURST,ARVALID,ARSIZE;
                input ARREADY;
                //read data channel
                input RREADY;
                input RID,RDATA,RRESP,RLAST,RVALID;
                //write address channel
                input AWID,AWADDR,AWLEN,AWBURST,AWVALID,AWSIZE;
                input AWREADY;
                //write data channel
                input WID,WDATA,WSTRB,WLAST,WVALID;
                input WREADY;
                //write response channel
                input BREADY;
                input BID,BVALID,BRESP;
        endclocking
        
        modport mstr_DRV(clocking mstr_drv);
        modport mstr_MON(clocking mstr_mon);
        modport slave_DRV(clocking slave_drv);
        modport slave_MON(clocking slave_mon);
        //assertion for handshaking
        property wa_hs;
                @(posedge clk)(AWVALID && AWREADY)|=>!AWVALID && !AWREADY;
        endproperty
        p1:assert property(wa_hs)
                $display("wa_hs,write address channel handshaking is perfect");
        else
                $display("wa_hs,failed");

        property wd_hs;
                @(posedge clk)(WVALID && WREADY)|=>!WVALID && !WREADY;
        endproperty
        p2:assert property(wd_hs)
                $display("wd_hs,write data channel handshaking is perfect");
        else
                $display("wd_hs,failed");

        property wb_hs;
                @(posedge clk)(BVALID && BREADY)|=>!BVALID && !BREADY;
        endproperty
        p3:assert property(wb_hs)
                $display("wb_hs,write response handshaking is perfect");
        else
                $display("wb_hs,failed");

        property ra_hs;
                @(posedge clk)(ARVALID && ARREADY)|=>!ARVALID && !ARREADY;
        endproperty
        p4:assert property(ra_hs)
                $display("ra_hs,read address channel handshaking is perfect");
        else
                $display("ra_hs,failed");

        property rd_hs;
         @(posedge clk)(RVALID && RREADY)|=>!RVALID && !RREADY;
        endproperty
        p5:assert property(rd_hs)
                $display("rd_hs,read data channel handshaking is perfect");
        else
                $display("rd_hs,failed");

        property resp;
                @(posedge clk)$rose(BVALID && BREADY)|->!BRESP;
        endproperty
        p6:assert property(resp)
                $display("bresp is perfect");
        else
                $display("bresp failed ************");
endinterface
