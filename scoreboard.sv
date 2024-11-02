class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Variables para el checkeo
    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;
    
    // Puedes definir variables para almacenar valores anteriores
    real expected_X;
    real expected_Y;
    real expected_Z;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

    virtual function void write(Item item);
        `uvm_info("SCBD", $sformatf("r mode=%0d X=%0f Y=%0f Z=%0f Overflow=%b Underflow=%b",
            item.r_mode, $bitstoreal(item.fp_X), $bitstoreal(item.fp_Y), $bitstoreal(item.fp_Z), item.ovrf, item.udrf), UVM_LOW)

        // Calcular el resultado esperado basado en los valores de entrada
        expected_X = $bitstoreal(item.fp_X) * $bitstoreal(item.fp_Y); // Ejemplo de multiplicación
        expected_Z = expected_X; // Asumiendo que Z es el resultado

        // Comparar resultados
        if (expected_Z !== $bitstoreal(item.fp_Z)) begin
            `uvm_fatal("CHECKER", $sformatf("Error: Resultado esperado Z=%0f, pero Z obtenido=%0f", expected_Z, $bitstoreal(item.fp_Z)));
        end else begin
            `uvm_info("CHECKER", $sformatf("Resultado correcto: Z=%0f", $bitstoreal(item.fp_Z)), UVM_LOW);
        end

        // Aquí puedes agregar más verificaciones como overflow y underflow
        if (item.ovrf) begin
            `uvm_warning("OVERFLOW_WARNING", "Se detectó un overflow en el resultado");
        end

        if (item.udrf) begin
            `uvm_warning("UNDERFLOW_WARNING", "Se detectó un underflow en el resultado");
        end
    endfunction
endclass
