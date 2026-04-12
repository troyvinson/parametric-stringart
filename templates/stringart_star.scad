// MIT License
//
// Copyright (c) 2026 Troy Vinson
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/* [Star Frame Settings] */
// 1. The total outer diameter of the star.
frame_width = 160; // min:100
// 2. How many points the star has.
star_points = 5; // [5:1:8]
// 3. How deep the valleys of the star go (0.2 = very pointy, 0.8 = almost a circle).
inner_radius_ratio = 0.4; // [0.1:0.05:0.9]
// 4. The thickness of the model (Z-axis).
frame_depth = 30; // 
// 5. The thickness of the frame wall.
frame_thickness = 10;
// 6. Corner rounding.
outer_corner_radius = 3; // [0:1:20]
// 7. Interior valley rounding.
inner_corner_radius = 3; // [0:1:20]
// 8. Color
frame_color = "#CCCCCC"; // color

/* [Center Object] */
svg_file = "default.svg";
object_scale_percent = 100;
object_offset_x = 0;
object_offset_y = 0;
object_color = "#CCCCCC";

/* [String (Ray) Settings] */
strings_per_row = 28;
string_rows = 5;
string_margin = 4;
convergence_y_offset = 0; 
alternate_rotation = true;
string_color = "#CCCCCC";

/* [Center Void] */
void_shape = "None"; 
void_width = 20;
void_height = 20;

/* [Hidden] */
$fn = 120; 
string_embed_percent = 50; 
string_clearance = 0.1; 
string_width = 0.61; 
string_height = 0.41;
frame_height = frame_width; // Stars are roughly circular in bounds

// --- Execution ---
union() {
    color(frame_color) base_frame();
    center_shape();
    color(string_color) rays();
}

// --- Modules ---

module star_polygon(d, points, ratio) {
    r_outer = d / 2;
    r_inner = r_outer * ratio;
    count = points * 2;
    step = 360 / count;
    
    points_list = [
        for (i = [0 : count - 1])
            let (r = (i % 2 == 0) ? r_outer : r_inner)
            [r * cos(i * step + 90), r * sin(i * step + 90)]
    ];
    polygon(points_list);
}

module raw_outer_profile() {
    star_polygon(frame_width, star_points, inner_radius_ratio);
}

module outer_profile() {
    safe_r = min(outer_corner_radius, 10);
    if (safe_r > 0) {
        offset(r=safe_r) offset(r=-safe_r) raw_outer_profile();
    } else {
        raw_outer_profile();
    } 
}

module inner_profile() {
    module raw_inner_profile() {
        offset(delta=-frame_thickness) raw_outer_profile();
    }
    safe_r = min(inner_corner_radius, 10);
    if (safe_r > 0) {
        offset(r=safe_r) offset(r=-safe_r) raw_inner_profile();
    } else {
        raw_inner_profile();
    } 
}

module center_shape_solid() {
    scale_factor = (object_scale_percent / 100);
    translate([object_offset_x, object_offset_y, 0]) {
        color(object_color)
            linear_extrude(height=frame_depth, center=true) {
                scale([scale_factor, scale_factor]) {
                    if (svg_file == "default.svg" || svg_file == "") {
                        star_polygon(40, star_points, inner_radius_ratio);
                    } else {
                        import(file=svg_file, center=true);
                    }
                }
            }
    }
}