module screen_refresh(
	input enable,
	input clk,
	output reg [7:0] vga_x_out,
	output reg [7:0] vga_y_out,
	output reg [7:0] R_buffer,
	output reg [7:0] B_buffer,
	output reg [7:0] G_buffer
);

	wire [15:0] counter_val;

	counter_16bit xycounter(
		.enable(enable),
		.clk(clk),
		.Q(counter_val)
	);
	
	always @ (counter_val)
	begin
		if (enable == 1'b1)
		begin
		vga_x_out <= counter_val[7:0];
		vga_y_out <= counter_val[15:8];
		
		R_buffer <= 8'b0;
		B_buffer <= 8'b0;
		G_buffer <= 8'b0;
		end
	end

endmodule

module counter_16bit(
	input enable,
	input clk,
	output reg [15:0] Q
);

	always @ (posedge clk)
	begin
		if (enable == 1'b1)
			Q <= Q + 1'b1;
	end

endmodule