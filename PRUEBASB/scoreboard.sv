class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)
    
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp", this);
    endfunction
    
    bit signo;
    string signo_str;
    bit [7:0] exponente;
    bit [22:0] mantisa_result;
    bit [47:0] mantisa_product;
    bit [31:0] resultado_esperado;
  	bit [31:0] resultado_esperado_r;
    bit [7:0] exponente_result;
    int aciertos, fallos;
  	bit [2:0] r_mode;
  	bit guard_bit;
	bit round_bit;
  	bit sticky_bit;
  
  	 // Agregar archivo CSV
    string csv_filename = "scoreboard_results.csv";
    integer file_id;

    // Abrir el archivo CSV en la fase de inicio (open file)
    virtual function void start_of_simulation();
        file_id = $fopen(csv_filename, "w");
        if (file_id) begin
            // Escribir encabezado en el CSV
            $fwrite(file_id, "Fp_X,Fp_Y,Exponente_obtenido,Exponente_esperado,Mantisa_obtenido,Mantisa_esperado,Resultado_obtenido,Resultado_esperado,R_mode,Signo,Resultado_redondeado\n");
        end else begin
            `uvm_error("SCBD", "No se pudo abrir el archivo CSV para escritura.");
        end
    endfunction
    
    virtual function void write(Item item);
        signo = item.fp_X[31] ^ item.fp_Y[31]; 
        exponente = item.fp_X[30:23] + item.fp_Y[30:23] - 127; 
        mantisa_product = {1'b1, item.fp_X[22:0]} * {1'b1, item.fp_Y[22:0]}; 

        if (mantisa_product[47]) begin 
            mantisa_result = mantisa_product[46:24];
            exponente_result = exponente + 1;
          	
            // Asignación de bits de redondeo
          	round_bit = mantisa_product[23]; 
          	guard_bit = mantisa_product[22];
      		sticky_bit =mantisa_product[21];
          
        end else begin 
          
            mantisa_result = mantisa_product[45:23];
            exponente_result = exponente;
          	// Asignación de bits de redondeo
          	round_bit = mantisa_product[22];
          	guard_bit = mantisa_product[21]; 
          	sticky_bit =mantisa_product[20];
          
        end
      
     resultado_esperado = {signo, exponente_result, mantisa_result};

case (item.r_mode)
3'b000: begin
    // Redondeo a la unidad más cercana, ties to even
    if (round_bit == 0) begin
        // Si round_bit es 0, no se redondea
        resultado_esperado_r = resultado_esperado;
    end else if (round_bit == 1) begin
        // Si round_bit es 1, analizamos guard_bit y sticky_bit
        if (guard_bit || sticky_bit) begin
            // Si guard_bit o sticky_bit son 1, redondeamos hacia arriba
            resultado_esperado_r = resultado_esperado + 1;
        end else begin
            // Si guard_bit y sticky_bit son 0, aplicamos "ties to even"
            if (resultado_esperado[0] == 1) begin
                // Si resultado_esperado es impar, redondeamos hacia arriba para hacer par
                resultado_esperado_r = resultado_esperado + 1;
            end else begin
                // Si resultado_esperado es par, no redondeamos
                resultado_esperado_r = resultado_esperado; //REVISAR ESTO PORQUE NO DEBERÍA SER ASÍ
            end
        end
    end
end

       
    3'b001: begin
        // Round to zero (truncate)
        resultado_esperado_r = resultado_esperado; // No cambios, simplemente truncar
    end
    3'b010: begin
        // Round towards -∞
        if (signo == 0) begin
            resultado_esperado_r = resultado_esperado;
        end else begin
            resultado_esperado_r = resultado_esperado + 1;
        end
    end
    3'b011: begin
        // Round towards +∞
        if (signo == 0) begin
            resultado_esperado_r = resultado_esperado + 1;
        end else begin
            resultado_esperado_r = resultado_esperado;
        end
    end
    3'b100: begin
        // Round to nearest, ties away from zero
        if (round_bit == 0) begin
            resultado_esperado_r = resultado_esperado;
        end else begin
            resultado_esperado_r = resultado_esperado + 1;
        end
    end
    default: begin
        // Modo de redondeo no encontrado
        `uvm_error("SCBD", $sformatf("ERROR: MODO DE REDONDEO NO ENCONTRADO: %b", item.r_mode));
    end
endcase

