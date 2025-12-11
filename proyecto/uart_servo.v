module uart_servo (
    input wire clk,
    input wire rst,
    input wire rx_pin,
    output wire servo_pwm,
    output reg buzzer
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

reg [$clog2(50000000)-1:0] buzzer_counter = 0;

reg pos_act;
reg pos_ant;

localparam WAIT_POS_CHANGE = 1'b0;
localparam BUZZER_ON       = 1'b1;
reg state_buzzer = WAIT_POS_CHANGE;
always @(posedge clk) begin
    pos_act <= pos_sel;
    pos_ant <= pos_act;

    case (state_buzzer)
        WAIT_POS_CHANGE: begin
            if (pos_act != pos_ant) begin
                state_buzzer <= BUZZER_ON;
                buzzer_counter <= 0;
                buzzer <= 0;
            end
        end

        BUZZER_ON: begin
            if (buzzer_counter < 50000000 - 1) begin
                buzzer_counter <= buzzer_counter + 1;
            end else begin
                state_buzzer <= WAIT_POS_CHANGE;
                buzzer <= 1;
            end
        end
    endcase
end

endmodule
