/* [Export Options] */
// 1. Select which part to preview or export.
part_to_render = "All"; // [Frame, Cradle Base, All]

/* [Heart Frame Settings] */
// 1. The total maximum height of the outer frame (Width is locked to proportion).
frame_height = 140; // min:100
// 2. The thickness of the model from the build plate up (Z-axis).
frame_depth = 30; // 
// 3. The thickness of the outer frame wall itself.
frame_thickness = 10;
// 4. Color of the outer frame
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

// Lock the width to maintain the traditional 160:140 (8:7) heart ratio
frame_width = frame_height * (8 / 7);

// --- Execution ---
if (part_to_render == "Frame") {
    render_frame();
} else if (part_to_render == "Cradle Base") {
    color(frame_color) cradle_base();
} else if (part_to_render == "All") {
    render_frame();
    // Drops the cradle base down to explicitly match the frame's bottom Z-plane
    translate([0, -frame_height/2 - 40, -frame_depth/2]) color(frame_color) cradle_base();
}

module render_frame() {
    union() {
        color(frame_color) base_frame();
        center_shape();
        color(string_color) rays();
    }
}

// --- Modules ---

module outer_profile() {
    filleted_heart(frame_width, frame_height);
}

module inner_profile() {
    offset(delta=-frame_thickness) outer_profile();
}

module center_shape_solid() {
    scale_factor = (object_scale_percent / 100);
    translate([object_offset_x, object_offset_y, 0]) {
        color(object_color)
            linear_extrude(height=frame_depth, center=true) {
                scale([scale_factor, scale_factor]) {
                    if (svg_file == "default.svg" || svg_file == "") {
                        filleted_heart(60, 52.5);
                    } else {
                        import(file=svg_file, center=true);
                    }
                }
            }
    }
}

// --- CRADLE BASE ---
module cradle_base() {
    cradle_w = frame_width * 0.6;
    // Matches frame depth exactly, unless frame depth drops below 25mm
    cradle_d = max(frame_depth, 25);
    cradle_h = 30;

    difference() {
        // Base block: Extrudes a 2D profile along the Y-axis to keep front/back faces completely flat
        safe_r = 5;
        rotate([90, 0, 0])
            linear_extrude(height=cradle_d, center=true)
                hull() {
                    // Bottom flat footprint
                    translate([0, 0.5]) square([cradle_w, 1], center=true);
                    // Top rounded left/right edges
                    translate([-cradle_w/2 + safe_r, cradle_h - safe_r]) circle(r=safe_r);
                    translate([ cradle_w/2 - safe_r, cradle_h - safe_r]) circle(r=safe_r);
                }
        
        // Sinks the heart deep into the block, leaving exactly 10mm of plastic underneath
        translate([0, 0, 10 + frame_height/2])
            rotate([90, 0, 0])
                // Ensure the cut geometry always completely breaches the front and back of the cradle block
                linear_extrude(height=cradle_d + 2, center=true)
                    offset(delta=0.5) // 0.5mm tolerance for drop-in fit
                        outer_profile();
    }
}