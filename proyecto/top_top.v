module top_top #(parameter cona = 4693)(
input clk;
input [3:0] columns;
input [3:0] rows;
input boton; //pulsador de adentro
input reed; //sensor magnetico
output pos_sel; //del servo
input resetl;
input ready_i;

input   reset,  //reset de solo el ultrasonido
input   echo,        // Señal del sensor (ECHO)
output reg  trigger, // Señal de disparo (TRIGGER)

output buzz; //buzzer de alerta, debe ser un reg en su cajita

output servo; //servomotor debe ser un reg en su cajita

    
output reg rs,       
output reg rw,
output enable,    
output reg [DATA_BITS-1:0] data

);

wire nume;
wire [15:0] dista;

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

reg [6:0] SSeg,

  always @ ( * ) begin
    case (nume1)
      4'b0000: SSeg = 2'h30; // "0"  
  	  4'b0001: SSeg = 2'h31; // "1" 
  	  4'b0010: SSeg = 2'h32; // "2" 
  	  4'b0011: SSeg = 2'h33; // "3" 
  	  4'b0100: SSeg = 2'h34; // "4" 
  	  4'b0101: SSeg = 2'h35; // "5" 
  	  4'b0110: SSeg = 2'h36; // "6" 
  	  4'b0111: SSeg = 2'h37; // "7" 
  	  4'b1000: SSeg = 2'h38; // "8"  
  	  4'b1001: SSeg = 2'h39; // "9" 
      4'ha: SSeg = 2'h41;   //A
      4'hb: SSeg = 2'h42;   //B
      4'hc: SSeg = 2'h43;   //C
      4'hd: SSeg = 2'h44;   //D
      4'he: SSeg = 2'h2a;   //*
      4'hf: SSeg = 2'h23;   //#
       default: SSeg = 2'h30;
    endcase
  end


LCD1602_controller lcd(.clk(clk), .reset(resetl), .ready_i(ready_i), .in1(SSeg), .vis1(vis1), .rs(rs), .rw(rw), .enable(enable), .data(data))







// 16-20 Definir los estados de la FSM, param local: acceder desde afuera
localparam IDLE = 3'b000;
localparam STATE1 = 3'b001;
localparam STATE2 = 3'b010;
localparam STATE3 = 3'b011;
localparam STATE4 = 3'b100;
localparam STATEP = 3'b101;
localparam STATE6 = 3'b110;
localparam STATE7 = 3'b111;

reg [2:0] fsm_state;//el estado presente. el que va a saltar entre los valores de localparam
reg [2:0] next_state;

reg [1:0] j;

initial begin
    fsm_state <= IDLE;
    buzz <= 0
    pos_sel <= 0
    //hacer un beginin para lo mostrado en la LCD
    j=2'b00
end




always @(*) begin
    case(fsm_state)
        IDLE: begin //estado inicial
            next_state <= (u)? STATE1 : IDLE;
        end

        STATE1: begin 
            next_state <= (nume11 == A*)? STATE2 : (u==0)? IDLE : STATE1; //eso de A* es ilustrativo. se debe hacer nume11 que almacene temporalmente el ingreso por teclado
        end

        STATE2:begin
			next_state <= (nume11 == cona)? STATE3 : (u==0)? IDLE: STATE2; //eso de "cona", que es el parametro, es ilustrativo. se debe hacer nume11 que almacene temporalmente el ingreso por teclado
        end

        STATE3: begin 
            next_state <= (reed == 0)? STATE4 : STATE3;
        end

		STATE4: begin
			next_state <= (reed == 0)? STATE4 : IDLE;
		end
        
        STATEP:begin
			next_state <= (u)? STATEP : IDLE; 
        end

        default: next_state = IDLE;
    endcase
end

always @(posedge clk) begin
    if (reset == 0) begin
        buzz <= 0;
        pos_sel <= 1;
		j <= 2'b00;
        
    end else begin
        case (next_state)
            IDLE: begin
                buzz <= 0
                pos_sel <= 0
                //lcd <= " "
                vis1 <= 20 20 20 20 20 20 

            end
            STATE1: begin
                buzz <= 0
                pos_sel <= 0
                //lcd <= "ingrese perfil seguido de *"
                vis1 <= 69 6e 67 72 65 73 65 20 70 65 72 66 69 6c 20 79 20 2a
            end
            STATE2: begin
                buzz <= 0
                pos_sel <= 0
                //lcd <= "digite contraseña seguido de *"
                j=j + 2'b01
                vis1 <= 64 69 67 69 746520636f6e7472617365c3b161207365677569646f206465202a
            end
            STATE3: begin
                buzz <= 0
                pos_sel <= 1
                //lcd <= "Abierto"
            end
			STATE4: begin
                buzz <= 0
                pos_sel <= 1
                //lcd <= "Abierto"
            end
			STATEP: begin
                buzz <= 1
                pos_sel <= 0
                //lcd <= "Intruso"
                j=2'b00
            end


        endcase
    end
end





endmodule