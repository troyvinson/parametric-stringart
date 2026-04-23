// Standard Digital File License
//
//Copyright (c) 2026 Troy Vinson
//
//This content is licensed under a Standard Digital File License.
//
//You shall not share, sub-license, sell, rent, host, transfer, or distribute in any way the digital or 3D printed versions of this object, nor any other derivative work of this object in its digital or physical format (including - but not limited to - remixes of this object, and hosting on other digital platforms). The objects may not be used without permission in any way whatsoever in which you charge money, or collect fees.

/* [Triangle Frame] */
// Outer point-to-point width of the frame.
frame_width = 160; // [100:1:400]
// Overall thickness of the model (Z height).
frame_depth = 30; // [10:1:80]
// Thickness of the frame wall.
frame_thickness = 10; // [3:0.5:40]
// Rounding on the outer corners.
outer_corner_radius = 5; // [0:1:30]
// Rounding on the inner corners.
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
// Scale the entire text group to fit the frame opening.
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
string_color = "#FFFFFF"; // color

/* [Hidden] */
$fn = 120;
string_embed_percent = 50;
string_clearance = 0.1;
string_width = 0.61;
string_height = 0.41;

// Equilateral triangle: height derived from circumradius = frame_width / 2.
frame_height = (frame_width / 2) * 1.5;

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
    // Rotated so a flat edge sits at the bottom.
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


include <../core_engine.scad>
