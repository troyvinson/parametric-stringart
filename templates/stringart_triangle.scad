/* [Triangle Frame Settings] */
// 1. The total point-to-point width of the outer frame.
frame_width = 160; // min:100
// 2. The thickness of the model from the build plate up (Z-axis).
frame_depth = 30; // 
// 3. The thickness of the outer frame wall itself.
frame_thickness = 10;
// 4. Controls 2D corner rounding for the X/Y plane.
outer_corner_radius = 5; // [0:1:30]
// 5. Controls interior corner rounding.
inner_corner_radius = 5; // [0:1:30]
// 6. Color of the outer frame
frame_color = "#CCCCCC"; // color

/* [Center Object] */
// 1. Upload your custom SVG artwork.
svg_file = "default.svg";
// 2. Adjust scale to fit inside the frame (preserves aspect ratio).
object_scale_percent = 100; // [1:1:500]
// 3. Fine-tune positioning if the auto-center needs a slight nudge on the X-axis.
object_offset_x = 0; // [-50:0.5:50]
// 4. Fine-tune positioning if the auto-center needs a slight nudge on the Y-axis.
object_offset_y = 0; // [-50:0.5:50]
// 5. Color of the central SVG object
object_color = "#CCCCCC"; // color

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

/* [Center Void (Experimental)] */
// 1. Removes the chaotic center convergence point. 
void_shape = "None"; // [None, Ellipse, Rectangle, Hexagon, Heart]
// 2. Width of the center string cut.
void_width = 20; // [1:0.5:200]
// 3. Height of the center string cut.
void_height = 20; // [1:0.5:200]

/* [Hidden] */
$fn = 120; 
string_embed_percent = 50; 
string_clearance = 0.1; 
string_width = 0.6; 
string_height = 0.4;

// Calculate equilateral height based on circumradius width
frame_height = (frame_width / 2) * 1.5;

// --- Execution ---
union() {
    color(frame_color) base_frame();
    center_shape();
    color(string_color) rays();
}

// --- Modules ---

module raw_outer_profile() {
    // Rotated 90 degrees to point UP and sit flat on the bottom
    rotate([0, 0, 90])
        circle(d=frame_width, $fn=3);
}

module outer_profile() {
    safe_r = min(outer_corner_radius, frame_width/4);
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
    safe_r = min(inner_corner_radius, (frame_width-frame_thickness)/4);
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
                        circle(d=35, $fn=3);
                    } else {
                        import(file=svg_file, center=true);
                    }
                }
            }
    }
}