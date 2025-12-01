module compt( clk_1, columns, rows, num);

input clk_1;
input [3:0] columns;
input [3:0] rows;
output reg [3:0] num;

initial begin
    num <= 4'b1111;
end

always @(posedge clk_1)
begin
    if(rows == 4'b1000)
    begin
        case(columns)
            4'b1000: begin num = 4'b0001; end 
            4'b0100: begin num = 4'b0010; end
            4'b0010: begin num = 4'b0011; end
            4'b0001: begin num = 4'b1010; end
            default: begin
                num = 4'b1111;
            end
        endcase
    end

    else if(rows == 4'b0100)
    begin
        case(columns)
            4'b1000: begin num = 4'b0100; end
            4'b0100: begin num = 4'b0101; end
            4'b0010: begin num = 4'b0110; end
            4'b0001: begin num = 4'b1011; end
            default: begin
            num = 4'b1111;
            end
        endcase
    end

    else if(rows == 4'b0010)
    begin
        case(columns)
            4'b1000: begin num = 4'b0111; end
            4'b0100: begin num = 4'b1000; end
            4'b0010: begin num = 4'b1001; end
            4'b0001: begin num = 4'b1100; end
            default: begin
                num = 4'b1111;
            end
        endcase
    end

    else if(rows == 4'b0001)
    begin
        case(columns)
            4'b1000: begin num = 4'b1110; end // * es 14 decimal
            4'b0100: begin num = 4'b0000; end
            4'b0010: begin num = 4'b1111; end // # es 15 decimal
            4'b0001: begin num = 4'b1101; end
            default: begin
                num = 4'b1111;
            end
        endcase
    end

    else begin
        num = 4'b1111;
    end
end

endmodule