class monitor extends uvm_monitor;

    `uvm_component_utils(monitor)

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(Item) mon_analysis_port;
    virtual mul_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual mul_if)::get(this,"","mul_if",vif))
            `uvm_fatal("MON","Could not get vif")
        mon_analysis_port = new("mon_analysis_port", this);
      	`uvm_info("MON", "Monitor built successfully and vif obtained.", UVM_MEDIUM)
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
      	`uvm_info("MON", "Entering run_phase. Waiting for clock event...", UVM_MEDIUM)
        forever begin
        	@(vif.cb) begin
            	Item item   = Item::type_id::create("item");
                item.fp_X       = vif.fp_X;
                item.fp_Y       = vif.fp_Y;
                item.fp_Z       = vif.fp_Z;
                item.r_mode     = vif.r_mode;
                item.ovrf       = vif.ovrf;
                item.udrf       = vif.udrf;
                mon_analysis_port.write(item);
            	`uvm_info("MON",$sformatf("SAW Item %s", item.convert2str()),UVM_HIGH)
            end
        end
    endtask
endclass

