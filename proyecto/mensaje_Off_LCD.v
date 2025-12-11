module mensaje_Off_LCD #(parameter  NUM_COMMANDS = 4, 
                                NUM_DATA = 16,  // Solo linea 1
                                DATA_BITS = 8,
                                COUNT_MAX = 800000)(
    input clk,            
    input reset,
    input ready_i,
    input distancia,      //Viene de ultrasonido    
    input [1:0] mns,      //Seleccionar mensaje
    output reg rs,        //Register select: comando o dato   
    output reg rw,        //Read/Write
    output enable,    
    output reg [DATA_BITS-1:0] dat
);

// Definir los estados de la FSM
localparam APAGADO = 3'b000;
localparam IDLE = 3'b001;
localparam CONFIG_CMD = 3'b010;
localparam WR_TEXT = 3'b011;
localparam DISPLAY = 3'b100;      // Nuevo estado para mantener el display
localparam CHANGE_MNS = 3'b101;   // Simplificado: solo limpia y cambia mensaje

reg [2:0] fsm_state;
reg [2:0] next_state;
reg clk_16ms;

// Comandos de configuración del LCD
localparam DISPLAY_OFF = 8'h08;
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;

// Contadores para el div frec, comandos y datos
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
reg [$clog2(NUM_COMMANDS):0] command_counter;
reg [$clog2(NUM_DATA):0] data_counter;

// Registro para detectar cambio en mns
reg [1:0] mns_prev;
reg Apagar;

// Banco de registros para comandos y datos
reg [DATA_BITS-1:0] config_mem [0:NUM_COMMANDS-1]; 
reg [DATA_BITS-1:0] mensaje0 [0:NUM_DATA-1]; //Usuario
reg [DATA_BITS-1:0] mensaje1 [0:NUM_DATA-1]; //Clave
reg [DATA_BITS-1:0] mensaje2 [0:NUM_DATA-1]; //Abierto
reg [DATA_BITS-1:0] mensaje3 [0:NUM_DATA-1]; //Intruso

// Inicialización
initial begin
    fsm_state <= IDLE;
    command_counter <= 'b0;
    data_counter <= 'b0;
    rs <= 1'b0;
    rw <= 1'b0;
    dat <= 8'b0;
    clk_16ms <= 1'b0;
    clk_counter <= 'b0;
    mns_prev <= 2'b0;
    Apagar <= 1'b0;
    
    config_mem[0] <= LINES2_MATRIX5x8_MODE8bit;
    config_mem[1] <= SHIFT_CURSOR_RIGHT;
    config_mem[2] <= DISPON_CURSOROFF;
    config_mem[3] <= CLEAR_DISPLAY;
    
    // Mensaje 0 - Usuario
    mensaje0[0]  <= "E";
    mensaje0[1]  <= "N";
    mensaje0[2]  <= "T";
    mensaje0[3]  <= "R";
    mensaje0[4]  <= "A";
    mensaje0[5]  <= " ";
    mensaje0[6]  <= "U";
    mensaje0[7]  <= "S";
    mensaje0[8]  <= "U";
    mensaje0[9]  <= "A";
    mensaje0[10] <= "R";
    mensaje0[11] <= "I";
    mensaje0[12] <= "O";
    mensaje0[13] <= " ";
    mensaje0[14] <= "Y";
    mensaje0[15] <= "*";

    // Mensaje 1 - Clave
    mensaje1[0]  <= "I";
    mensaje1[1]  <= "N";
    mensaje1[2]  <= "G";
    mensaje1[3]  <= "R";
    mensaje1[4]  <= "E";
    mensaje1[5]  <= "S";
    mensaje1[6]  <= "A";
    mensaje1[7]  <= " ";
    mensaje1[8]  <= "C";
    mensaje1[9]  <= "L";
    mensaje1[10] <= "A";
    mensaje1[11] <= "V";
    mensaje1[12] <= "E";
    mensaje1[13] <= " ";
    mensaje1[14] <= "Y";
    mensaje1[15] <= "*";

    // Mensaje 2 - Abierto
    mensaje2[0]  <= "A";
    mensaje2[1]  <= "B";
    mensaje2[2]  <= "I";
    mensaje2[3]  <= "E";
    mensaje2[4]  <= "R";
    mensaje2[5]  <= "T";
    mensaje2[6]  <= "O";
    mensaje2[7]  <= ".";
    mensaje2[8]  <= ".";
    mensaje2[9]  <= ".";
    mensaje2[10] <= " ";
    mensaje2[11] <= " ";
    mensaje2[12] <= " ";
    mensaje2[13] <= " ";
    mensaje2[14] <= " ";
    mensaje2[15] <= " ";

    // Mensaje 3 - Intruso
    mensaje3[0]  <= " ";
    mensaje3[1]  <= "I";
    mensaje3[2]  <= "N";
    mensaje3[3]  <= "T";
    mensaje3[4]  <= "R";
    mensaje3[5]  <= "U";
    mensaje3[6]  <= "S";
    mensaje3[7]  <= "O";
    mensaje3[8]  <= " ";
    mensaje3[9]  <= ">";
    mensaje3[10] <= ":";
    mensaje3[11] <= "[";
    mensaje3[12] <= " ";
    mensaje3[13] <= " ";
    mensaje3[14] <= " ";
    mensaje3[15] <= " ";
end

// Generador de reloj de 16ms
always @(posedge clk) begin
    if (clk_counter == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        clk_counter <= 'b0;
    end else begin
        clk_counter <= clk_counter + 1;
    end
end

// Actualización del estado
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next_state;
    end
end

// Lógica combinacional de transiciones de estado
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
            // Cuando termina de escribir, va a DISPLAY
            next_state <= (data_counter == NUM_DATA) ? DISPLAY : WR_TEXT;
        end
        
        DISPLAY: begin
            // Solo cambia de mensaje si mns es diferente
            next_state <= (mns != mns_prev) ? CHANGE_MNS : DISPLAY;
        end
        
        CHANGE_MNS: begin
            // Después de limpiar, escribe el nuevo mensaje
            next_state <= WR_TEXT;
        end
        
        default: next_state = IDLE;
    endcase
end

// Lógica secuencial de las salidas y contadores
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
        dat <= 'b0;
        mns_prev <= 2'b0;
        rs <= 1'b0;
        Apagar <= 1'b0;
    end else begin
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
            end
            
            CONFIG_CMD: begin
                rs <= 1'b0;
                command_counter <= command_counter + 1;
                dat <= config_mem[command_counter];
                Apagar <= 1'b0;
            end
            
            WR_TEXT: begin
                rs <= 1'b1;
                // Seleccionar mensaje según mns
                case (mns)
                    2'b00: dat <= mensaje0[data_counter];
                    2'b01: dat <= mensaje1[data_counter];
                    2'b10: dat <= mensaje2[data_counter];
                    2'b11: dat <= mensaje3[data_counter];
                    default: dat <= mensaje0[data_counter];
                endcase
                data_counter <= data_counter + 1;
            end
            
            DISPLAY: begin
                // Mantener el mensaje en pantalla sin escribir
                rs <= 1'b1;
                // No se incrementan contadores, no se modifica dat
            end
            
            CHANGE_MNS: begin
                rs <= 1'b0;
                dat <= CLEAR_DISPLAY;    // Solo limpia la pantalla
                data_counter <= 'b0;     // Reinicia contador de datos
                command_counter <= 'b0;  // Reinicia contador de comandos (por seguridad)
                mns_prev <= mns;         // Actualiza el mensaje anterior
            end
        endcase
    end
end

assign enable = clk_16ms;

endmodule