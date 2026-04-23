// Standard Digital File License
//
//Copyright (c) 2026 Troy Vinson
//
//This content is licensed under a Standard Digital File License.
//
//You shall not share, sub-license, sell, rent, host, transfer, or distribute in any way the digital or 3D printed versions of this object, nor any other derivative work of this object in its digital or physical format (including - but not limited to - remixes of this object, and hosting on other digital platforms). The objects may not be used without permission in any way whatsoever in which you charge money, or collect fees.

/* [Frame] */
// Shape of the frame.
frame_shape = "Halo"; // [Halo, Rectangle, Ellipse]
// Gap between the text and the inner frame wall. Also determines the frame size.
halo_offset = 15; // [5:1:50]
// Overall thickness of the model (Z height).
frame_depth = 30; // [10:1:80]
// Thickness of the frame wall.
frame_thickness = 10; // [3:0.5:40]
// Rounding on the outer corners (Rectangle and Ellipse only).
outer_corner_radius = 5; // [0:1:30]
// Rounding on the inner corners (Rectangle and Ellipse only).
inner_corner_radius = 5; // [0:1:30]
// Frame color.
frame_color = "#000000"; // color

/* [Text] */
// Emoji(s) to display before the main text (uses Noto Emoji font).
text_prefix = "";
// Nudge the prefix emoji left or right.
emoji_prefix_x = -5; // [-50:0.5:50]
// Nudge the prefix emoji up or down.
emoji_prefix_y = 0; // [-50:0.5:50]
// Size of the emoji characters.
emoji_font_size = 14; // [5:1:100]
// Style of the emoji characters.
emoji_font_style = "Regular"; // [Light,Regular,Medium,SemiBold,Bold]
// Main text to display.
text_string = "Text Here";
// Emoji(s) to display after the main text (uses Noto Emoji font).
text_suffix = "";
// Nudge the suffix emoji left or right.
emoji_suffix_x = 5; // [-50:0.5:50]
// Nudge the suffix emoji up or down.
emoji_suffix_y = 0; // [-50:0.5:50]
// Font for the main text.
text_font = "Lobster"; //[Aclonica, Acme, Agbalumo, Aladin, Alkatra,Amaranth,Artifika,Bagel Fat One,Bree Serif,Cabin,Cal Sans,Caprasimo,Carter One,Chewy,Chicle,Comic Relief,Concert One,Creepster,Dangrek,Gabriela,Galada,Goblin One,Imprima,Irish Grover,Itim,Jolly Lodger,Lemon,Lilita One,Lobster,Lobster Two,Lora,Merriweather Sans,Montserrat,Moul,Noto Emoji,Orelega One,Pacifico,Paprika,Quando,Radio Canada,REM,Righteous,Risque,Roboto,Roboto Condensed,Roboto Flex,Roboto Mono,Roboto Serif,Roboto Slab,Rum Raisin,Salsa,Seymour One,Slackey,Sniglet,Spicy Rice,Sriracha,Suez One,Telex,Tilt Neon,Tilt Warp,Titan One,Ubuntu,Ubuntu Sans,Ultra,Wendy One,Young Serif]
// Style of the main text font (not all styles work with all fonts).
text_font_style = "Bold"; // [Regular,Bold,Medium,SemiBold,Light,ExtraBold,Black,ExtraLight,Thin,Bold Italic,Italic,Light Italic,Medium Italic]
// Size of the main text.
text_font_size = 18; // [5:1:100]
// Letter spacing multiplier (affects text and emojis).
content_spacing = 1; // [0.1:0.1:5]
// Width of the solid halo/outline around the text and emojis.
content_halo_size = 3; // [0:0.5:20]
// How far the text rises above the halo (negative = debossed into the halo).
content_relief = 2; // [-10:0.5:20]
// Scale the entire text group.
content_scale = 100; // [1:1:500]
// Nudge the text left or right.
content_offset_x = 0; // [-50:0.5:50]
// Nudge the text up or down.
content_offset_y = 0; // [-50:0.5:50]
// Color of the halo/outline base.
content_halo_color = "#FFFFFF"; // color
// Color of the embossed or debossed text.
content_color = "#FF0000"; // color

/* [Strings] */
// Total number of strings per revolution.
string_count = 22; // [4:1:120]
// Number of depth layers the strings are spread across.
string_layers = 4; // [1:1:20]
// Gap between strings and the top face of the frame.
string_margin_top = 7.5; // [0:0.5:10]
// Gap between strings and the bottom face of the frame.
string_margin_bottom = 7.5; // [0:0.5:10]
// Moves the string convergence point up or down.
string_center_y = 0; // [-50:0.5:50]
// Rotate alternating layers for a woven appearance.
string_weave = true; // [true:false]
// Color of the strings.
string_color = "#FFFFFF"; // color

/* [Hidden] */
$fn = 120;
string_embed_percent = 50;
string_clearance = 0.1;
string_width = 0.61;
string_height = 0.41;

center_mode = "text";
void_shape  = "None";

// Estimated text metrics — used for frame sizing and stand positioning.
_main_font_full  = str(text_font, (text_font_style == "" ? "" : str(":style=", text_font_style)));
_emoji_font_full = str("Noto Emoji", (emoji_font_style == "" ? "" : str(":style=", emoji_font_style)));
_half_w_est  = (text_string == "") ? 0
             : (len(text_string) * text_font_size * content_spacing * 0.6) / 2;
