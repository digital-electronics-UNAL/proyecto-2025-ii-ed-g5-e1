module servo_control(
    input wire clk,         // Reloj de 50 MHz
    input wire pos_sel,     // 0 → 0° , 1 → 90°
    output reg servo_pwm    // Señal PWM al servo
);

    // Parámetros del servo (en ciclos de reloj)
    localparam integer PERIOD_20MS = 1_000_000;  // 20 ms a 50 MHz
    localparam integer PULSE_0DEG  = 50_000;     // 1 ms  = 50,000 ciclos
    localparam integer PULSE_90DEG = 100_000;    // 2 ms  =100,000 ciclos

    reg [19:0] counter = 0;
    reg [19:0] pulse_width;

    always @(posedge clk) begin
        // Selección del ángulo
        if (pos_sel == 1'b0)
            pulse_width <= PULSE_0DEG;
        else
            pulse_width <= PULSE_90DEG;

        // Generación del PWM de 20 ms
        if (counter < PERIOD_20MS - 1)
            counter <= counter + 1;
        else
            counter <= 0;

        // PWM alto mientras el contador esté dentro del pulso
        servo_pwm <= (counter < pulse_width);
    end

endmodule