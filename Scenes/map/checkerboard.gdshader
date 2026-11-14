shader_type canvas_item;

uniform int bands = 20;
uniform int black_spacing = 1;
uniform int white_spacing = 1;

uniform vec4 color1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color2 : source_color = vec4(1.0);

void fragment() {
	float x = floor(UV.x * float(bands));
	float y = floor(UV.y * float(bands));

	float total = float(black_spacing + white_spacing);

	float cell_x = mod(x, total);
	float cell_y = mod(y, total);

	bool black = (cell_x < float(black_spacing)) == (cell_y < float(black_spacing));

	COLOR = black ? color1 : color2;
}