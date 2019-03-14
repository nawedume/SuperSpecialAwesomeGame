module test_move(
    input CLOCK_50,
    input PS2_KBCLK,    // Keyboard clock
    input PS2_KBDAT,    // Keyboard input data
    output [4:0] LEDR
);

    wire scan_done_tick;
    wire [7:0] scan_out;
    wire [2:0] move_out;

    // instantiate ps2 receiver
    ps2_rx ps2_rx_unit (
        .clk(CLOCK_50),
        .reset(1'b0),
        .rx_en(1'b1),
        .ps2d(PS2_KBDAT),
        .ps2c(PS2_KBCLK),
        .rx_done_tick(scan_done_tick),
        .rx_data(scan_out)
    );

    // Get move
    move_control mymove(
        .keyboard_data(scan_out),
        .move(move_out)
    );

    reg [4:0] l;


    always @ (posedge CLOCK_50)
        begin
        if (scan_done_tick == 1'b0)
        begin
            case (move_out)
                3'b001: l <= 5'b00001;
                3'b010: l <= 5'b00010;  
                3'b011: l <= 5'b00100;  
                3'b100: l <= 5'b01000;  
                3'b101: l <= 5'b10000; 
            default: l <= 5'b00000;
            endcase
        end
        else
        begin
            l <= 5'b00000;
        end
    end
    
    assign LEDR = l;

endmodule
