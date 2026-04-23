// Standard Digital File License
//
//Copyright (c) 2026 Troy Vinson
//
//This content is licensed under a Standard Digital File License.
//
//You shall not share, sub-license, sell, rent, host, transfer, or distribute in any way the digital or 3D printed versions of this object, nor any other derivative work of this object in its digital or physical format (including - but not limited to - remixes of this object, and hosting on other digital platforms). The objects may not be used without permission in any way whatsoever in which you charge money, or collect fees.

/* [Star Frame] */
// Outer point-to-point diameter of the star.
frame_width = 180; // [100:1:400]
// Number of points on the star.
star_points = 5; // [5:1:8]
// Depth of the valleys between points (0.2 = very pointy, 0.8 = almost circular).
inner_radius_ratio = 0.4; // [0.1:0.05:0.9]
// Overall thickness of the model (Z height).
frame_depth = 30; // [10:1:80]
// Thickness of the frame wall.
frame_thickness = 8; // [3:0.5:40]
// Rounding on the outer tips.
outer_corner_radius = 2; // [0:1:20]
// Rounding on the inner valleys.
inner_corner_radius = 1; // [0:1:20]
// Frame color.
frame_color = "#CCCCCC"; // color

/* [Center Object] */
// Your SVG artwork file.
svg_file = "default.svg";
// Scale the artwork to fit the frame opening.
content_scale = 100; // [1:1:500]
// Nudge the artwork left or right.
content_offset_x = 0; // [-50:0.5:50]
// Nudge the artwork up or down.
content_offset_y = 0; // [-50:0.5:50]
// Color of the SVG artwork.
svg_color = "#CCCCCC"; // color

/* [Strings] */
// Total number of strings per revolution.
string_count = 28; // [4:1:120]
// Number of depth layers the strings are spread across.
string_layers = 5; // [1:1:20]
// Gap between strings and the top face of the frame.
string_margin_top = 4; // [0:0.5:10]
// Gap between strings and the bottom face of the frame.
string_margin_bottom = 4; // [0:0.5:10]
// Moves the string convergence point up or down.
string_center_y = 0; // [-50:0.5:50]
// Rotate alternating layers for a woven appearance.
string_weave = true; // [true:false]
// Color of the strings.
string_color = "#CCCCCC"; // color

/* [Center Void] */
// Cuts out a void at the string convergence center. Useful for hollow SVG artwork.
void_shape = "None"; // [None, Ellipse, Rectangle, Hexagon, Heart]
// Width of the void cutout.
void_width = 20; // [1:0.5:200]
// Height of the void cutout (applies to Ellipse, Rectangle, and Heart only).
void_height = 20; // [1:0.5:200]

/* [Hidden] */
$fn = 120;
string_embed_percent = 50;
string_clearance = 0.1;
string_width = 0.61;
string_height = 0.41;
frame_height = frame_width;

center_mode = "svg";

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


include <../core_engine.scad>
