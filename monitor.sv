class monitor extends uvm_monitor;

    `uvm_component_utils(monitor)
    function new(string name = "monitor",uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(mul_item) mon_analysis_port;
    virtual mul_if vif;

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual mul_if)::get(this,"","mul_vif",vif))
            `uvm_fatal("MON","Could not get vif")
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            @(vif.cb);
                if(vif.rstn) begin
                    mul_item item       = mul_item::type_id::create("item");
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