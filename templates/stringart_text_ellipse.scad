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

/* [Ellipse Frame Settings] */
// 1. The total width of the outer frame.
frame_width = 160; // min:100
// 2. The total height of the outer frame.
frame_height = 160; // min:100
// 3. The thickness of the model from the build plate up (Z-axis).
frame_depth = 30; //
// 4. The thickness of the outer frame wall itself.
frame_thickness = 10;
// 5. Controls 2D corner rounding for the X/Y plane.
outer_corner_radius = 5; // [0:1:30]
// 6. Controls interior corner rounding.
inner_corner_radius = 5; // [0:1:30]
// 7. Flatten the bottom of the Ellipse so it can stand on a desk?
flatten_ellipse_bottom = true; // [true:Yes, false:No]
// 8. Color of the outer frame
frame_color = "#CCCCCC"; // color

/* [Text Settings] */
// 1. Text to display
text_string = "Troy";
// 2. Font to use
text_font = "Arial:style=Bold";
// 3. Size of the text
text_size = 20; // [5:1:100]
// 4. Letter spacing
text_spacing = 1; // [0.1:0.1:5]
// 5. Width of the solid outline around the text
text_outline_width = 3; // [0:0.5:20]
// 6. Height the text protrudes above the outline (use negative for debossing)
text_emboss_height = 2; // [-10:0.5:20]
// 7. Adjust scale to fit inside the frame (preserves aspect ratio)
object_scale_percent = 100; // [1:1:500]
// 8. Fine-tune positioning if the auto-center needs a slight nudge on the X-axis
object_offset_x = 0; // [-50:0.5:50]
// 9. Fine-tune positioning if the auto-center needs a slight nudge on the Y-axis
object_offset_y = 0; // [-50:0.5:50]
// 10. Color of the text outline base
text_outline_color = "#FFFFFF"; // color
// 11. Color of the embossed/debossed text
text_color = "#FF0000"; // color
/* [String (Ray) Settings] */
// 1. Number of strings wrapping around one full revolution.
strings_per_row = 28;
// 2. Number of vertical layers of strings.
string_rows = 5;
// 3. Z-axis margin to keep strings away from top and bottom frame faces.
string_margin = 4; // [0:0.5:10]
// 4. Shifts the convergence point of all strings up or down.
convergence_y_offset = 0;
// 5. Offset the angle of every other row for a woven look.
alternate_rotation = true; // [true:false]
// 6. Color of the strings/rays
string_color = "#CCCCCC"; // color

/* [Hidden] */
// High resolution for smooth curves.
$fn = 120;
// Variables locked from user adjustment.
string_embed_percent = 50;
string_clearance = 0.1;
string_width = 0.61;
string_height = 0.41;
flat_bottom_cutoff = 15;

center_mode = "text";
void_shape = "None";

// --- Execution ---
union() {
    color(frame_color) base_frame();
    center_shape();
    color(string_color) rays();
}

// --- Modules ---

module raw_outer_profile() {
    actual_cutoff = flatten_ellipse_bottom ? flat_bottom_cutoff : 0;
    cut_y = -frame_height/2 + actual_cutoff;

    difference() {
        scale([frame_width/frame_height, 1])
            circle(d=frame_height);

        // The slice
        translate([0, cut_y - 500])
            square([frame_width*3, 1000], center=true);
    }
}

module outer_profile() {
    safe_r = min(outer_corner_radius, frame_width/2.1, frame_height/2.1);
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

    safe_r = min(inner_corner_radius, (frame_width-frame_thickness)/2.1, (frame_height-frame_thickness)/2.1);
    if (safe_r > 0) {
        offset(r=safe_r) offset(r=-safe_r) raw_inner_profile();
    } else {
        raw_inner_profile();
    }
}


include <../core_engine.scad>
