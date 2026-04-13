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

module string_boundary() {
    linear_extrude(height=frame_depth + 2, center=true)
        offset(delta=-frame_thickness * (1 - (string_embed_percent/100))) outer_profile();
}

module string_void() {
    translate([0, convergence_y_offset, 0])
        linear_extrude(height=frame_depth * 3, center=true) {
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

module bounded_string_pattern(w, h) {
    difference() {
        intersection() {
            string_boundary();
            raw_string_pattern(w, h);
        }
        if (void_shape != "None") {
            string_void();
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
            bounded_string_pattern(string_width + (string_clearance * 2), string_height + (string_clearance * 2));
        } 
    }
}

module center_shape() {
    difference() {
        center_shape_solid();
        if (string_clearance > 0) {
            bounded_string_pattern(string_width + (string_clearance * 2), string_height + (string_clearance * 2));
        } 
    }
}

module rays() {
    bounded_string_pattern(string_width, string_height);
}
module center_shape_solid() {
    scale_factor = (object_scale_percent / 100);
    translate([object_offset_x, object_offset_y, 0]) {
        if (svg_file == "default.svg" || svg_file == "") {
            union() {
                color(object_color)
                    linear_extrude(height=frame_depth, center=true)
                        square([80, 20], center=true);
                color("black")
                    translate([0, 0, frame_depth/2])
                        linear_extrude(height=2, center=false)
                            text("Upload SVG File", size=8, halign="center", valign="center");
            }
        } else {
            color(object_color)
                linear_extrude(height=frame_depth, center=true)
                    scale([scale_factor, scale_factor])
                        import(file=svg_file, center=true);
        }
    }
}
