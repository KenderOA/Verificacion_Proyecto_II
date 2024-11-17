class monitor extends uvm_monitor; // Declare a class 'monitor' that extends 'uvm_monitor'

  `uvm_component_utils(monitor) // Macro to register the 'monitor' class with the UVM factory

  function new(string name = "monitor", uvm_component parent = null); // Constructor for the 'monitor' class
    super.new(name, parent); // Call the parent class constructor
  endfunction

  uvm_analysis_port #(Item) mon_analysis_port; // Declare an analysis port for 'Item' type
  virtual mul_if vif; // Declare a virtual interface handle for 'mul_if'

  virtual function void build_phase(uvm_phase phase); // Define the build phase function
    super.build_phase(phase); // Call the parent class build_phase function
    if(!uvm_config_db#(virtual mul_if)::get(this,"","mul_if",vif)) // Get the virtual interface from the configuration database
      `uvm_fatal("MON","Could not get vif") // Fatal error if the virtual interface is not found
    mon_analysis_port = new("mon_analysis_port", this); // Create a new analysis port instance
    `uvm_info("MON", "Monitor built successfully and vif obtained.", UVM_HIGH) // Info message indicating successful build
  endfunction

  virtual task run_phase(uvm_phase phase); // Define the run phase task
    super.run_phase(phase); // Call the parent class run_phase function
    `uvm_info("MON", "Entering run_phase. Waiting for clock event...", UVM_HIGH) // Info message indicating entry into run_phase
    forever begin // Infinite loop to continuously monitor the interface
      @(vif.cb) begin // Wait for a clock event on the virtual interface
        Item item   = Item::type_id::create("item"); // Create a new 'Item' object
        item.fp_X       = vif.fp_X; // Capture 'fp_X' signal from the interface
        item.fp_Y       = vif.fp_Y; // Capture 'fp_Y' signal from the interface
        item.fp_Z       = vif.fp_Z; // Capture 'fp_Z' signal from the interface
        item.r_mode     = vif.r_mode; // Capture 'r_mode' signal from the interface
        item.ovrf       = vif.ovrf; // Capture 'ovrf' signal from the interface
        item.udrf       = vif.udrf; // Capture 'udrf' signal from the interface
        mon_analysis_port.write(item); // Write the captured item to the analysis port
        `uvm_info("MON",$sformatf("SAW Item %s", item.convert2str()),UVM_HIGH) // Info message indicating the captured item
      end
    end
  endtask
endclass
