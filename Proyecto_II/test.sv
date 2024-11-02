class test extends uvm_test;
    `uvm_component_utils(test)

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    env e0;
    virtual mul_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e0 = env::type_id::create("e0", this);
        if (!uvm_config_db#(virtual mul_if)::get(this, "", "mul_if", vif))
            `uvm_fatal("TEST", "Did not get vif")
        uvm_config_db#(virtual mul_if)::set(this, "e0.a0.*", "mul_if", vif);



    endfunction

    virtual task run_phase(uvm_phase phase);
        gen_item_seq seq = gen_item_seq::type_id::create("seq");
        phase.raise_objection(this);

        seq.randomize();
        seq.start(e0.a0.s0);
        phase.drop_objection(this);
    endtask

endclass
