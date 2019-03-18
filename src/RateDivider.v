module RateDivider_60frames(
	input clk,
	output reg [20:0] counter
);


	always @ (posedge clk)
	begin
		if (counter == 20'b0)
			counter <= 20'd833334;		// 60 Frames
		else
			counter <= counter - 1'b1;
	end


endmodule
