
// Class definition for the test, extending from uvm_test
class test extends uvm_test;

  // Macro to register the component with the factory
  `uvm_component_utils(test)

  // Constructor for the test class
  function new(string name = "test", uvm_component parent = null);
    // Call the parent constructor
    super.new(name, parent);
  endfunction

  // Declaration of environment, sequence, and virtual interface variables
  env e0;
  gen_item_seq seq;
  virtual mul_if vif;

  // Build phase function to create and configure components
  virtual function void build_phase(uvm_phase phase);
    // Call the parent build_phase
    super.build_phase(phase);

    // Create the environment component
    e0 = env::type_id::create("e0", this);

    // Get the virtual interface from the configuration database
    if (!uvm_config_db#(virtual mul_if)::get(this, "", "mul_if", vif))
      // Fatal error if the virtual interface is not found
      `uvm_fatal("TEST", "Did not get vif")
    // Set the virtual interface for the environment's sub-components
    uvm_config_db#(virtual mul_if)::set(this, "e0.a0.*", "mul_if", vif);

    // Create the sequence
    seq = gen_item_seq::type_id::create("seq");
  endfunction

  // Run phase task to execute the test sequences
  virtual task run_phase(uvm_phase phase);

    // Raise an objection to keep the simulation running
    phase.raise_objection(this);

    // Set the case type to "default" and randomize the sequence
    seq.case_type = "default";
    seq.randomize();
    // Start the sequence on the environment's sub-component
    seq.start(e0.a0.s0);

    // Set the case type to "NaN" and randomize the sequence
    seq.case_type = "NaN";
    seq.randomize();
    // Start the sequence on the environment's sub-component
    seq.start(e0.a0.s0);

    // Set the case type to "r_invalid" and randomize the sequence
    seq.case_type = "r_invalid";
    seq.randomize();
    // Start the sequence on the environment's sub-component
    seq.start(e0.a0.s0);

    // Set the case type to "Zero" and randomize the sequence
    seq.case_type = "Zero";
    seq.randomize();
    // Start the sequence on the environment's sub-component
    seq.start(e0.a0.s0);

    // Set the case type to "Infinity" and randomize the sequence
    seq.case_type = "Infinity";
    seq.randomize();
    // Start the sequence on the environment's sub-component
    seq.start(e0.a0.s0);

    // Set the case type to "zero_x_inf_y" and randomize the sequence
    seq.case_type = "zero_x_inf_y";
    seq.randomize();
    // Start the sequence on the environment's sub-component
    seq.start(e0.a0.s0);

    // Set the case type to "inf_x_NaN_y" and randomize the sequence
    seq.case_type = "inf_x_NaN_y";
    seq.randomize();
    // Start the sequence on the environment's sub-component
    seq.start(e0.a0.s0);

    // Set the case type to "zero_x_NaN_y" and randomize the sequence
    seq.case_type = "zero_x_NaN_y";
    seq.randomize();
    // Start the sequence on the environment's sub-component
    seq.start(e0.a0.s0);

    // Wait for 700 time units
    #700;
    // Drop the objection to end the simulation
    phase.drop_objection(this);

  endtask

endclass

