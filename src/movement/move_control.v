module move_control(
    input [7:0] keyboard_data,
    output reg [2:0] move
);

    always @ (*)
        begin 
        case (keyboard_data)
            8'h75: move = 3'b010; // 3'b001;   // UP
            8'h6B: move = 3'b001; // 3'b010;   // LEFT
            8'h72: move = 3'b100; // 3'b011;   // DOWN
            8'h74: move = 3'b011; //3'b100;   // RIGHT
            8'h1A: move = 3'b101;   // ATTACK
        default: move = 3'b000; // Do nothing
        endcase
    end
endmodule