module top_top #(parameter cona = 4693)(
input clk,
input [3:0] columns,
input [3:0] rows,
input boton, //pulsador de adentro
input reed, //sensor magnetico
output pos_sel, //del servo
input resetl, //del LCD
input ready_i,
input resett,
input   reset,  //reset del ultrasonido, y concatenado DE TODO EL PROCESO DE LA FIR
input   echo,        // Señal del sensor (ECHO)
output reg  trigger, // Señal de disparo (TRIGGER)

output buzz, //buzzer de alerta, debe ser un reg en su cajita

output pwmservo, //señal de control al servomotor

output reg p, //fuente de las resistencias pull up para teclado
    
output reg rs,       
output reg rw,
output enable,    
output reg [DATA_BITS-1:0] data

);





//del ultrasonido:

wire u;

hcsr04_distancia ultra (
     .clk(clk),          
    .rst(reset),        
    .echo(echo),         
     .trigger(trigger),  
     .salida(u)       
);

//del servomotor:


servo_control servom(.clk(clk), .pos_sel(pos_sel), .servo_pwm(pwmservo));










//del teclado y codifica:

wire [3:0] dig1;

teclado teclas(.clk(clk), .rst(resett), .column(columns), .row(rows), .digito(dig1), .key_detected(), .p(p) );

codahexa codes(.digdec(dig1), .dighex(digitoalcd)); //el que entra a la lcd

//la lcd:



//LCD1602_controller lcd(.clk(clk), .reset(resetl), .ready_i(ready_i), .in1(SSeg), .vis1(vis1), .rs(rs), .rw(rw), .enable(enable), .data(data))



//hasta aqui la lcd












// 16-20 Definir los estados de la FSM, param local: acceder desde afuera
localparam IDLE = 3'b000;
localparam STATE1 = 3'b001;
localparam STATE2 = 3'b010;
localparam STATE3 = 3'b011;
localparam STATE4 = 3'b100;
localparam STATEP = 3'b101; //hasta aqui
//localparam STATE6 = 3'b110;
//localparam STATE7 = 3'b111;

reg [2:0] fsm_state;//el estado presente. el que va a saltar entre los valores de localparam
reg [2:0] next_state;

reg [1:0] j;

/*initial begin
    fsm_state <= IDLE;
    buzz <= 0
    pos_sel <= 0
    //hacer un beginin para lo mostrado en la LCD
    j=2'b00
end */




always @(*) begin
    case(fsm_state)
        IDLE: begin //estado inicial
            next_state <= (u)? STATE1 : (boton)? STATE3 : IDLE;
        end

        STATE1: begin 
            next_state <= (nume11 == A*)? STATE2 : (u==0)? IDLE : STATE1; //eso de A* es ilustrativo. se debe hacer nume11 que almacene temporalmente el ingreso por teclado
        end

        STATE2:begin
			next_state <= (nume11 == cona)? STATE3 : (u==0)? IDLE: (j==2'b10)?  STATEP :  STATE2 ; //eso de "cona", que es el parametro, es ilustrativo. se debe hacer nume11 que almacene temporalmente el ingreso por teclado
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
    if (reset == 0) begin //ver si esto es con logica negada. Si dejarlo asi, o con reset==1
        buzz <= 0;
        pos_sel <= 1;
		j <= 2'b00;
        
    end else begin
        case (next_state)
            IDLE: begin
                buzz <= 0
                pos_sel <= 0
                //lcd <= " "
                mns <= 20 

            end
            STATE1: begin
                buzz <= 0
                pos_sel <= 0
                // esc<= algo
                mns <= 2'b00 //texto estatico
            end
            STATE2: begin
                buzz <= 0
                pos_sel <= 0
               // esc<=algo
                j=j + 2'b01
                mns <= 2'b01 //texto estatico
            end
            STATE3: begin
                buzz <= 0
                pos_sel <= 1
                mns <= 2'b10 //texto estatico
            end
			STATE4: begin
                buzz <= 0
                pos_sel <= 1
                mns <= 2'b10 //texto estatico
            end
			STATEP: begin
                buzz <= 1
                pos_sel <= 0
                mns <= 2'b11 //texto estatico
                j=2'b00
            end


        endcase
    end
end





endmodule