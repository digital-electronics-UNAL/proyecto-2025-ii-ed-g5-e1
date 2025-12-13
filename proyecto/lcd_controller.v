module LCD1602_controller #(parameter NUM_COMMANDS = 4, 
                                      MAX_NUM_PASS = 9999,
                                      NUM_DATA = 16,  
                                      NUM_DATA_PERLINE = 16,
                                      DATA_BITS = 8,
                                      COUNT_MAX = 800000)(
    input clk,            
    input reset,          
    input ready_i,
    input message_change,
    input [1:0] sel_msg,
    input [$clog2(MAX_NUM_PASS)-1:0] data_in, // Numero de 4 digitos correspondiente a la contraseña
    output reg rs,        
    output reg rw,
    output enable,    
    output reg [DATA_BITS-1:0] data
);

// Definir los estados de la FSM
localparam IDLE = 3'b000;
localparam CONFIG_CMD1 = 3'b001;
localparam WR_STATIC_TEXT_1L = 3'b010;
localparam CONFIG_CMD2 = 3'b011;
localparam WR_STATIC_TEXT_2L = 3'b100;
localparam WR_Din_TEXT = 3'b101;

localparam SetCursor=3'b000;
localparam WR_UM=3'b001;
localparam WR_C=3'b010;
localparam WR_D=3'b011;
localparam WR_U=3'b100;

reg [2:0] fsm_state;
reg [2:0] next_state;
reg clk_16ms;
reg [2:0] sel_dinamic;

// Comandos de configuración
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam DISPON_CURSORBLINK = 8'h0E;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
localparam START_2LINE = 8'hC0;

// Definir un contador para el divisor de frecuencia
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
// Definir un contador para controlar el envío de comandos
reg [$clog2(NUM_COMMANDS):0] command_counter;
// Definir un contador para controlar el envío de datos
reg [$clog2(NUM_DATA_PERLINE):0] data_counter;

// Banco de registros para comandos y datos
reg [DATA_BITS-1:0] config_mem [0:NUM_COMMANDS-1]; 
reg [DATA_BITS-1:0] message [0:NUM_DATA-1];

initial begin
    fsm_state <= IDLE;
    command_counter <= 'b0;
    data_counter <= 'b0;
    rs <= 1'b0;
    rw <= 1'b0;
    data <= 8'b0;
    clk_16ms <= 1'b0;
    clk_counter <= 'b0;
	config_mem[0] <= LINES2_MATRIX5x8_MODE8bit;
	config_mem[1] <= SHIFT_CURSOR_RIGHT;
	config_mem[2] <= DISPON_CURSOROFF;
	config_mem[3] <= CLEAR_DISPLAY;  
end

