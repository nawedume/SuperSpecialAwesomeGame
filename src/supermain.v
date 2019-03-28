module supermain(
    input CLOCK_50,
    input KEY,
    input PS2_KBCLK,    // Keyboard clock
    input PS2_KBDAT,    // Keyboard input data

    // The ports below are for the VGA output.  Do not change.
    output VGA_CLK,   						//	VGA Clock
    output VGA_HS,							//	VGA H_SYNC
    output VGA_VS,							//	VGA V_SYNC
    output VGA_BLANK_N,					//	VGA BLANK
    output VGA_SYNC_N,						//	VGA SYNC
    output VGA_R,   						//	VGA Red[9:0]
    output VGA_G,	 						//	VGA Green[9:0]
    output VGA_B,   						//	VGA Blue[9:0]
    output [16:0] LEDR
);
    wire [19:0] frame_counter;
    RateDivider_60frames framedivider(
        .clk(CLOCK_50),
        .counter(frame_counter)
    );
    wire frame_reset;
    assign frame_reset = frame_counter == 20'b0;


    reg [4:0] player_x_pos;
    reg [4:0] player_y_pos;


    // instantiate ps2 receiver
    ps2_rx ps2_rx_unit (
        .clk(CLOCK_50),
        .reset(frame_reset),
        .rx_en(1'b1),
        .ps2d(PS2_KBDAT),
        .ps2c(PS2_KBCLK),
        .rx_done_tick(scan_done_tick),
        .rx_data(scan_out)
    );

    wire [2:0] move_out; 
    // Get move
    move_control mymove(
        .keyboard_data(scan_out),
        .move(move_out)
    );


    collision_detector cdec(
        .current_x_pos(player_x_pos),
        .current_y_pos(player_y_pos),
        .move(move_out),
        .map(2'b00),
        .new_x_pos(player_new_x),
        .new_y_pos(player_new_y)
    );

    reg [4:0] player_new_x;
    reg [4:0] player_new_y;

    always @ (posedge CLOCK_50)
    begin
        player_x_pos <= player_new_x;
        player_y_pos <= player_new_y;
    end

    wire [7:0] player_x_pixel;
    wire [6:0] player_y_pixel;

    assign player_x_pixel = 8 * player_x_pos;
    assign player_y_pixel = 8 * player_y_pos;


    /*
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [23:0] colour;
	tri0 writeEn;
	wire resetn_vga;
	assign resetn = KEY[0];

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x_pixel),
			.y(y_pixel),
			.plot(writeEn),

			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";



	wire [11:0] rom_address;
	wire [7:0] rom_data;
	wire drawtile;

	rom4096x8 myrom(
		.address(rom_address),
		.clock(CLOCK_50),
		.q(rom_data)
	);


    wire drawtile;
    wire [7:0] x_val;
    wire [7:0] y_val;

    wire active;
    screen_drawer screend(
        .clk(CLOCK_50),
        .draw(drawtile),
        .player_x_pos_volitile(player_x_pos),
        .player_y_pos_volitile(player_y_pos),
        .map_address_volitile(12'b001000000000),
        .rom_request_data(rom_data),
        .rom_request_address(rom_address),
        .vga_draw_enable_bus(writeEn),
		.vga_x_out_bus(x_val),
		.vga_y_out_bus(y_val),
		.vga_RGB_out_bus(colour),
		.draw(drawtile),
	    .active(active);
    );

    screen_refresh blackscreen(
        .clk(CLOCK_50),
        .enable(~KEY[1]),
        .vga_x_out_bus(x),
        .vga_y_out_bus(y),
        .vga_RGB_out_bus(colour),
        .vga_draw_enable_bus(writeEn),
        .done(drawtile)
    );*/

endmodule