module tiledrawer(
	input clk,
	input [11:0] tile_address_volitile,
	input [7:0] x_pos_volitile,
	input [7:0] y_pos_volitile,
	input draw,
	input [7:0] rom_request_data,
	output reg [11:0] rom_request_address,
	output vga_draw_enable_bus,
	output [7:0] vga_x_out_bus,
	output [7:0] vga_y_out_bus,
	output [23:0] vga_RGB_out_bus,
	output [7:0] statetestout,
	output [23:0] rgbtestout,
	output reg active
	);
	assign statetestout = current_state;
	assign rgbtestout = {R_out_buffer, G_out_buffer, B_out_buffer};
	// init regs used for internal calcs 
	reg [7:0] x_in, y_in, x_out_buffer, y_out_buffer;
	reg [6:0] current_xy;
	reg [7:0] R_out_buffer, G_out_buffer, B_out_buffer;
	reg [11:0] tile_address;
	reg load_R, load_G, load_B,request_data;
	reg draw_pixel, reset_xy_load_tile_address;
	reg [7:0] current_state, next_state;
	reg [11:0] rom_request_address_buffer;

	reg [7:0] vga_x_out;
	reg [7:0] vga_y_out;
	reg [23:0] vga_RGB_out;
	reg vga_draw_enable;

	assign vga_x_out_bus = active ? vga_x_out : 8'bzzzzzzzz;
	assign vga_y_out_bus = active ? vga_y_out : 8'bzzzzzzzz;
	assign vga_RGB_out_bus = active ? vga_RGB_out : 24'bzzzzzzzzzzzzzzzzzzzzzzzz;
	assign vga_draw_enable_bus = active ? vga_draw_enable : 1'bz;

	// params for ease of reading
	localparam  S_INACTIVE 				= 8'd0,
				S_LOAD_INIT_VALUES 		= 8'd1,
				S_REQUEST_R				= 8'd2,
				S_SAVE_R				= 8'd3,
				S_POSTSAVE_R			= 8'd4,
				S_REQUEST_G				= 8'd5,
				S_SAVE_G				= 8'd6,
				S_POSTSAVE_G			= 8'd7,
				S_REQUEST_B 			= 8'd8,
				S_SAVE_B				= 8'd9,
				S_POSTSAVE_B			= 8'd10,
				S_DRAW					= 8'd11,
				S_CHECK_FINISHED_TILE   = 8'd12;

	// state table for FSM of tiledrawer
	always @(*)
	begin: state_table 
			case (current_state)
				S_INACTIVE: next_state = draw ? S_LOAD_INIT_VALUES : S_INACTIVE; // check ? load if true : load if false
				S_LOAD_INIT_VALUES: next_state = S_REQUEST_R;
				S_REQUEST_R: next_state = S_SAVE_R;
				S_SAVE_R: next_state = S_POSTSAVE_R;
				S_POSTSAVE_R: next_state = S_REQUEST_G;
				S_REQUEST_G: next_state = S_SAVE_G;
				S_SAVE_G: next_state = S_POSTSAVE_G;
				S_POSTSAVE_G: next_state = S_REQUEST_B;
				S_REQUEST_B: next_state = S_SAVE_B;
				S_SAVE_B: next_state = S_POSTSAVE_B;
				S_POSTSAVE_B: next_state = S_DRAW;
				S_DRAW: next_state = S_CHECK_FINISHED_TILE; 
				S_CHECK_FINISHED_TILE: next_state = active ? S_REQUEST_R : S_INACTIVE;
			default: next_state = S_INACTIVE;
		endcase
	end 


	// control path
	always @(*)
	begin: control
		// set load signals to 0 by default
		active = 1'b1;
		load_R = 1'b0;
		load_G = 1'b0;
		load_B = 1'b0;
		request_data = 1'b0;
		draw_pixel = 1'b0;
		reset_xy_load_tile_address = 1'b0;
		rom_request_address_buffer = 12'b000000000000;
		case (current_state)
			// at start of every tile, load the relative x/y and tile address, then reset the internal counters
			S_LOAD_INIT_VALUES: begin
				x_in = x_pos_volitile;
				y_in = y_pos_volitile;
				reset_xy_load_tile_address = 1'b1;
			end

			// then request the RGB in 3 cycles to stay in pace with ROM
			S_REQUEST_R: begin
				rom_request_address_buffer = tile_address;
				request_data = 1'b1;
			end

			S_SAVE_R: begin
				rom_request_address_buffer = tile_address;
				request_data = 1'b1;
			end

			S_POSTSAVE_R: begin
				rom_request_address_buffer = tile_address;
				request_data = 1'b1;
				//load_R = 1'b1;
				R_out_buffer = rom_request_data;
			end

			S_REQUEST_G: begin
				rom_request_address_buffer = tile_address + 12'b000000000001;
				request_data = 1'b1;
			end

			S_SAVE_G: begin
				rom_request_address_buffer = tile_address + 12'b000000000001;
				request_data = 1'b1;
			end

			S_POSTSAVE_G: begin
				rom_request_address_buffer = tile_address + 12'b000000000001;
				request_data = 1'b1;
				//load_G = 1'b1;
				G_out_buffer = rom_request_data;
			end

			S_REQUEST_B: begin
				rom_request_address_buffer = tile_address + 12'b000000000010;
				request_data = 1'b1;
			end

			S_SAVE_B: begin
				rom_request_address_buffer = tile_address + 12'b000000000010;
				request_data = 1'b1;
			end

			S_POSTSAVE_B: begin
				rom_request_address_buffer = tile_address + 12'b000000000010;
				request_data = 1'b1;
				//load_B = 1'b1;
				B_out_buffer = rom_request_data;
			end

			// once all values for the pixel are loaded, draw the pixel
			S_DRAW: begin
				draw_pixel = 1'b1;
				y_out_buffer = x_in + current_xy[5:3];
				x_out_buffer = y_in + current_xy[2:0];
			end
			// and once the pixel is drawn, check to see if the row or tile is finished
			S_CHECK_FINISHED_TILE: begin
				if(current_xy == 7'b1000000) begin
					active = 1'b0;
				end
			end

			default: begin
				rom_request_address_buffer = 12'b000000000000;
				reset_xy_load_tile_address = 1'b0;
				draw_pixel = 1'b0;
				request_data = 1'b0;
				load_R = 1'b0;
				load_G = 1'b0;
				load_B = 1'b0;
				active = 1'b0;
				end
		endcase
	end


	always@(posedge clk) 
	begin: datapath

		if(request_data)
			rom_request_address <= rom_request_address_buffer;
		//if(load_R)
		//	R_out_buffer <= rom_request_data;
		//if(load_G)
		//	G_out_buffer <= rom_request_data;
		//if(load_B)
		//	B_out_buffer <= rom_request_data;

		if(reset_xy_load_tile_address) begin
			current_xy <= 6'b000000;
			tile_address <= tile_address_volitile;
		end

		// check if a pixel is being drawn this cycle
		if(draw_pixel == 1'b1) begin
			// if so, load the buffer values and update the pixel address to the next one
			vga_x_out <= x_out_buffer;
			vga_y_out <= y_out_buffer;
			current_xy <= current_xy + 7'b0000001;
			vga_RGB_out <= {R_out_buffer, G_out_buffer, B_out_buffer};
			//vga_RGB_out <= 24'hFFFFFF;
			tile_address <= tile_address + 12'b000000000011;
			vga_draw_enable <= 1'b1;
		end
		else begin
			// if not, disable the vga draw output
			vga_draw_enable <= 1'b0;
		end
		
		// move to next state after all logic
		current_state <= next_state;
		
	end
	
endmodule
