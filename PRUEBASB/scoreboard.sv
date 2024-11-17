class scoreboard extends uvm_scoreboard; // Define the scoreboard class extending uvm_scoreboard

    `uvm_component_utils(scoreboard) // Macro to register the scoreboard class with UVM

    function new(string name = "scoreboard", uvm_component parent = null); // Constructor
        super.new(name, parent); // Call the parent constructor
    endfunction

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp; // Declare analysis imp

    virtual function void build_phase(uvm_phase phase); // Build phase function
        super.build_phase(phase); // Call the parent build phase
        m_analysis_imp = new("m_analysis_imp", this); // Initialize analysis imp
    endfunction

    bit signo; // Sign bit
    string signo_str; // Sign string
    bit [7:0] exponente; // Exponent
    bit [22:0] mantisa_result; // Mantissa result
    bit [47:0] mantisa_product; // Mantissa product
    bit [31:0] resultado_esperado; // Expected result
    bit [31:0] resultado_esperado_r; // Rounded expected result
    bit [7:0] exponente_result; // Exponent result
    int aciertos, fallos; // Counters for hits and misses
    bit [2:0] r_mode; // Rounding mode
    bit guard_bit; // Guard bit
    bit round_bit; // Round bit
    bit sticky_bit; // Sticky bit

    // CSV file handling
    string csv_filename = "scoreboard_results.csv"; // CSV filename
    integer file_id; // File ID

    // Open the CSV file at the start of simulation
    virtual function void start_of_simulation();
        file_id = $fopen(csv_filename, "w"); // Open file for writing
        if (file_id) begin
            // Write header to CSV
            $fwrite(file_id, "Fp_X,Fp_Y,Exponente_obtenido,Exponente_esperado,Mantisa_obtenido,Mantisa_esperado,Resultado_obtenido,Resultado_esperado,R_mode,Signo,Resultado_redondeado\n");
        end else begin
            `uvm_error("SCBD", "No se pudo abrir el archivo CSV para escritura."); // Error if file cannot be opened
        end
    endfunction

    virtual function void write(Item item); // Write function
        signo = item.fp_X[31] ^ item.fp_Y[31]; // Calculate sign
        exponente = item.fp_X[30:23] + item.fp_Y[30:23] - 127; // Calculate exponent
        mantisa_product = {1'b1, item.fp_X[22:0]} * {1'b1, item.fp_Y[22:0]}; // Calculate mantissa product

        if (mantisa_product[47]) begin // Normalize mantissa
            mantisa_result = mantisa_product[46:24];
            exponente_result = exponente + 1;
            // Assign rounding bits
            round_bit = mantisa_product[23];
            guard_bit = mantisa_product[22];
            sticky_bit = mantisa_product[21];
        end else begin
            mantisa_result = mantisa_product[45:23];
            exponente_result = exponente;
            // Assign rounding bits
            round_bit = mantisa_product[22];
            guard_bit = mantisa_product[21];
            sticky_bit = mantisa_product[20];
        end

        resultado_esperado = {signo, exponente_result, mantisa_result}; // Form expected result

        // Rounding modes
        case (item.r_mode)
            3'b000: begin // Round to nearest, ties to even
                if (round_bit == 0) begin
                    resultado_esperado_r = resultado_esperado; // No rounding
                end else if (round_bit == 1) begin
                    if (guard_bit || sticky_bit) begin
                        resultado_esperado_r = resultado_esperado + 1; // Round up
                    end else begin
                        if (resultado_esperado[0] == 1) begin
                            resultado_esperado_r = resultado_esperado + 1; // Round to even
                        end else begin
                            resultado_esperado_r = resultado_esperado; // No rounding
                        end
                    end
                end
            end
            3'b001: begin // Round to zero (truncate)
                resultado_esperado_r = resultado_esperado; // No changes
            end
            3'b010: begin // Round towards -∞
                if (signo == 0) begin
                    resultado_esperado_r = resultado_esperado;
                end else begin
                    resultado_esperado_r = resultado_esperado + 1;
                end
            end
            3'b011: begin // Round towards +∞
                if (signo == 0) begin
                    resultado_esperado_r = resultado_esperado + 1;
                end else begin
                    resultado_esperado_r = resultado_esperado;
                end
            end
            3'b100: begin // Round to nearest, ties away from zero
                if (round_bit == 0) begin
                    resultado_esperado_r = resultado_esperado;
                end else begin
                    resultado_esperado_r = resultado_esperado + 1;
                end
            end
            default: begin // Invalid rounding mode
                `uvm_error("SCBD", $sformatf("ERROR: MODO DE REDONDEO NO ENCONTRADO: %b", item.r_mode));
            end
        endcase

        // Check for valid mode before proceeding with UVM messages
        if (!(item.fp_X inside {32'hFF800000, 32'h7F800000, 0, 32'h80000000, 32'hFFC00000, 32'h7FC00000}) && 
            !(item.fp_Y inside {32'hFF800000, 32'h7F800000, 0, 32'h80000000, 32'hFFC00000, 32'h7FC00000}) &&
            item.r_mode inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100} ) 
        begin
            `uvm_info("SCBD", $sformatf("Exp obt: %h | Exp esp: %h | Man obt: %h | Man esp: %h | Res Esp: %h | Res Obt nr: %h | R_modo: %b | signo: %b", exponente_result, item.fp_Z[30:23], mantisa_result, item.fp_Z[22:0], item.fp_Z, resultado_esperado, item.r_mode, signo), UVM_LOW);

            if (resultado_esperado_r == item.fp_Z) begin
                `uvm_info("SCBD", $sformatf("PASS: RESULTADO ESPERADO: %h | RESULTADO OBTENIDO: %h", item.fp_Z, resultado_esperado_r), UVM_LOW);
            end else begin
                // Underflow case
                if (item.udrf == 1) begin
                    `uvm_info("SCBD", $sformatf("INFO: UNDERFLOW DETECTADO: ± 0 | RESULTADO OBTENIDO: %h | RESULTADO ESPERADO: %h", resultado_esperado_r, item.fp_Z), UVM_LOW);
                // Overflow case
                end else if (item.ovrf == 1) begin
                    `uvm_info("SCBD", $sformatf("INFO: OVERFLOW DETECTADO: ± inf | RESULTADO OBTENIDO: %h | RESULTADO ESPERADO: %h", resultado_esperado_r, item.fp_Z), UVM_LOW);
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: RESULTADO OBTENIDO: %h | RESULTADO ESPERADO: %h", resultado_esperado_r, item.fp_Z));
                end
            end
        end

        if (signo) begin
            signo_str = "-"; // Set sign string to "-"
        end else begin
            signo_str = "+"; // Set sign string to "+"
        end

        // Check if result is ±inf
        if ((item.fp_X inside {32'hFF800000, 32'h7F800000}) || 
            (item.fp_Y inside {32'hFF800000, 32'h7F800000})) begin
            if (item.fp_Z == 32'hFF800000 || item.fp_Z == 32'h7F800000) begin
                if (signo == item.fp_Z[31]) begin
                    `uvm_info("SCBD", $sformatf("PASS: SIGNO CORRECTO Y RESULTADO CORRECTO | %s inf = %h", 
                                signo_str, item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1; // Increment hits
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: SIGNO INCORRECTO Y RESULTADO CORRECTO | %s inf = %h", 
                                signo_str, item.fp_Z));
                    fallos = fallos + 1; // Increment misses
                end
            end else if ((item.fp_X inside {32'hFF800000, 32'h7F800000, 32'hFFC00000, 32'h7FC00000}) || (item.fp_Y inside {32'hFF800000, 32'h7F800000, 32'hFFC00000, 32'h7FC00000})) begin
                if (item.fp_Z == 32'h7FC00000) begin
                    `uvm_info("SCBD", $sformatf("PASS:  RESULTADO CORRECTO | 7fc00000 = %h", item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1; // Increment hits
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: RESULTADO INCORRECTO fp_Z = %h != ±0", item.fp_Z));
                    fallos = fallos + 1; // Increment misses
                end
            end
        end

        // Check if result is ±0
        if ((item.fp_X inside {0, 32'h80000000}) || 
            (item.fp_Y inside {0, 32'h80000000})) begin
            if (item.fp_Z == 0 || item.fp_Z == 32'h80000000) begin
                if (signo == item.fp_Z[31]) begin
                    `uvm_info("SCBD", $sformatf("PASS: SIGNO CORRECTO Y RESULTADO CORRECTO | %s 0 = %h", 
                                signo_str, item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1; // Increment hits
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: SIGNO INCORRECTO Y RESULTADO CORRECTO | %s 0 = %h", 
                                signo_str, item.fp_Z));
                    fallos = fallos + 1; // Increment misses
                end
            end else if ((item.fp_X inside {32'hFF800000, 32'h7F800000, 32'hFFC00000, 32'h7FC00000}) || (item.fp_Y inside {32'hFF800000, 32'h7F800000, 32'hFFC00000, 32'h7FC00000})) begin
                if (item.fp_Z == 32'h7FC00000) begin
                    `uvm_info("SCBD", $sformatf("PASS:  RESULTADO CORRECTO | 7fc00000 = %h", item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1; // Increment hits
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: RESULTADO INCORRECTO fp_Z = %h != ±0", item.fp_Z));
                    fallos = fallos + 1; // Increment misses
                end
            end
        end

        // Check if result is NaN
        if ((item.fp_X inside {32'hFFC00000, 32'h7FC00000}) || 
            (item.fp_Y inside {32'hFFC00000, 32'h7FC00000})) begin
            if (item.fp_Z == 32'h7FC00000) begin
                `uvm_info("SCBD", $sformatf("PASS:  RESULTADO CORRECTO | 7fc00000 = %h", item.fp_Z), UVM_LOW);
                aciertos = aciertos + 1; // Increment hits
            end else begin
                `uvm_error("SCBD", $sformatf("ERROR: RESULTADO CORRECTO | 7fc00000 != %h", item.fp_Z));
                fallos = fallos + 1; // Increment misses
            end
        end

        // Write to CSV file
        if (file_id) begin
            $fwrite(file_id, "%h,%h,%h,%h,%h,%h,%h,%h,%b,%s,%h\n",
                    item.fp_X, item.fp_Y, exponente_result, item.fp_Z[30:23],
                    mantisa_result, item.fp_Z[22:0], item.fp_Z, resultado_esperado_r,
                    item.r_mode, signo_str, resultado_esperado_r);
        end
    endfunction
endclass
