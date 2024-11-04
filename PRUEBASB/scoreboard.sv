class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)

    // Declaración de variables como miembros de la clase
    bit [22:0] mantisa_X;  // Mantisa de fp_X
    bit [7:0]  exponente_X; // Exponente de fp_X
    bit        signo_X;     // Signo de fp_X

    bit [22:0] mantisa_Y;  // Mantisa de fp_Y
    bit [7:0]  exponente_Y; // Exponente de fp_Y
    bit        signo_Y;     // Signo de fp_Y
    bit        signo_Z;     // Signo de fp_Z

    // Declaración de mantisa_producto y exponente_producto como miembros
    bit [47:0] mantisa_producto;   // Producto de mantisas
    bit [8:0]  exponente_producto;  // Producto de exponentes
    bit [31:0] fp_Z_calculado;      // Resultado calculado

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

    virtual function void write(Item item);
        // Mensaje para mostrar los valores que están entrando
        `uvm_info("SCBD", $sformatf("Received in Scoreboard: r_mode=%0d, fp_X=%0b, fp_Y=%0b, fp_Z=%0b, Overflow=%b, Underflow=%b", 
            item.r_mode, item.fp_X, item.fp_Y, item.fp_Z, item.ovrf, item.udrf), UVM_LOW)

        // Descomposición de fp_X y fp_Y en signo, exponente y mantisa
        mantisa_X = item.fp_X[22:0];
        exponente_X = item.fp_X[30:23];
        signo_X = item.fp_X[31];

        mantisa_Y = item.fp_Y[22:0];
        exponente_Y = item.fp_Y[30:23];
        signo_Y = item.fp_Y[31];

        // Multiplicación de mantisas (agregamos el bit implícito)
        mantisa_producto = (mantisa_X | 23'b10000000000000000000000) * (mantisa_Y | 23'b10000000000000000000000);

        // Sumar exponentes (se restará el sesgo de 127)
        exponente_producto = (exponente_X + exponente_Y) - 127; 

        // Determinar el signo del resultado (XOR para determinar el signo)
        signo_Z = signo_X ^ signo_Y; 

        // Normalizar el resultado
        // Si hay un bit de sobrecarga, desplazar a la derecha y ajustar el exponente
        if (mantisa_producto[47]) begin
            mantisa_producto = mantisa_producto >> 1;
            exponente_producto = exponente_producto + 1;
        end

        // Ajuste según el modo de redondeo
        case (item.r_mode)
            0: // Redondeo hacia cero
                mantisa_producto = mantisa_producto[46:24]; // Truncar (descartar la parte fraccionaria)
            1: // Redondeo hacia el entero más cercano
                if (mantisa_producto[23]) // Si el bit 23 es 1, se necesita redondear
                    mantisa_producto = mantisa_producto[46:24] + 1; // Añadir uno
                else
                    mantisa_producto = mantisa_producto[46:24]; // Truncar
            2: // Redondeo hacia el infinito positivo
                if (signo_Z == 0 && mantisa_producto[23]) // Solo si es positivo y hay fracción
                    mantisa_producto = mantisa_producto[46:24] + 1;
                else
                    mantisa_producto = mantisa_producto[46:24]; // Truncar
            3: // Redondeo hacia el infinito negativo
                if (signo_Z == 1 && mantisa_producto[23]) // Solo si es negativo y hay fracción
                    mantisa_producto = mantisa_producto[46:24] + 1;
                else
                    mantisa_producto = mantisa_producto[46:24]; // Truncar
            default:
                mantisa_producto = mantisa_producto[46:24]; // Truncar por defecto
        endcase

        // Crear el resultado final en formato IEEE 754
        fp_Z_calculado = {signo_Z, exponente_producto[7:0], mantisa_producto[22:0]};

        // Comparar con el fp_Z del item
        if (fp_Z_calculado !== item.fp_Z) begin
            `uvm_error("SCBD", $sformatf("ERROR! fp_Z calculado (%0b) no coincide con fp_Z obtenido (%0b)", 
                fp_Z_calculado, item.fp_Z))
        end else begin
            `uvm_info("SCBD", $sformatf("PASS! fp_Z calculado (%0b) coincide con fp_Z obtenido (%0b)", 
                fp_Z_calculado, item.fp_Z), UVM_HIGH);
        end
    endfunction
endclass
