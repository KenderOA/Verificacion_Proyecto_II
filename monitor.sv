class monitor extends uvm_monitor;

    `uvm_component_utils(monitor)
    function new(string name = "monitor",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    uvm_analysis_port #(Item) mon_analysis_port;
    virtual des_if vif;

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual multiplicador_if)::get(this,"","multiplicador_vif",vif))
            `uvm_fatal("MON","Could not get vif")
            mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            @(vif.cb);
                if(vif.rstn) begin
                    Item Item       = Item::type_id::create("Item");
                    Item.fp_X       = vif.fp_X;
                    Item.fp_Y       = vif.fp_Y;
                    Item.fp_Z       = vif.fp_Z;
                    Item.r_mode     = vif.r_mode;
                    Item.ovrf       = vif.ovrf;
                    Item.udrf       = vif.udrf;
                    mon_analysis_port.write(Item);
                    `uvm_info("MON",$sformatf("SAW Item %s", Item.convert2str()),UVM_HIGH)
                end
        end
    endtask
endclass

//revisar, dudas