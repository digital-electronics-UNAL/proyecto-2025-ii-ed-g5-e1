module reed(clk, z, t);
    input clk;
    input z;
    output reg t;


    always @(posedge clk) begin
        if (z == 0 ) begin //z es reedswitch. en 0, significa switch abierto, o sea puerta abierta
        t <=1 //t=1 significa puerta abierta, servomotor en posicion de abierto, y viceversa
        end else if (z == 1 ) begin
            t <= 0; 
            end //toca hacer logicacombinacional para que funcione a la par con los otros metodos de abrir
        end //toca agregar en el top, otro estado en donde haya tiempo de abrir la puerta, con una transision razonable de tiempo
       

endmodule