_pre_x_est   = ((text_string == "" && text_suffix == "") ? 0 : -(_half_w_est + text_font_size * 0.6)) + emoji_prefix_x;
_post_x_est  = ((text_prefix == "" && text_string == "") ? 0 :  (_half_w_est + text_font_size * 0.6)) + emoji_suffix_x;

// Width = main text span only; emoji nudge offsets don't expand the frame boundary.
_left_edge   = -_half_w_est;
_right_edge  =  _half_w_est;
_text_w_est  = (_right_edge - _left_edge) * (content_scale / 100);
_text_h_est  = text_font_size * (content_scale / 100);

// Scale halo and wall with content so the gap stays consistent at any content_scale.
_scaled_halo      = halo_offset * (content_scale / 100);
_scaled_thickness = frame_thickness * (content_scale / 100);

// Frame outer dimensions — derived from text metrics + scaled halo + wall for all shapes.
frame_width  = _text_w_est + (_scaled_halo + _scaled_thickness) * 2;
frame_height = _text_h_est + (_scaled_halo + _scaled_thickness) * 2;

// Ellipse flat-cut y: halo_offset below the bottom of the text content.
_ellipse_cut_y = -(_text_h_est/2 + _scaled_halo + _scaled_halo * 0.3);

// --- Execution ---
union() {
    color(frame_color) union() {
        base_frame();
        if (frame_shape == "Halo") integrated_stand();
    }
    center_shape();
    color(string_color) rays();
}

// --- Modules ---

// Text glyph union at the template level — used by Halo outer/inner profiles.
module _frame_text_glyphs_2d() {
    scale([content_scale / 100, content_scale / 100]) {
        if (text_prefix != "")
            translate([_pre_x_est, emoji_prefix_y])
                text(text_prefix, size=emoji_font_size, font=_emoji_font_full,
                     halign="center", valign="center", spacing=content_spacing);
        if (text_string != "")
            text(text_string, size=text_font_size, font=_main_font_full,
                 halign="center", valign="center", spacing=content_spacing);
        if (text_suffix != "")
            translate([_post_x_est, emoji_suffix_y])
                text(text_suffix, size=emoji_font_size, font=_emoji_font_full,
                     halign="center", valign="center", spacing=content_spacing);
    }
}

// Raw outer boundary before rounding — Rectangle and Ellipse only.
module _raw_rect() {
    square([frame_width, frame_height], center=true);
}

module _raw_ellipse() {
    difference() {
        scale([frame_width/frame_height, 1]) circle(d=frame_height);
        translate([0, _ellipse_cut_y - 500]) square([frame_width*3, 1000], center=true);
    }
}

module outer_profile() {
    if (frame_shape == "Halo") {
        translate([content_offset_x, content_offset_y])
            offset(r = _scaled_halo + _scaled_thickness)
                _frame_text_glyphs_2d();
    } else if (frame_shape == "Rectangle") {
        safe_r = min(outer_corner_radius, frame_width/2.1, frame_height/2.1);
        if (safe_r > 0) offset(r=safe_r) offset(r=-safe_r) _raw_rect();
        else _raw_rect();
    } else { // Ellipse
        safe_r = min(outer_corner_radius, frame_width/2.1, frame_height/2.1);
        if (safe_r > 0) offset(r=safe_r) offset(r=-safe_r) _raw_ellipse();
        else _raw_ellipse();
    }
}

module _raw_inner_rect() { offset(delta=-_scaled_thickness) _raw_rect(); }
module _raw_inner_ellipse() { offset(delta=-_scaled_thickness) _raw_ellipse(); }

module inner_profile() {
    if (frame_shape == "Halo") {
        translate([content_offset_x, content_offset_y])
            offset(r = _scaled_halo)
                _frame_text_glyphs_2d();
    } else if (frame_shape == "Rectangle") {
        safe_r = min(inner_corner_radius, (frame_width-frame_thickness)/2.1, (frame_height-frame_thickness)/2.1);
        if (safe_r > 0) offset(r=safe_r) offset(r=-safe_r) _raw_inner_rect();
        else _raw_inner_rect();
    } else { // Ellipse
        safe_r = min(inner_corner_radius, (frame_width-frame_thickness)/2.1, (frame_height-frame_thickness)/2.1);
        if (safe_r > 0) offset(r=safe_r) offset(r=-safe_r) _raw_inner_ellipse();
        else _raw_inner_ellipse();
    }
}

// Stand for Halo frame only.
module integrated_stand() {
    bottom_y = (content_offset_y - _text_h_est / 2) - (_scaled_halo + _scaled_thickness);
    stand_w  = (_text_w_est * 0.6) + _scaled_halo;
    stand_h  = 14 * (content_scale / 100);
    overlap  = 5  * (content_scale / 100);
    corner_r = 2;

    translate([content_offset_x, bottom_y - stand_h + overlap, 0])
        linear_extrude(height=frame_depth, center=true)
            offset(r=corner_r) offset(delta=-corner_r)
            hull() {
                translate([0, 2])           square([stand_w,       4], center=true);
                translate([0, stand_h - 2]) square([stand_w * 0.5, 4], center=true);
            }
}


include <../core_engine.scad>
