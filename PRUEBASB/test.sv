class test extends uvm_test;

    `uvm_component_utils(test)

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    env e0;
    gen_item_seq seq;
    virtual mul_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        e0 = env::type_id::create("e0", this);

        if (!uvm_config_db#(virtual mul_if)::get(this, "", "mul_if", vif))
            `uvm_fatal("TEST", "Did not get vif")
        uvm_config_db#(virtual mul_if)::set(this, "e0.a0.*", "mul_if", vif);

        seq = gen_item_seq::type_id::create("seq");
      	
    endfunction

    virtual task run_phase(uvm_phase phase);

        phase.raise_objection(this);

		seq.case_type = "default";
      	seq.randomize();
        seq.start(e0.a0.s0);
      	
      	seq.case_type = "NaN";
      	seq.randomize();
       	seq.start(e0.a0.s0);
      
      	seq.case_type = "r_invalid";
      	seq.randomize();
        seq.start(e0.a0.s0);
      
      	seq.case_type = "Zero";
      	seq.randomize();
        seq.start(e0.a0.s0);
      
      	seq.case_type = "Infinity";
      	seq.randomize();
        seq.start(e0.a0.s0);
      
      	seq.case_type = "zero_x_inf_y";
      	seq.randomize();
        seq.start(e0.a0.s0);
      
      	seq.case_type = "inf_x_NaN_y";
      	seq.randomize();
        seq.start(e0.a0.s0);
      
      	seq.case_type = "zero_x_NaN_y";
      	seq.randomize();
        seq.start(e0.a0.s0);
      
        #700;
        phase.drop_objection(this);

    endtask

endclass

