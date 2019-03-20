module tiledrawer(
	input clk,
	input [7:0] tile_address_volitile,
	input [7:0] x_pos_volitile,
	input [7:0] y_pos_volitile,
	input draw,
	input [7:0] rom_request_data,
	output reg [11:0] rom_request_address,
	output reg vga_draw_enable,
	output reg [7:0] vga_x_out,
	output reg [7:0] vga_y_out,
	output reg [23:0] vga_RGB_out,
	output reg active
	);

	// init regs used for internal calcs 
	reg [7:0] x_in, y_in, x_out_buffer, y_out_buffer;
	reg [2:0] current_x, current_y;
	reg [7:0] R_out_buffer, G_out_buffer, B_out_buffer;
	reg [7:0] tile_address;
	reg load_R, load_G, load_B;
	reg row_finished, draw_pixel;

	// params for ease of reading
	localparam  S_INACTIVE 				= 8'd0,
				S_LOAD_INIT_VALUES 		= 8'd1,
				S_REQUEST_R				= 8'd2,
				S_REQUEST_G				= 8'd3,
				S_REQUEST_B 			= 8'd4,
				S_DRAW       			= 8'd5;
				S_CHECK_FINISHED_TILE   = 8'd6;

	// state table for FSM of tiledrawer
	always @(*)
	begin: state_table 
			case (current_state)
				S_INCATIVE: next_state = draw ? S_LOAD_INIT_VALUES : S_INACTIVE; // check ? load if true : load if false
				S_LOAD_INIT_VALUES: next_state = S_REQUEST_R;
				S_REQUEST_R: next_state = S_REQUEST_G;
				S_REQUEST_G: next_state = S_REQUEST_B;
				S_REQUEST_B: next_state = S_DRAW;
				S_DRAW: next_state = S_CHECK_FINISHED_TILE; 
				S_CHECK_FINISHED_TILE: next_state = active ? S_REQUEST_R : S_INACTIVE;
			default: next_state = S_INACTIVE;
		endcase
	end 

	
	// control path
	always @(*)
	begin: control
		// set load signals to 0 by default
		load_R = 1'b0;
		load_G = 1'b0;
		load_B = 1'b0;
		row_finished = 1'b0;
		draw_pixel = 1'b0;
		case (current_state)
			// at start of every tile, load the relative x/y and tile address, then reset the internal counters
			S_LOAD_INIT_VALUES: begin
				x_in = x_pos_volitile;
				y_in = y_pos_volitile;
				x_progress = 3'b000;
				y_progress = 3'b000;
				tile_address = tile_address_volitile;
			end

			// then request the RGB in 3 cycles to stay in pace with ROM
			S_REQUEST_R: begin
				rom_request_address = tile_address;
				load_R = 1'b1;
			end

			S_REQUEST_G: begin
				rom_request_address = tile_address + 2'b01;
				load_G = 1'b1;
			end

			S_REQUEST_B: begin
				rom_accces_address = tile_address + 2'b10;
				load_B = 1'b1;
			end

			// once all values for the pixel are loaded, draw the pixel
			S_DRAW: begin
				draw_pixel = 1'b1;
				x_out_buffer = current_x;
				y_out_buffer = current_y;
			end

			// and once the pixel is drawn, check to see if the row or tile is finished
			S_CHECK_FINISHED_TILE: begin
				if(current_x == 3'b111) begin
					row_finished = 1'b1;
					if(current_y == 3'b111) begin
						active = 1'b0;
					end
				end
			end

			default: begin
				x_buffer = 7'b0;
				y_buffer = 7'b0;
				x_progress = 2'b0;
				y_progress = 2'b0;
				active_buffer = 1'b0;
				row_finished = 1'b0;
				load_R = 1'b0;
				load_G = 1'b0;
				load_B = 1'b0;
				end
		endcase
	end


	always@(posedge clk) 
	begin: datapath

		if(load_R)
			R_out_buffer <= rom_request_data;
		if(load_G)
			G_out_buffer <= rom_request_data;
		if(load_B)
			B_out_buffer <= rom_request_data;

		// check if a pixel is being drawn this cycle
		if(draw_pixel = 1'b1;) begin
			// if so, load the buffer values and update the pixel address to the next one
			vga_x_out <= x_out_buffer;
			vga_y_out <= y_out_buffer;
			vga_RGB_out <= {R_out_buffer, G_out_buffer, B_out_buffer};
			tile_address <= tile_address + 2'b11;
			vga_draw_enable <= 1'b1;
		else begin
			// if not, disable the vga draw output
			vga_draw_enable <= 1'b0;
		end
		
		// check if the drawn pixels are at the end of a row
		if(row_finished == 1'b0) begin
			// if so, inc the x
			current_x = current_x + 1'b1;
		else begin
			// otherwise reset the x, inc the y, and reset the row
			current_x = 3'b000;
			current_y = current_y + 1'b1;
			row_finished <= 1'b0;
		end
		
		// move to next state after all logic
		current_state <= next_state;
		
	end
	
endmodule