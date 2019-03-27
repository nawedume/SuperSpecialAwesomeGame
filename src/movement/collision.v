module collision_detector(
    input [5:0] current_x_pos,
    input [5:0] current_y_pos,
    input [1:0] move,
    input [2:0] map,
    output [5:0] new_x_pos,
    output [5:0] new_y_pos
);

    reg [22:0] current_map [0:14];
    reg [22:0] map1 [0:14];
    reg [22:0] map2 [0:14];
    reg [22:0] map3 [0:14];
    reg [22:0] map4 [0:14];

    // Draw maps here
    // MAP 1
    initial begin
        map1[0] = 20'b11111111111111111111;
        map1[2] = 20'b10000000000000000001;
        map1[3] = 20'b10000000000000000001;
        map1[4] = 20'b10000000000000000001;
        map1[5] = 20'b10000000000000000001;
        map1[6] = 20'b10000000000000000001;
        map1[7] = 20'b10000000000000000001;
        map1[8] = 20'b10000000000000000001;
        map1[9] = 20'b10000000000000000001;
        map1[10] = 20'b10000000000000000001;
        map1[11] = 20'b10000000000000000001;
        map1[12] = 20'b10000000000000000001;
        map1[13] = 20'b10000000000000000001;
        map1[14] = 20'b10000000000000000001;
    end
    
    // MAP 2
    initial begin
        map1[0] = 20'b11111111111111111111;
        map1[2] = 20'b10000000000000000001;
        map1[3] = 20'b10000000000000000001;
        map1[4] = 20'b10000000000000000001;
        map1[5] = 20'b10000000000000000001;
        map1[6] = 20'b10000000000000000001;
        map1[7] = 20'b10000000000000000001;
        map1[8] = 20'b10000000000000000001;
        map1[9] = 20'b10000000000000000001;
        map1[10] = 20'b10000000000000000001;
        map1[11] = 20'b10000000000000000001;
        map1[12] = 20'b10000000000000000001;
        map1[13] = 20'b10000000000000000001;
        map1[14] = 20'b10000000000000000001;
    end

    // MAP 3
     initial begin
        map1[0] = 20'b11111111111111111111;
        map1[2] = 20'b10000000000000000001;
        map1[3] = 20'b10000000000000000001;
        map1[4] = 20'b10000000000000000001;
        map1[5] = 20'b10000000000000000001;
        map1[6] = 20'b10000000000000000001;
        map1[7] = 20'b10000000000000000001;
        map1[8] = 20'b10000000000000000001;
        map1[9] = 20'b10000000000000000001;
        map1[10] = 20'b10000000000000000001;
        map1[11] = 20'b10000000000000000001;
        map1[12] = 20'b10000000000000000001;
        map1[13] = 20'b10000000000000000001;
        map1[14] = 20'b10000000000000000001;
    end
    
    // MAP 4
    initial begin
        map1[0] = 20'b11111111111111111111;
        map1[2] = 20'b10000000000000000001;
        map1[3] = 20'b10000000000000000001;
        map1[4] = 20'b10000000000000000001;
        map1[5] = 20'b10000000000000000001;
        map1[6] = 20'b10000000000000000001;
        map1[7] = 20'b10000000000000000001;
        map1[8] = 20'b10000000000000000001;
        map1[9] = 20'b10000000000000000001;
        map1[10] = 20'b10000000000000000001;
        map1[11] = 20'b10000000000000000001;
        map1[12] = 20'b10000000000000000001;
        map1[13] = 20'b10000000000000000001;
        map1[14] = 20'b10000000000000000001;
    end

    
    reg [19:0] temp_x;
    reg [14:0] temp_y;

    
    reg cc;

    
    always @ (move)
    begin

        if (move == 3'b100) begin   // RIGHT
                temp_x = current_x_pos + 1'b1;
                temp_y = current_y_pos;
            end
        
        else if (move == 3'b001) begin   // UP
                temp_x = current_x_pos;
                temp_y = current_y_pos - 1'b1;
            end
        
        else if (move == 3'b010) begin      // LEFT
                temp_x = current_x_pos - 1'b1;
                temp_y = current_y_pos;
            end
        
        else if (move == 3'b011) begin       // DOWN
                temp_x = current_x_pos;
                temp_y = current_y_pos + 1'b1;
            end
        
        else begin
            temp_x = current_x_pos;
            temp_y = current_y_pos;
        end

    end
    
    // Check if collision happened with new values
    always @ (move)
    begin
      case (map)
        2'b00: cc = map1[temp_x][temp_y];
        2'b01: cc = map2[temp_x][temp_y];
        2'b10: cc = map3[temp_x][temp_y];
        2'b11: cc = map4[temp_x][temp_y];
      endcase
    end


    // If collision happened retatin old value, if not go to new.
    assign new_x_pos = cc ? current_x_pos : temp_x;
    assign new_y_pos = cc ? current_y_pos : temp_y;
endmodule
