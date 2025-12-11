module top (
    input  wire       clk,          // Reloj principal (50 MHz)
    input  wire       reset,        // Reset activo bajo
    input  wire       ready_i,      // Señal de sistema listo
    input  wire       distance,     // No usado por ahora

    // Pines del teclado matricial 4x4
    input  wire [3:0] column,       // Entradas de columnas (con pull-up externas o internas)
    output wire [3:0] row,          // Salidas de filas (activadas secuencialmente)

    // Salidas hacia la LCD 1602
    output wire       rs,
    output wire       rw,
    output wire       enable,
    output wire [7:0] data
);

    // ================================================
    // Señales internas del teclado
    // ================================================
    wire [3:0] digito;           // Código 0-F del teclado
    wire       key_detected;     // Pulso cuando se detecta tecla
    wire       p;                // Siempre 1 (para pull-ups)

    // Salida ASCII del conversor
    wire [6:0] ascii_char;

    // Señales para el LCD
    reg        message_change = 0;
    reg [1:0]  sel_msg        = 2'b01;  // por defecto: "INGRESA CLAVE"

    // ================================================
    // Instancias de tus módulos reales
    // ================================================
    teclado teclado_inst (
        .clk(clk),
        .rst(reset),
        .column(column),     // Conectado directamente al pin de entrada
        .row(row),           // Conectado directamente al pin de salida
        .digito(digito),
        .key_detected(key_detected),
        .p(p)
    );

    codahexa codahexa_inst (
        .digdec(digito),
        .dighex(ascii_char)
    );

    LCD1602_controller lcd_controller (
        .clk(clk),
        .reset(reset),
        .ready_i(ready_i),
        .message_change(message_change),
        .sel_msg(sel_msg),
        .data_in({1'b0, ascii_char}),   // 8 bits para data_in
        .rs(rs),
        .rw(rw),
        .enable(enable),
        .data(data)
    );

    // ================================================
    // FSM para acumular contraseña de 4 dígitos
    // ================================================
    localparam S_ESPERA   = 2'b00;
    localparam S_GUARDA   = 2'b01;
    localparam S_LLENO    = 2'b10;

    reg [1:0] state     = S_ESPERA;
    reg [1:0] next_state;

    reg [1:0] pos = 2'b00;  // posición actual en el buffer (0 a 3)

    // ------------------------------------------------
    // 1. Registro de estado actual
    // ------------------------------------------------
    always @(posedge clk) begin
        if (reset == 0)
            state <= S_ESPERA;
        else
            state <= next_state;
    end

    // ------------------------------------------------
    // 2. Lógica combinacional de estado futuro
    // ------------------------------------------------
    always @(*) begin
        next_state = state;

        case (state)
            S_ESPERA: begin
                if (key_detected && digito != 4'b0000)  // tecla válida (no "sin tecla")
                    next_state = S_GUARDA;
            end

            S_GUARDA: begin
                if (pos == 2'd3)
                    next_state = S_LLENO;
                else
                    next_state = S_ESPERA;
            end

            S_LLENO: begin
                next_state = S_ESPERA;
            end

            default:
                next_state = S_ESPERA;
        endcase
    end

    // ------------------------------------------------
    // 3. Lógica secuencial de salidas y buffer
    // ------------------------------------------------
    always @(posedge clk) begin
        if (reset == 0) begin
            pos               <= 2'b00;
            message_change    <= 1'b0;
            sel_msg           <= 2'b01;  // "INGRESA CLAVE"
        end else begin
            message_change <= 1'b0;  // pulso de 1 ciclo

            case (state)
                S_ESPERA: begin
                    // nada
                end

                S_GUARDA: begin
                    // El carácter ya se muestra automáticamente en la segunda línea
                    // gracias a data_in conectado a ascii_char
                    if (pos < 3)
                        pos <= pos + 1'b1;
                end

                S_LLENO: begin
                    // Contraseña completa (4 dígitos)
                    sel_msg        <= 2'b10;     // mensaje "ABIERTO"
                    message_change <= 1'b1;      // avisa al LCD que cambie

                    // Limpiar para próximo intento
                    pos <= 2'b00;
                end

                default: ;
            endcase
        end
    end

endmodule