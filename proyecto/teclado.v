module teclado #(
    parameter CICLOS_10MS = 500000,  // Ciclos para 10 ms
    parameter CICLOS_20US = 1000     // Ciclos para 20 us
)(
    input wire clk,
    input wire rst,
    input [3:0] column,  // Columnas (inputs con pull-ups)
    output reg [3:0] row,  // Filas (outputs)
    output reg [7:0] digito,  // Columna detectada (0-3)
    output reg key_detected  // Pulso alto cuando se detecta tecla (para uso posterior)
);

// Estados de la FSM (agregué IDLE para claridad, como en mi versión anterior)
localparam IDLE = 3'b000;
localparam FILA_1 = 3'b001;
localparam FILA_2 = 3'b010;
localparam FILA_3 = 3'b011;
localparam FILA_4 = 3'b100;

reg [2:0] state;                 // Registro de estado
reg [2:0] next_state;            // Estado siguiente

reg [$clog2(CICLOS_10MS)-1:0] counter_10ms;  // Contador para 10 ms
reg enable_10ms;                             // Pulso cada 10 ms

reg [$clog2(CICLOS_20US)-1:0] counter_20us;  // Contador para 20 us
reg enable_20us;                             // Pulso cada 20 us

reg col_low;                    // Bandera: 1 si alguna columna es LOW

// Generador de pulso cada 10 ms
always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter_10ms <= 0;
        enable_10ms <= 0;
    end else begin
        enable_10ms <= 0;
        if (counter_10ms == CICLOS_10MS - 1) begin
            counter_10ms <= 0;
            enable_10ms <= 1;
        end else begin
            counter_10ms <= counter_10ms + 1;
        end
    end
end

// Generador de pulso cada 20 us
always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter_20us <= 0;
        enable_20us <= 0;
    end else begin
        enable_20us <= 0;
        if (counter_20us == CICLOS_20US - 1) begin
            counter_20us <= 0;
            enable_20us <= 1;
        end else begin
            counter_20us <= counter_20us + 1;
        end
    end
end

// Lógica de estado actual y detección de col_low
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        col_low <= 0;
        digito <= 0;
        key_detected <= 0;
    end else begin
        state <= next_state;
        col_low <= (column != 4'b1111) ? 1'b1 : 1'b0;
        key_detected <= 0;  // Pulso bajo por defecto
    end
end

// Lógica de estado siguiente
always @(*) begin
    next_state = state;
    case (state)
        IDLE: begin
            if (enable_10ms) begin
                next_state = FILA_1;
            end
        end
        FILA_1: begin
            if (col_low) begin
                next_state = FILA_1;  // Permanece
            end else if (enable_20us) begin
                next_state = FILA_2;
            end
        end
        FILA_2: begin
            if (col_low) begin
                next_state = FILA_2;
            end else if (enable_20us) begin
                next_state = FILA_3;
            end
        end
        FILA_3: begin
            if (col_low) begin
                next_state = FILA_3;
            end else if (enable_20us) begin
                next_state = FILA_4;
            end
        end
        FILA_4: begin
            if (col_low) begin
                next_state = FILA_4;
            end else if (enable_20us) begin
                next_state = IDLE;
            end
        end
        default: next_state = IDLE;
    endcase
end

// Asignación de filas y detección de columna (integrado en FSM)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        row <= 4'b1111;
    end else begin
        case (state)
            FILA_1: begin
                row <= 4'b0111;  // Activa fila 1
                if (col_low) begin
                    case (column)
                        4'b0111: digito <= 8'h31;  // 1
                        4'b1011: digito <= 8'h32;  // 2
                        4'b1101: digito <= 8'h33;  // 3
                        4'b1110: digito <= 8'h41;  // A
                        default: digito <= 8'h58;   // 58
                    endcase
                    key_detected <= 1;  // Pulso para indicar detección
                end
            end
            FILA_2: begin
                row <= 4'b1011;  // Activa fila 2
                if (col_low) begin
                    case (column)
                        4'b0111: digito <= 8'h34;  // 4
                        4'b1011: digito <= 8'h35;  // 5
                        4'b1101: digito <= 8'h36;  // 6
                        4'b1110: digito <= 8'h42;  // B
                        default: digito <= 8'h58;   // 58  // Ninguna o error
                    endcase
                    key_detected <= 1;
                end
            end
            FILA_3: begin
                row <= 4'b1101;  // Activa fila 3
                if (col_low) begin
                    case (column)
                        4'b0111: digito <= 8'h37;  // 7
                        4'b1011: digito <= 8'h38;  // 8
                        4'b1101: digito <= 8'h39;  // 9
                        4'b1110: digito <= 8'h43;  // C
                        default: digito <= 8'h58;   // 58
                    endcase
                    key_detected <= 1;
                end
            end
            FILA_4: begin
                row <= 4'b1110;  // Activa fila 4
                if (col_low) begin
                    case (column)
                        4'b0111: digito <= 8'h2A;  // *
                        4'b1011: digito <= 8'h30;  // 0
                        4'b1101: digito <= 8'h23;  // #
                        4'b1110: digito <= 8'h44;  // D
                        default: digito <= 8'h58;   // 58
                    endcase
                    key_detected <= 1;
                end
            end
            default: row <= 4'b1111;  // Todas HIGH
        endcase
    end
end

endmodule