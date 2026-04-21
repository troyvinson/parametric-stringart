// Standard Digital File License
//
//Copyright (c) 2026 Troy Vinson
//
//This content is licensed under a Standard Digital File License.
//
//You shall not share, sub-license, sell, rent, host, transfer, or distribute in any way the digital or 3D printed versions of this object, nor any other derivative work of this object in its digital or physical format (including - but not limited to - remixes of this object, and hosting on other digital platforms). The objects may not be used without permission in any way whatsoever in which you charge money, or collect fees.

// === CORE STRING ENGINE ===
// Do not render this file directly. It is injected into the templates via build.py

// Generates a mathematically perfect, centered heart using solid geometry.
module heart2d(w, h) {
    S = 100;
    y_max = (S * sqrt(2) / 4) + (S / 2);
    y_min = -S * sqrt(2) / 2;
    y_center = (y_max + y_min) / 2;
    
    resize([w, h])
    translate([0, -y_center])
    union() {
        rotate([0, 0, 45]) square(S, center=true);
        translate([-S*sqrt(2)/4, S*sqrt(2)/4]) circle(d=S);
        translate([ S*sqrt(2)/4, S*sqrt(2)/4]) circle(d=S);
    }
}

// Applies a 2mm fillet to blunt the sharp bottom point
module filleted_heart(w, h) {
    offset(r=2) offset(delta=-2) heart2d(w, h);
}

module raw_string_pattern(w, h) {
    ray_length = max(frame_width, frame_height) * 1.5;
    z_usable = frame_depth - string_height - (string_margin * 2); 
    z_start = (string_rows == 1) ? 0 : -z_usable/2;
    z_step = (string_rows > 1) ? z_usable / (string_rows - 1) : 0; 

    union() {
        for (r = [0 : string_rows - 1]) {
            z_pos = z_start + r * z_step;
            rot_offset = (alternate_rotation && r % 2 != 0) ? (360/strings_per_row)/2 : 0;
            
            translate([0, convergence_y_offset, z_pos]) {
                for (s = [0 : strings_per_row - 1]) {
                    rotate([0, 0, s * (360/strings_per_row) + rot_offset])
                        translate([ray_length/2, 0, 0])
                            cube([ray_length, w, h], center=true);
                } 
            }
        }
    }
}

module string_boundary(l_clearance = 0) {
    linear_extrude(height=frame_depth + 2, center=true)
        offset(delta=(-frame_thickness * (1 - (string_embed_percent/100))) + l_clearance) outer_profile();
}

module string_void(l_clearance = 0) {
    translate([0, convergence_y_offset, 0])
        linear_extrude(height=frame_depth * 3, center=true) {
            // Shrink the void by the clearance amount to let the string cut deeper
            offset(delta=-l_clearance) {
                if (void_shape == "Ellipse") {
                    scale([void_width/void_height, 1])
                        circle(d=void_height);
                } else if (void_shape == "Rectangle") {
                    square([void_width, void_height], center=true);
                } else if (void_shape == "Hexagon") {
                    circle(d=void_width, $fn=6);
                } else if (void_shape == "Heart") {
                    filleted_heart(void_width, void_height);
                }
            }
        }
}

module bounded_string_pattern(w, h, l_clearance = 0) {
    difference() {
        intersection() {
            string_boundary(l_clearance);
            raw_string_pattern(w, h);
        }
        if (void_shape != "None") {
            string_void(l_clearance);
        }
    }
}

module base_frame() {
    difference() {
        linear_extrude(height=frame_depth, center=true) {
            difference() {
                outer_profile();
                inner_profile();
            } 
        }
        if (string_clearance > 0) {
            bounded_string_pattern(
                string_width + (string_clearance * 2), 
                string_height + (string_clearance * 2), 
                string_clearance
            );
        }
    }
}

module center_shape() {
    difference() {
        center_shape_solid();
        if (string_clearance > 0) {
            bounded_string_pattern(
                string_width + (string_clearance * 2), 
                string_height + (string_clearance * 2), 
                string_clearance
            );
        }
    }
}

module rays() {
    bounded_string_pattern(string_width, string_height);
}

module center_shape_solid() {
    scale_factor = (object_scale_percent / 100);

    // Check if mode is defined, default to "svg"
    is_text_mode = is_undef(center_mode) ? false : (center_mode == "text");

    translate([object_offset_x, object_offset_y, 0]) {
        if (is_text_mode) {
            scale([scale_factor, scale_factor]) {
                if (text_emboss_height >= 0) {
                    // Emboss (positive or zero)
                    union() {
                        // Outline Base (solid)
                        color(text_outline_color)
                            linear_extrude(height=frame_depth, center=true)
                                offset(r=text_outline_width)
                                    text(text_string, size=text_size, font=str(font, (font_style == "" ? "" : str(":style=", font_style))), halign="center", valign="center", spacing=text_spacing);

                        // Raised Text
                        color(text_color)
                            translate([0, 0, frame_depth/2])
                                linear_extrude(height=text_emboss_height)
                                    text(text_string, size=text_size, font=str(font, (font_style == "" ? "" : str(":style=", font_style))), halign="center", valign="center", spacing=text_spacing);
                    }
                } else {
                    // Deboss (negative)
                    difference() {
                        // Outline Base (solid)
                        color(text_outline_color)
                            linear_extrude(height=frame_depth, center=true)
                                offset(r=text_outline_width)
                                    text(text_string, size=text_size, font=str(font, (font_style == "" ? "" : str(":style=", font_style))), halign="center", valign="center", spacing=text_spacing);

                        // Subtracted Text
                        translate([0, 0, frame_depth/2 + text_emboss_height])
                            linear_extrude(height=abs(text_emboss_height) + 1) // +1 for clean cut
                                text(text_string, size=text_size, font=str(font, (font_style == "" ? "" : str(":style=", font_style))), halign="center", valign="center", spacing=text_spacing);
                    }
                    // Add the bottom of the debossed area in the text color if desired,
                    // but for deboss usually we just cut into it. If we want it colored:
                    // Actually, let's keep it simple and just do difference.
                    // If they want colored text, we could fill the cut or color the cut faces,
                    // OpenSCAD coloring in differences can be tricky. Let's just difference.
                    color(text_color)
                        translate([0, 0, frame_depth/2 + text_emboss_height])
                            linear_extrude(height=0.01) // Just a thin layer to provide color at the bottom of the deboss
                                text(text_string, size=text_size, font=str(font, (font_style == "" ? "" : str(":style=", font_style))), halign="center", valign="center", spacing=text_spacing);
                }
            }
        } else {
            if (is_undef(svg_file) || svg_file == "default.svg" || svg_file == "") {
                // Placeholder Cylinder
                color("gray")
                    linear_extrude(height=frame_depth, center=true)
                        circle(d=40);

                // Raised Black Text
                color("black")
                    translate([0, 0, frame_depth/2])
                        linear_extrude(height=1) {
                            translate([0, 5, 0])
                                text("Upload", size=6, font="Arial:style=Bold", halign="center", valign="center");
                            translate([0, -3, 0])
                                text("SVG File", size=6, font="Arial:style=Bold", halign="center", valign="center");
                        }
            } else {
                // Uploaded SVG
                linear_extrude(height=frame_depth, center=true) {
                    scale([scale_factor, scale_factor]) {
                        import(file=svg_file, center=true);
                    }
                }
            }
        }
    }
}
