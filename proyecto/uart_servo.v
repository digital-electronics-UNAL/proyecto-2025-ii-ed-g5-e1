module uart_servo (
    input wire clk,
    input wire rst,
    input wire rx_pin,
    output wire servo_pwm
);

uart_lock_control uart_lock_inst (
    .clk(clk),        // Conectar al reloj principal
    .rst(rst),        // Conectar a la señal de reset
    .rx_pin(rx_pin),     // Conectar al pin RX del UART
    .lock_open(pos_sel)   // Salida de control de la cerradura
);

wire pos_sel;

servo_control servo_inst (
    .clk(clk),         // Conectar al reloj principal
    .pos_sel(pos_sel),     // Conectar a la señal de selección de posición
    .servo_pwm(servo_pwm)    // Salida PWM al servo
);
endmodule
