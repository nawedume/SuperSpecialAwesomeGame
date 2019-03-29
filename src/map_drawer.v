module map_drawer(
	input clk,
	input [15:0] tile_address_volitile,
	input draw,
	input [23:0] rom_request_data,
	output [15:0] rom_address_bus,
	output vga_draw_enable_bus,
	output [7:0] vga_x_out_bus,
	output [7:0] vga_y_out_bus,
	output [23:0] vga_RGB_out_bus,
	output reg done
	);

	// init regs used for internal calcs 
	reg [7:0] x_out_buffer, y_out_buffer;
	reg [7:0] current_x;
	reg [7:0] current_y;
	reg [23:0] RGB_out_buffer;
	reg [15:0] tile_address;
	reg [7:0] current_state, next_state;
	reg [15:0] rom_address;

	reg [7:0] vga_x_out;
	reg [7:0] vga_y_out;
	reg [23:0] vga_RGB_out;

	reg [1:0] draw_pixel;
	reg reset_xy_load_tile_address;
	reg vga_draw_enable;
	reg active;

	assign vga_x_out_bus = active ? vga_x_out : 8'bzzzzzzzz;
	assign vga_y_out_bus = active ? vga_y_out : 8'bzzzzzzzz;
	assign vga_RGB_out_bus = active ? vga_RGB_out : 24'bzzzzzzzzzzzzzzzzzzzzzzzz;
	assign vga_draw_enable_bus = active ? vga_draw_enable : 1'bz;
	assign rom_address_bus = active ? rom_address : 16'bzzzzzzzzzzzzzzzz;

	// params for ease of reading
	localparam  S_INACTIVE 				= 8'd0,
				S_LOAD_INIT_VALUES 		= 8'd1,
				S_REQUEST_RGB			= 8'd11,
				S_SAVE_RGB				= 8'd12,
				S_DRAW					= 8'd13,
				S_CHECK_FINISHED_TILE   = 8'd14,
				S_DONE					= 8'd15;

	// state table for FSM of tiledrawer
	always @(*)
	begin: state_table 
			case (current_state)
				S_INACTIVE: next_state = draw ? S_LOAD_INIT_VALUES : S_INACTIVE; // check ? load if true : load if false
				S_LOAD_INIT_VALUES: next_state = S_REQUEST_RGB1;
				S_REQUEST_RGB1: next_state = S_REQUEST_RGB2;
				S_REQUEST_RGB2: next_state = S_REQUEST_RGB3;
				S_REQUEST_RGB3: next_state = S_REQUEST_RGB4;
				S_REQUEST_RGB4: next_state = S_REQUEST_RGB5;
				S_REQUEST_RGB5: next_state = S_SAVE_RGB;
				S_SAVE_RGB: next_state = S_DRAW;
				S_DRAW: next_state = S_CHECK_FINISHED_TILE; 
				S_CHECK_FINISHED_TILE: next_state = active ? S_REQUEST_RGB : S_DONE;
				S_DONE: next_state = S_INACTIVE;
			default: next_state = S_INACTIVE;
		endcase
	end 


	// control path
	always @(*)
	begin: control
		// set load signals to 0 by default
		active = 1'b1;
		done = 1'b0;
		draw_pixel = 2'b00;
		reset_xy_load_tile_address = 1'b0;
		case (current_state)
			// at start of every tile, load the relative x/y and tile address, then reset the internal counters
			S_LOAD_INIT_VALUES: begin
				reset_xy_load_tile_address = 1'b1;
			end

			S_REQUEST_RGB1: begin
				rom_address = tile_address;
			end
			S_REQUEST_RGB2: begin
				rom_address = tile_address;
			end
			S_REQUEST_RGB3: begin
				rom_address = tile_address;
			end
			S_REQUEST_RGB4: begin
				rom_address = tile_address;
			end
			S_REQUEST_RGB5: begin
				rom_address = tile_address;
			end

			S_SAVE_RGB: begin
				rom_address = tile_address;
				RGB_out_buffer = rom_request_data;
			end

			// once all values for the pixel rom_request_addressare loaded, draw the pixel
			S_DRAW: begin
				if(current_x == 8'b10100000) begin
					draw_pixel = 2'b10;
				end
				else begin
					draw_pixel = 2'b01;
				end
				y_out_buffer = current_y[7:0];
				x_out_buffer = current_x[7:0];
			end
			// and once the pixel is drawn, check to see if the row or tile is finished
			S_CHECK_FINISHED_TILE: begin
				if(current_y == 8'b01111000) begin
					active = 1'b0;
				end
			end

			S_DONE: begin
				done = 1'b1;
			end

			default: begin
				end
		endcase
	end


	always@(posedge clk) 
	begin: datapath


		if(reset_xy_load_tile_address) begin
			current_x <= 8'b00000000;
			current_y <= 8'b00000000;
			tile_address <= tile_address_volitile;
		end

		// check if a pixel is being drawn this cycle
		if(draw_pixel == 2'b01) begin
			// if so, load the buffer values and update the pixel address to the next one
			vga_x_out <= x_out_buffer;
			vga_y_out <= y_out_buffer;
			current_x <= current_x + 8'b00000001;
			vga_RGB_out <= RGB_out_buffer;
			tile_address <= tile_address + 16'b0000000000000001;
			vga_draw_enable <= 1'b1;
		end
		if(draw_pixel == 2'b10) begin
			// if so, load the buffer values and update the pixel address to the next one
			vga_x_out <= x_out_buffer;
			vga_y_out <= y_out_buffer;
			current_y <= current_y + 8'b00000001;
			current_x <= 8'b00000000;
			vga_RGB_out <= RGB_out_buffer;
			tile_address <= tile_address + 16'b0000000000000001;
			vga_draw_enable <= 1'b1;
		end
		if(draw_pixel == 2'b00) begin
			// if not, disable the vga draw output
			vga_draw_enable <= 1'b0;
		end
		
		// move to next state after all logic
		current_state <= next_state;
		
	end
	
endmodule
