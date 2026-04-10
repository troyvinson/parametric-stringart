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
// 1. Removes the chaotic center convergence point. Recommended if your SVG is a hollow ring.
void_shape = "None"; // [None, Ellipse, Rectangle, Hexagon, Heart]
// 2. Width of the center string cut. Make this slightly smaller than the inner hole of your SVG.
void_width = 20; // [1:0.5:200]
// 3. Height of the center string cut (Only applies to Ellipse, Rectangle, and Heart).
void_height = 20; // [1:0.5:200]

/* [Hidden] */
// High resolution for smooth curves.
$fn = 120; 
// Variables locked from user adjustment.
string_embed_percent = 50; 
string_clearance = 0.1; 
string_width = 0.6; 
string_height = 0.4;
flat_bottom_cutoff = 15;

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

module center_shape_solid() {
    actual_cutoff = flatten_ellipse_bottom ? flat_bottom_cutoff : 0;
    y_shift = actual_cutoff / 2;
    scale_factor = (object_scale_percent / 100);

    translate([object_offset_x, object_offset_y + y_shift, 0]) {
        color(object_color)
            linear_extrude(height=frame_depth, center=true) {
                scale([scale_factor, scale_factor]) {
                    if (svg_file == "default.svg" || svg_file == "") {
                        circle(d=35);
                    } else {
                        import(file=svg_file, center=true);
                    }
                }
            }
    }
}