// Verificar si el modo es válido antes de proceder con los mensajes UVM
if (!(item.fp_X inside {32'hFF800000, 32'h7F800000, 0, 32'h80000000, 32'hFFC00000, 32'h7FC00000}) && 
    !(item.fp_Y inside {32'hFF800000, 32'h7F800000, 0, 32'h80000000, 32'hFFC00000, 32'h7FC00000}) &&
    item.r_mode inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100} ) 
begin
    `uvm_info("SCBD", $sformatf("Exp obt: %h | Exp esp: %h | Man obt: %h | Man esp: %h | Res Esp: %h | Res Obt nr: %h | R_modo: %b | signo: %b", exponente_result, item.fp_Z[30:23], mantisa_result, item.fp_Z[22:0], item.fp_Z, resultado_esperado, item.r_mode, signo), UVM_HIGH);

    if (resultado_esperado_r == item.fp_Z) begin
        `uvm_info("SCBD", $sformatf("PASS: RESULTADO ESPERADO: %h | RESULTADO OBTENIDO: %h", item.fp_Z, resultado_esperado_r), UVM_LOW);
    end else begin
        // Caso para Underflow
        if (item.udrf == 1) begin
          `uvm_info("SCBD", $sformatf("INFO: UNDERFLOW DETECTADO: ± 0 | RESULTADO OBTENIDO: %h | RESULTADO ESPERADO: %h", resultado_esperado_r, item.fp_Z), UVM_LOW);
        // Caso para Overflow
        end else if (item.ovrf == 1) begin
          `uvm_info("SCBD", $sformatf("INFO: OVERFLOW DETECTADO: ± inf | RESULTADO OBTENIDO: %h | RESULTADO ESPERADO: %h", resultado_esperado_r, item.fp_Z), UVM_LOW);
        end else begin
          `uvm_error("SCBD", $sformatf("ERROR: RESULTADO OBTENIDO: %h | RESULTADO ESPERADO: %h", resultado_esperado_r, item.fp_Z));
        end
    end
end


        if (signo) begin
            signo_str = "-";
        end else begin
            signo_str = "+";
        end

        // Verificar si el resultado es ±inf
        if ((item.fp_X inside {32'hFF800000, 32'h7F800000}) || 
            (item.fp_Y inside {32'hFF800000, 32'h7F800000})) begin
            if (item.fp_Z == 32'hFF800000 || item.fp_Z == 32'h7F800000) begin
                if (signo == item.fp_Z[31]) begin
                    `uvm_info("SCBD", $sformatf("PASS: SIGNO CORRECTO Y RESULTADO CORRECTO | %s inf = %h", 
                                signo_str, item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1;
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: SIGNO INCORRECTO Y RESULTADO CORRECTO | %s inf = %h", 
                                signo_str, item.fp_Z));
                    fallos = fallos + 1;
                end
            end else if ((item.fp_X inside {32'hFF800000, 32'h7F800000, 32'hFFC00000, 32'h7FC00000}) || (item.fp_Y inside {32'hFF800000, 32'h7F800000, 32'hFFC00000, 32'h7FC00000})) begin
                if (item.fp_Z == 32'h7FC00000) begin
                    `uvm_info("SCBD", $sformatf("PASS:  RESULTADO CORRECTO | 7fc00000 = %h", item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1;
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: RESULTADO INCORRECTO fp_Z = %h != ±0", item.fp_Z));
                fallos = fallos + 1;
                end
            end
        end

        // Verificar si el resultado es ±0
        if ((item.fp_X inside {0, 32'h80000000}) || 
            (item.fp_Y inside {0, 32'h80000000})) begin
            if (item.fp_Z == 0 || item.fp_Z == 32'h80000000) begin
                if (signo == item.fp_Z[31]) begin
                    `uvm_info("SCBD", $sformatf("PASS: SIGNO CORRECTO Y RESULTADO CORRECTO | %s 0 = %h", 
                                signo_str, item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1;
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: SIGNO INCORRECTO Y RESULTADO CORRECTO | %s 0 = %h", 
                                signo_str, item.fp_Z));
                    fallos = fallos + 1;
                end
            end else if ((item.fp_X inside {32'hFF800000, 32'h7F800000, 32'hFFC00000, 32'h7FC00000}) || (item.fp_Y inside {32'hFF800000, 32'h7F800000, 32'hFFC00000, 32'h7FC00000})) begin
                if (item.fp_Z == 32'h7FC00000) begin
                    `uvm_info("SCBD", $sformatf("PASS:  RESULTADO CORRECTO | 7fc00000 = %h", item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1;
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: RESULTADO INCORRECTO fp_Z = %h != ±0", item.fp_Z));
                fallos = fallos + 1;
                end
            end
        end

      // Verificar si el resultado es NaN
        if ((item.fp_X inside {32'hFFC00000, 32'h7FC00000}) || 
            (item.fp_Y inside {32'hFFC00000, 32'h7FC00000})) begin
            if (item.fp_Z == 32'h7FC00000) begin
                `uvm_info("SCBD", $sformatf("PASS:  RESULTADO CORRECTO | 7fc00000 = %h", item.fp_Z), UVM_LOW);
                aciertos = aciertos + 1;
            end else begin
                `uvm_error("SCBD", $sformatf("ERROR: RESULTADO CORRECTO | 7fc00000 != %h", item.fp_Z));
                fallos = fallos + 1;
            end
        end 

        //`uvm_info("SCBD", $sformatf("ACIERTOS: %d | FALLOS: %d", aciertos, fallos), UVM_LOW);

        
     // Escribir en el archivo CSV
            if (file_id) begin
                $fwrite(file_id, "%h,%h,%h,%h,%h,%h,%h,%h,%b,%s,%h\n",
                        item.fp_X, item.fp_Y, exponente_result, item.fp_Z[30:23],
                        mantisa_result, item.fp_Z[22:0], item.fp_Z, resultado_esperado_r,
                        item.r_mode, signo_str, resultado_esperado_r);
            end
    endfunction
endclass
