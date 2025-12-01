module top_top #(parameter cona = 4693)(
input clk;
input [3:0] columns;
input [3:0] rows;
input boton; //pulsador de adentro
input reed; //sensor magnetico
input pos_sel; //del servo

input   reset,
input   echo,        // Señal del sensor (ECHO)
output reg  trigger, // Señal de disparo (TRIGGER)

output buzz; //buzzer de alerta, debe ser un reg en su cajita
output servo; //servomotor debe ser un reg en su cajita

);

wire nume;
wire dista;

ultrasonico_hcsr04 ultra(.clk(clk), .reset(reset), .echo(echo), .trigger(trigger), .distancia_cm(dista))

  always @(posedge clk) begin
        if (dista <10 ) begin 
            u <= 1; 
        end else if (dista >= 10 ) begin
            u <= 0;
            end 
       
    end


wire [3:0] nume1;

tecladoejtop teclas (.clk(clk), .columns(columns), .rows(rows), .nume(nume1));


// 16-20 Definir los estados de la FSM, param local: acceder desde afuera
localparam IDLE = 3'b000;
localparam STATE1 = 3'b001;
localparam STATE2 = 3'b010;
localparam STATE3 = 3'b011;
localparam STATE4 = 3'b100;
localparam STATE5 = 3'b101;
localparam STATE6 = 3'b110;
localparam STATE7 = 3'b111;

reg [2:0] fsm_state;//el estado presente. el que va a saltar entre los valores de localparam
reg [2:0] next_state;


initial begin
    fsm_state <= IDLE;
    buzz <= 0
    pos_sel <= 0
end




always @(*) begin
    case(fsm_state)
        IDLE: begin //estado inicial
            next_state <= (u)? STATE1 : IDLE;
        end

        STATE1: begin 
            next_state <= (nume11 == A*)? STATE2 : STATE1; //eso de A* es ilustrativo. se debe hacer nume11 que almacene temporalmente el ingreso por teclado
        end

        STATE2:begin
			next_state <= (nume11 == cona)? STATE3 : STATE2; //eso de "cona", que es el parametro, es ilustrativo. se debe hacer nume11 que almacene temporalmente el ingreso por teclado
        end

        STATE3: begin 
            next_state <= (reed == 0)? STATE4 : STATE3;
        end

		STATE4: begin
			next_state <= (reed == 0)? STATE4 : IDLE;
		end
        default: next_state = IDLE;
    endcase
end

always @(posedge clk_16ms) begin
    if (reset == 1) begin
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
				data <= static_data_mem[data_counter];
            end
            CONFIG_CMD2: begin
                data_counter <= 'b0;
				rs <= 1'b0; 
				data <= START_2LINE;
            end
			WR_STATIC_TEXT_2L: begin
                data_counter <= data_counter + 1;
                rs <= 1'b1; 
				data <= static_data_mem[NUM_DATA_PERLINE + data_counter];
            end
        endcase
    end
end





endmodule