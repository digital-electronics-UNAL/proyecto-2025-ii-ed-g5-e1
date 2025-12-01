module ultrasonico_hcsr04 (
    input   clk,         // Reloj a 50 MHz
    input   reset,
    input   echo,        // Señal del sensor (ECHO)
    output reg  trigger,     // Señal de disparo (TRIGGER)
    output reg [15:0] distancia_cm  // Distancia medida
);

//------------------------------------------
// PARÁMETROS
//------------------------------------------
localparam CLK_FREQ = 50000000;     // 50 MHz
localparam TRIG_TIME = 500;         // 10 us / 20 ns = 500 ciclos
localparam MEAS_TIMEOUT = 30000;    // ~30 ms en ciclos de 1 us

//------------------------------------------
// DIVISOR PARA OBTENER TICK DE 1 us
//------------------------------------------
reg [5:0] us_count = 0;
reg tick_1us = 0;

always @(posedge clk) begin
    if (us_count == 49) begin
        us_count <= 0;
        tick_1us <= 1;
    end else begin
        us_count <= us_count + 1;
        tick_1us <= 0;
    end
end

//------------------------------------------
// ESTADOS DEL CONTROL
//------------------------------------------
localparam IDLE      = 0,
           TRIGGER   = 1,
           WAIT_ECHO = 2,
           MEASURE   = 3,
           DONE      = 4;

reg [2:0] state = IDLE;
reg [15:0] us_timer = 0;
reg [15:0] echo_width = 0;

//------------------------------------------
// MAQUINA DE ESTADOS PRINCIPAL
//------------------------------------------
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        trigger <= 0;
        us_timer <= 0;
        echo_width <= 0;
        distancia_cm <= 0;
    end else if (tick_1us) begin  // ejecuta cada 1us

        case (state)

        //------------------------------------------
        IDLE:
        begin
            trigger <= 1;
            us_timer <= 0;
            state <= TRIGGER;
        end

        //------------------------------------------
        TRIGGER:  // Mantener 10us el pulso Trigger
        begin
            if (us_timer < 10) begin
                us_timer <= us_timer + 1;
                trigger <= 1;
            end else begin
                trigger <= 0;
                us_timer <= 0;
                state <= WAIT_ECHO;
            end
        end

        //------------------------------------------
        WAIT_ECHO:  // Esperar a que ECHO se ponga en alto
        begin
            if (echo) begin
                us_timer <= 0;
                state <= MEASURE;
            end else if (us_timer > MEAS_TIMEOUT) begin
                distancia_cm <= 16'hFFFF; // Sin lectura
                state <= IDLE;
            end else begin
                us_timer <= us_timer + 1;
            end
        end

        //------------------------------------------
        MEASURE:   // Medir duración del pulso ECHO
        begin
            if (echo) begin
                echo_width <= echo_width + 1;  // cada tick = 1us
            end else begin
                distancia_cm <= echo_width / 58;  // cálculo de distancia
                echo_width <= 0;
                state <= DONE;
            end
        end

        //------------------------------------------
        DONE:
        begin
            // repetir medición
            state <= IDLE;
        end

        endcase
    end
end

endmodule