always @(posedge clk) begin
    if (clk_counter == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        clk_counter <= 'b0;
    end else begin
        clk_counter <= clk_counter + 1;
    end
end


always @(posedge clk_16ms)begin
    if(reset == 0)begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next_state;
    end
end

// Logica de estado futuro
always @(*) begin
    case(fsm_state)
        IDLE: begin
            next_state <= (ready_i)? CONFIG_CMD1 : IDLE;
        end
        CONFIG_CMD1: begin 
            next_state <= (command_counter == NUM_COMMANDS)? WR_STATIC_TEXT_1L : CONFIG_CMD1;
        end
        WR_STATIC_TEXT_1L:begin
			next_state <= (data_counter == NUM_DATA_PERLINE)? WR_Din_TEXT : WR_STATIC_TEXT_1L;
        end
        WR_Din_TEXT: begin
            next_state <= (message_change) ? IDLE : WR_Din_TEXT;
        end
        default: next_state = IDLE;
    endcase
end
// Logica de salida
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
		  data <= 'b0;
    end else begin
        case (next_state)
            IDLE: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                rs <= 1'b0;
                data  <= 'b0;
            end
            CONFIG_CMD1: begin
			    rs <= 1'b0; 	
                command_counter <= command_counter + 1;
				data <= config_mem[command_counter];
            end
            WR_STATIC_TEXT_1L: begin
                data_counter <= data_counter + 1;
                rs <= 1'b1; 
				data <= message[data_counter];
                sel_dinamic <= SetCursor;
            end
            WR_Din_TEXT: begin
                data_counter <= 'b0;
                case (sel_dinamic)
                SetCursor: begin
                    rs <= 1'b0;
                    data <= 8'hC0; // Set cursor to the beginning of the second line
                    sel_dinamic <= WR_UM;
                end
                WR_UM: begin
                    rs <= 1'b1;
                    data <= data_in + 8'h30;
                    sel_dinamic <= SetCursor;
                end
            //     WR_C: begin
            //         rs <= 1'b1;
            //         data <= ((data_in%1000 - data_in%100)/100) + 8'h30;
            //         sel_dinamic <= WR_C;
            //     end
            //     WR_D: begin
            //         rs <= 1'b1;
            //         data <= ((data_in%100 - data_in%10)/10) + 8'h30;
            //         sel_dinamic <= WR_U;
            //     end
            //     WR_U: begin
            //         rs <= 1'b1;
            //         data <= (data_in%10) + 8'h30;
            //         sel_dinamic <= SetCursor;
            //     end
                endcase
            end
        endcase
    end
end
// Mensaje dinámico
always @(posedge clk) begin
    if (reset == 0) begin
        message[0]  <= "D";
        message[1]  <= "E";
        message[2]  <= "F";
        message[3]  <= "A";
        message[4]  <= "U";
        message[5]  <= "L";
        message[6]  <= "T";
        message[7]  <= " ";
        message[8]  <= " ";
        message[9]  <= " ";
        message[10] <= " ";
        message[11] <= " ";
        message[12] <= " ";
        message[13] <= " ";
        message[14] <= " ";
        message[15] <= "";

    end else begin
        case (sel_msg)
            2'b00:begin
                message[0]  <= "I";
                message[1]  <= "N";
                message[2]  <= "G";
                message[3]  <= "R";
                message[4]  <= "E";
                message[5]  <= "S";
                message[6]  <= "A";
                message[7]  <= " ";
                message[8]  <= "U";
                message[9]  <= "S";
                message[10] <= "U";
                message[11] <= "A";
                message[12] <= "R";
                message[13] <= "I";
                message[14] <= "O";
                message[15] <= " ";                
            end
            2'b01:begin
                message[0]  <= "I";
                message[1]  <= "N";
                message[2]  <= "G";
                message[3]  <= "R";
                message[4]  <= "E";
                message[5]  <= "S";
                message[6]  <= "A";
                message[7]  <= " ";
                message[8]  <= "C";
                message[9]  <= "L";
                message[10] <= "A";
                message[11] <= "V";
                message[12] <= "E";
                message[13] <= " ";
                message[14] <= " ";
                message[15] <= " ";                
            end
            2'b10:begin
                message[0]  <= "A";
                message[1]  <= "B";
                message[2]  <= "I";
                message[3]  <= "E";
                message[4]  <= "R";
                message[5]  <= "T";
                message[6]  <= "O";
                message[7]  <= ".";
                message[8]  <= ".";
                message[9]  <= ".";
                message[10] <= " ";
                message[11] <= " ";
                message[12] <= " ";
                message[13] <= " ";
                message[14] <= " ";
                message[15] <= " ";                
            end
            2'b11:begin
                message[0]  <= " ";
                message[1]  <= "I";
                message[2]  <= "N";
                message[3]  <= "T";
                message[4]  <= "R";
                message[5]  <= "U";
                message[6]  <= "S";
                message[7]  <= "O";
                message[8]  <= " ";
                message[9]  <= ">";
                message[10] <= ":";
                message[11] <= "[";
                message[12] <= " ";
                message[13] <= " ";
                message[14] <= " ";
                message[15] <= " ";                
            end

        endcase
    end
end

assign enable = clk_16ms;

endmodule