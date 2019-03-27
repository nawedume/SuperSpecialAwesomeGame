module collision_detector(
    input [22:0] current_x_pos,
    input [14:0] current_y_pos,
    input [1:0] move,
    input [2:0] map,
    output [22:0] new_x_pos,
    output [14:0] new_y_pos
);

    reg [22:0] current_map [0:14];
    reg [22:0] map1 [0:14];
    reg [22:0] map2 [0:14];
    reg [22:0] map3 [0:14];
    reg [22:0] map4 [0:14];

    // Draw maps here
    // MAP 1
    initial begin
        map1[0] = 15'b111111111111111;
        map1[2] = 15'b100000000000001;
        map1[3] = 15'b100000000000001;
        map1[4] = 15'b100000000000001;
        map1[5] = 15'b100000000000001;
        map1[6] = 15'b100000000000001;
        map1[7] = 15'b100000000000001;
        map1[8] = 15'b100000000000001;
        map1[9] = 15'b100000000000001;
        map1[10] = 15'b100000000000001;
        map1[11] = 15'b100000000000001;
        map1[12] = 15'b100000000000001;
        map1[13] = 15'b100000000000001;
        map1[14] = 15'b111111111111111;
    end
    
    // MAP 2
    initial begin
        map1[0] = 15'b111111111111111;
        map1[2] = 15'b100000000000001;
        map1[3] = 15'b100000000000001;
        map1[4] = 15'b100000000000001;
        map1[5] = 15'b100000000000001;
        map1[6] = 15'b100000000000001;
        map1[7] = 15'b100000000000001;
        map1[8] = 15'b100000000000001;
        map1[9] = 15'b100000000000001;
        map1[10] = 15'b100000000000001;
        map1[11] = 15'b100000000000001;
        map1[12] = 15'b100000000000001;
        map1[13] = 15'b100000000000001;
        map1[14] = 15'b111111111111111;
    end

    // MAP 3
    initial begin
        map1[0] = 15'b111111111111111;
        map1[2] = 15'b100000000000001;
        map1[3] = 15'b100000000000001;
        map1[4] = 15'b100000000000001;
        map1[5] = 15'b100000000000001;
        map1[6] = 15'b100000000000001;
        map1[7] = 15'b100000000000001;
        map1[8] = 15'b100000000000001;
        map1[9] = 15'b100000000000001;
        map1[10] = 15'b100000000000001;
        map1[11] = 15'b100000000000001;
        map1[12] = 15'b100000000000001;
        map1[13] = 15'b100000000000001;
        map1[14] = 15'b111111111111111;
    end
    
    // MAP 4
    initial begin
        map1[0] = 15'b111111111111111;
        map1[2] = 15'b100000000000001;
        map1[3] = 15'b100000000000001;
        map1[4] = 15'b100000000000001;
        map1[5] = 15'b100000000000001;
        map1[6] = 15'b100000000000001;
        map1[7] = 15'b100000000000001;
        map1[8] = 15'b100000000000001;
        map1[9] = 15'b100000000000001;
        map1[10] = 15'b100000000000001;
        map1[11] = 15'b100000000000001;
        map1[12] = 15'b100000000000001;
        map1[13] = 15'b100000000000001;
        map1[14] = 15'b111111111111111;
    end

    
    reg [22:0] temp_x;
    reg [14:0] temp_y;

    
    reg cc;
    
    // Check if collision happened with new values
    always @ (*)
    begin
      case (map)
        2'b00: cc <= map1[temp_x][temp_y];
        2'b01: cc <= map2[temp_x][temp_y];
        2'b10: cc <= map3[temp_x][temp_y];
        2'b11: cc <= map4[temp_x][temp_y];
      endcase
    end

    always @ (*)
    begin

        if (move == 3'b000) begin   // RIGHT
                temp_x <= current_x_pos + 1'b1;
                temp_y <= current_y_pos;
            end
        
        else if (move == 3'b001) begin   // UP
                temp_x <= current_x_pos;
                temp_y <= current_y_pos - 1'b1;
            end
        
        else if (move == 3'b010) begin      // LEFT
                temp_x <= current_x_pos - 1'b1;
                temp_y <= current_y_pos;
            end
        
        else if (move == 3'b011) begin       // DOWN
                temp_x <= current_x_pos;
                temp_y <= current_y_pos + 1'b1;
            end
        
        else begin
            temp_x = current_x_pos;
            temp_y = current_y_pos;
        end

    end

    // If collision happened retatin old value, if not go to new.
    assign new_x_pos = cc ? current_x_pos : temp_x;
    assign new_y_pos = cc ? current_y_pos : temp_y;
endmodule
