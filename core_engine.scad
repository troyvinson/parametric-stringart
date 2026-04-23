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
    z_usable = frame_depth - string_height - string_margin_bottom - string_margin_top;
    // Bottom row sits just inside the bottom margin; top row just inside the top margin.
    z_bottom = -frame_depth/2 + string_margin_bottom + string_height/2;
    z_start = (string_rows == 1) ? z_bottom + z_usable/2 : z_bottom;
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

    // --- Emoji / text positioning helpers ---
    // Estimated half-width of the main text block.
    // When text_string is empty, emojis are centered at x=0.
    _half_w = (text_string == "") ? 0
            : (len(text_string) * text_size * text_spacing * 0.6) / 2;
    _pre_x  = ((text_string == "" && text_suffix == "") ? 0 : -(_half_w + text_size * 0.6)) + emoji_prefix_x;
    _post_x = ((text_prefix == "" && text_string == "") ? 0 :  (_half_w + text_size * 0.6)) + emoji_suffix_x;

    _main_font  = str(font, (font_style == "" ? "" : str(":style=", font_style)));
    _emoji_font = "Noto Emoji";

    // 2D outline shape for a single text segment placed at x_pos
    module _text_2d(the_text, the_font, x_pos, the_size) {
        translate([x_pos, 0])
            text(the_text, size=the_size, font=the_font,
                 halign="center", valign="center", spacing=text_spacing);
    }

    // Union of all three text segments as a 2D shape (for outline base extrusion)
    module _all_text_2d_outlined() {
        offset(r=text_outline_width) {
            if (text_prefix != "") _text_2d(text_prefix, _emoji_font, _pre_x,  emoji_size);
            if (text_string != "") _text_2d(text_string, _main_font,  0,        text_size);
            if (text_suffix != "") _text_2d(text_suffix, _emoji_font, _post_x,  emoji_size);
        }
    }

    // Union of all three text segments as a 2D shape (raw, for emboss/deboss cutting)
    module _all_text_2d_raw() {
        if (text_prefix != "") _text_2d(text_prefix, _emoji_font, _pre_x,  emoji_size);
        if (text_string != "") _text_2d(text_string, _main_font,  0,        text_size);
        if (text_suffix != "") _text_2d(text_suffix, _emoji_font, _post_x,  emoji_size);
    }

    translate([object_offset_x, object_offset_y, 0]) {
        if (is_text_mode) {
            scale([scale_factor, scale_factor]) {
                if (text_emboss_height > 0) {
                    // Emboss (positive) — cavity cut in outline, colored text raised above
                    union() {
                        // Outline Base with text cavity so colored text shows through
                        color(text_outline_color)
                            difference() {
                                linear_extrude(height=frame_depth, center=true)
                                    _all_text_2d_outlined();
                                // Cut the text footprint flush from top down 1.2mm
                                translate([0, 0, frame_depth/2 - 1.2])
                                    linear_extrude(height=1.2 + 1) // +1 for clean cut
                                        _all_text_2d_raw();
                            }

                        // Colored text: 1.2mm cavity body + raised emboss above
                        color(text_color)
                            translate([0, 0, frame_depth/2 - 1.2])
                                linear_extrude(height=1.2 + text_emboss_height)
                                    _all_text_2d_raw();
                    }
                } else if (text_emboss_height == 0) {
                    // Flat — cavity cut in outline, colored text fills 1.2mm downward
                    union() {
                        // Outline Base with text cavity so colored text shows through
                        color(text_outline_color)
                            difference() {
                                linear_extrude(height=frame_depth, center=true)
                                    _all_text_2d_outlined();
                                // Cut the text footprint flush from top down 1.2mm
                                translate([0, 0, frame_depth/2 - 1.2])
                                    linear_extrude(height=1.2 + 1) // +1 for clean cut
                                        _all_text_2d_raw();
                            }

                        // Colored text fills the 1.2mm cavity flush with the top face
                        color(text_color)
                            translate([0, 0, frame_depth/2 - 1.2])
                                linear_extrude(height=1.2)
                                    _all_text_2d_raw();
                    }
                } else {
                    // Deboss (negative) — deep cavity cut + 1.2mm colored slab at cavity floor
                    union() {
                        difference() {
                            // Outline Base (solid)
                            color(text_outline_color)
                                linear_extrude(height=frame_depth, center=true)
                                    _all_text_2d_outlined();

                            // Subtracted Text cavity
                            translate([0, 0, frame_depth/2 + text_emboss_height - .1])
                                linear_extrude(height=abs(text_emboss_height) + 1) // +1 for clean cut
                                    _all_text_2d_raw();
                        }

                        // 1.2mm colored slab extending downward from the cavity floor
                        color(text_color)
                            translate([0, 0, frame_depth/2 + text_emboss_height - 1.2])
                                linear_extrude(height=1.2)
                                    _all_text_2d_raw();
                    }
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
