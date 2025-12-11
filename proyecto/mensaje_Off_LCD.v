module mensaje_Off_LCD #(
    parameter NUM_COMMANDS = 4, 
    parameter NUM_DATA = 16,  // Solo línea 1
    parameter DATA_BITS = 8,
    parameter DATA = 0,       // Data por defecto
    parameter COUNT_MAX = 800000  // Para clk_16ms
)(
    input clk,            
    input reset,          // Asumido activo bajo (0 = reset)
    input ready_i,
    input distancia,      // Desde ultrasonido    
    input [1:0] mns,      // Seleccionar mensaje
    output reg rs,        // Register select: comando o dato   
    output reg rw,        // Read/Write (siempre 0 para write)
    output reg enable,    // Ahora reg condicional    
    output reg [DATA_BITS-1:0] dat
);

// Estados de la FSM (corregí numeración para consistencia)
localparam APAGADO = 3'b000;
localparam IDLE = 3'b001;
localparam CONFIG_CMD = 3'b010;
localparam WR_TEXT = 3'b011;
localparam DISPLAY = 3'b100;      // Mantiene display sin escribir
localparam CHANGE_MNS = 3'b101;   // Limpia y cambia mensaje

reg [2:0] fsm_state;
reg [2:0] next_state;
reg clk_16ms;

// Comandos de configuración del LCD
localparam DISPLAY_OFF = 8'h08;
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;

// Contadores
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
reg [$clog2(NUM_COMMANDS):0] command_counter;
reg [$clog2(NUM_DATA):0] data_counter;

// Registro para cambio en mns
reg [1:0] mns_prev;
reg Apagar;

// Banco de registros para comandos y datos
reg [DATA_BITS-1:0] config_mem [0:NUM_COMMANDS-1]; 
reg [DATA_BITS-1:0] mensaje0 [0:NUM_DATA-1]; // Usuario
reg [DATA_BITS-1:0] mensaje1 [0:NUM_DATA-1]; // Clave
reg [DATA_BITS-1:0] mensaje2 [0:NUM_DATA-1]; // Abierto
reg [DATA_BITS-1:0] mensaje3 [0:NUM_DATA-1]; // Intruso

// Inicialización (sin cambios)
initial begin
    fsm_state <= IDLE;
    command_counter <= 'b0;
    data_counter <= 'b0;
    rs <= 1'b0;
    rw <= 1'b0;
    dat <= 8'b0;
    mns_prev <= 2'b0;
    Apagar <= 1'b0;
    enable <= 1'b0;  // Inicial bajo
    
    config_mem[0] <= LINES2_MATRIX5x8_MODE8bit;
    config_mem[1] <= SHIFT_CURSOR_RIGHT;
    config_mem[2] <= DISPON_CURSOROFF;
    config_mem[3] <= CLEAR_DISPLAY;
    
    // Mensajes (sin cambios)
    mensaje0[0]  <= "E"; /* ... */ mensaje0[15] <= "*";  // Usuario
    mensaje1[0]  <= "I"; /* ... */ mensaje1[15] <= "*";  // Clave
    mensaje2[0]  <= "A"; /* ... */ mensaje2[15] <= " ";  // Abierto
    mensaje3[0]  <= " "; /* ... */ mensaje3[15] <= " ";  // Intruso
end

// Generador de clk_16ms (sin cambios)
always @(posedge clk) begin
    if (clk_counter == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        clk_counter <= 'b0;
    end else begin
        clk_counter <= clk_counter + 1;
    end
end

// Actualización del estado (sin cambios)
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next_state;
    end
end

// Lógica combinacional de transiciones (sin cambios)
always @(*) begin
    case(fsm_state)
        IDLE: begin
            next_state <= (ready_i)? APAGADO : IDLE;
        end
        
        APAGADO: begin
            next_state <= (~distancia)? CONFIG_CMD : APAGADO;
        end
        
        CONFIG_CMD: begin 
            next_state <= (command_counter == NUM_COMMANDS) ? WR_TEXT : CONFIG_CMD;
        end
        
        WR_TEXT: begin
            next_state <= (data_counter == NUM_DATA) ? DISPLAY : WR_TEXT;
        end
        
        DISPLAY: begin
            next_state <= (mns != mns_prev) ? CHANGE_MNS : DISPLAY;
        end
        
        CHANGE_MNS: begin
            next_state <= WR_TEXT;
        end
        
        default: next_state = IDLE;
    endcase
end

// Lógica secuencial de salidas y contadores (cambios clave aquí)
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
        dat <= 'b0;
        mns_prev <= 2'b0;
        rs <= 1'b0;
        Apagar <= 1'b0;
        enable <= 1'b0;  // Bajo en reset
    end else begin
        enable <= 1'b0;  // Bajo por defecto, solo alto cuando se escribe
        
        case (next_state)
            IDLE: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                rs <= 1'b0;
                dat <= 'b0;
                mns_prev <= mns;
                Apagar <= 1'b0;
            end
            
            APAGADO: begin
                rs <= 1'b0;
                dat <= DISPLAY_OFF;
                Apagar <= 1'b1;
                enable <= 1'b1;  // Activa enable para este comando
            end
            
            CONFIG_CMD: begin
                rs <= 1'b0;
                dat <= config_mem[command_counter];
                enable <= 1'b1;  // Activa para escribir comando
                command_counter <= command_counter + 1;
                Apagar <= 1'b0;
            end
            
            WR_TEXT: begin
                rs <= 1'b1;
                case (mns)
                    2'b00: dat <= mensaje0[data_counter];
                    2'b01: dat <= mensaje1[data_counter];
                    2'b10: dat <= mensaje2[data_counter];
                    2'b11: dat <= mensaje3[data_counter];
                    default: dat <= mensaje0[data_counter];
                endcase
                enable <= 1'b1;  // Activa para escribir data
                data_counter <= data_counter + 1;
            end
            
            DISPLAY: begin
                // NO ESCRIBIR: enable bajo, no cambia dat/rs
                rs <= 1'b0;  // Opcional, pero bajo para seguridad
                enable <= 1'b0;  // Crucial: no pulsos de enable
                // No incrementa contadores ni modifica dat
            end
            
            CHANGE_MNS: begin
                rs <= 1'b0;
                dat <= CLEAR_DISPLAY;  // Limpia
                enable <= 1'b1;  // Activa para clear
                data_counter <= 'b0;
                command_counter <= 'b0;
                mns_prev <= mns;
            end
        endcase
    end
end

endmodule