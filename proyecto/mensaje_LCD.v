module mensaje_LCD #(parameter NUM_COMMANDS = 4, 
                                NUM_DATA = 16,  // Solo linea 1
                                DATA_BITS = 8,
                                COUNT_MAX = 800000)(
    input clk,            
    input reset,
    input ready_i,          
    input [3:0] mns,      //Seleccionar mensaje
    output reg rs,        //Register select: comando o dato   
    output reg rw,        //Read/Write
    output enable,    
    output reg [DATA_BITS-1:0] dat
);

// Definir los estados de la FSM
localparam IDLE = 2'b00;
localparam CONFIG_CMD = 2'b01;
localparam WR_TEXT = 2'b10;
localparam CHANGE_MNS = 2'b11;

reg [1:0] fsm_state;
reg [1:0] next_state;
reg clk_16ms;

// Comandos de configuración del LCD
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;

// Contador para el div frec, comandos y datos
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
reg [$clog2(NUM_COMMANDS):0] command_counter;
reg [$clog2(NUM_DATA):0] data_counter;

// Registro para detectar cambio en mns
reg [3:0] mns_prev;

// Banco de registros para comandos y datos
reg [DATA_BITS-1:0] config_mem [0:NUM_COMMANDS-1]; 
reg [DATA_BITS-1:0] mensaje1 [0:NUM_DATA-1];
reg [DATA_BITS-1:0] mensaje2 [0:NUM_DATA-1];

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
    mns_prev <= 4'b0;
    
    config_mem[0] <= LINES2_MATRIX5x8_MODE8bit;
    config_mem[1] <= SHIFT_CURSOR_RIGHT;
    config_mem[2] <= DISPON_CURSOROFF;
    config_mem[3] <= CLEAR_DISPLAY;
    
    // Mensaje 1
    mensaje1[0]  <= "M";
    mensaje1[1]  <= "E";
    mensaje1[2]  <= "N";
    mensaje1[3]  <= "S";
    mensaje1[4]  <= "A";
    mensaje1[5]  <= "J";
    mensaje1[6]  <= "E";
    mensaje1[7]  <= " ";
    mensaje1[8]  <= "U";
    mensaje1[9]  <= "N";
    mensaje1[10] <= "O";
    mensaje1[11] <= " ";
    mensaje1[12] <= " ";
    mensaje1[13] <= " ";
    mensaje1[14] <= " ";
    mensaje1[15] <= " ";
    
    // Mensaje 2
    mensaje2[0]  <= "M";
    mensaje2[1]  <= "E";
    mensaje2[2]  <= "N";
    mensaje2[3]  <= "S";
    mensaje2[4]  <= "A";
    mensaje2[5]  <= "J";
    mensaje2[6]  <= "E";
    mensaje2[7]  <= " ";
    mensaje2[8]  <= "D";
    mensaje2[9]  <= "O";
    mensaje2[10] <= "S";
    mensaje2[11] <= " ";
    mensaje2[12] <= " ";
    mensaje2[13] <= " ";
    mensaje2[14] <= " ";
    mensaje2[15] <= " ";
end

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

always @(*) begin
    case(fsm_state)
        IDLE: begin
            next_state <= (ready_i)? CONFIG_CMD : IDLE;
        end
        CONFIG_CMD: begin 
            next_state <= (command_counter == NUM_COMMANDS) ? WR_TEXT : CONFIG_CMD;
        end
        WR_TEXT: begin
            if (mns != mns_prev) begin
                next_state <= CHANGE_MNS;
            end else begin
                next_state <= (data_counter == NUM_DATA) ? WR_TEXT : WR_TEXT;
                // Se queda en WR_TEXT mostrando el mensaje continuamente
            end
        end
        CHANGE_MNS: begin
            next_state <= (data_counter == NUM_DATA) ? WR_TEXT : WR_TEXT;
        end
        default: next_state = IDLE;
    endcase
end

always @(posedge clk_16ms) begin
    if (reset == 0) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
        dat <= 'b0;
        mns_prev <= 4'b0;
    end else begin
        case (next_state)
            IDLE: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                rs <= 1'b0;
                dat <= 'b0;
                mns_prev <= mns;
            end
            CONFIG_CMD: begin
                rs <= 1'b0;
                command_counter <= command_counter + 1;
                dat <= config_mem[command_counter];
                mns_prev <= mns;
            end
            CHANGE_MNS: begin
                rs <= 1'b0;
                data_counter <= 'b0;
                mns_prev <= mns;
            end
            WR_TEXT: begin
                rs <= 1'b1;
                // Seleccionar mensaje según mns
                if (mns == 4'b0000) begin
                    dat <= mensaje1[data_counter];
                end else begin
                    dat <= mensaje2[data_counter];
                end

                if (data_counter == NUM_DATA - 1) begin
                    data_counter <= 'b0;
                end else begin
                    data_counter <= data_counter + 1;
                end
            end
        endcase
    end
end

assign enable = clk_16ms;

endmodule