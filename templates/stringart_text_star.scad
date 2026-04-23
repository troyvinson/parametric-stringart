// Standard Digital File License
//
//Copyright (c) 2026 Troy Vinson
//
//This content is licensed under a Standard Digital File License.
//
//You shall not share, sub-license, sell, rent, host, transfer, or distribute in any way the digital or 3D printed versions of this object, nor any other derivative work of this object in its digital or physical format (including - but not limited to - remixes of this object, and hosting on other digital platforms). The objects may not be used without permission in any way whatsoever in which you charge money, or collect fees.

/* [Star Frame Settings] */
// 1. The total outer diameter of the star.
frame_width = 180; // min:100
// 2. How many points the star has.
star_points = 5; // [5:1:8]
// 3. How deep the valleys of the star go (0.2 = very pointy, 0.8 = almost a circle).
inner_radius_ratio = 0.4; // [0.1:0.05:0.9]
// 4. The thickness of the model (Z-axis).
frame_depth = 30; //
// 5. The thickness of the frame wall.
frame_thickness = 8;
// 6. Corner rounding.
outer_corner_radius = 2; // [0:1:20]
// 7. Interior valley rounding.
inner_corner_radius = 1; // [0:1:20]
// 8. Color
frame_color = "#CCCCCC"; // color

/* [Text Settings] */
// 1. Emoji(s) to display before the text (optional, uses Noto Emoji font)
text_prefix = "";
// 2. Main text to display
text_string = "Test";
// 3. Emoji(s) to display after the text (optional, uses Noto Emoji font)
text_suffix = "";
// 2. Select font to use
font = "Roboto"; //[Aclonica, Acme, Agbalumo, Aladin, Alkatra,Amaranth,Artifika,Bagel Fat One,Bree Serif,Cabin,Cal Sans,Caprasimo,Carter One,Chewy,Chicle,Comic Relief,Concert One,Creepster,Dangrek,Gabriela,Galada,Goblin One,Imprima,Irish Grover,Itim,Jolly Lodger,Lemon,Lilita One,Lobster,Lobster Two,Lora,Merriweather Sans,Montserrat,Moul,Noto Emoji,Orelega One,Pacifico,Paprika,Quando,Radio Canada,REM,Righteous,Risque,Roboto,Roboto Condensed,Roboto Flex,Roboto Mono,Roboto Serif,Roboto Slab,Rum Raisin,Salsa,Seymour One,Slackey,Sniglet,Spicy Rice,Sriracha,Suez One,Telex,Tilt Neon,Tilt Warp,Titan One,Ubuntu,Ubuntu Sans,Ultra,Wendy One,Young Serif]
// 3. Not all styles work with all fonts
font_style = "Regular"; //  [Regular,Bold,Medium,SemiBold,Light,ExtraBold,Black,ExtraLight,Thin,Bold Italic,Italic,Light Italic,Medium Italic]
// 4. Size of the text
text_size = 20; // [5:1:100]
// 5. Letter spacing
text_spacing = 1; // [0.1:0.1:5]
// 6. Width of the solid outline around the text
text_outline_width = 3; // [0:0.5:20]
// 7. Height the text protrudes above the outline (use negative for debossing)
text_emboss_height = 2; // [-10:0.5:20]
// 8. Adjust scale to fit inside the frame (preserves aspect ratio)
object_scale_percent = 100; // [1:1:500]
// 10. Fine-tune positioning if the auto-center needs a slight nudge on the X-axis
object_offset_x = 0; // [-50:0.5:50]
// 10. Fine-tune positioning if the auto-center needs a slight nudge on the Y-axis
object_offset_y = 0; // [-50:0.5:50]
// 11. Color of the text outline base
text_outline_color = "#FFFFFF"; // color
// 12. Color of the embossed/debossed text
text_color = "#FF0000"; // color
/* [String (Ray) Settings] */
// 1. Number of strings wrapping around one full revolution.
strings_per_row = 28;
// 2. Number of vertical layers of strings.
string_rows = 5;
// 3. Z-axis margin to keep strings away from the top face.
string_margin_top = 4; // [0:0.5:10]
// 4. Z-axis margin to keep strings away from the bottom face.
string_margin_bottom = 4; // [0:0.5:10]
// 4. Shifts the convergence point of all strings up or down.
convergence_y_offset = 0;
// 5. Offset the angle of every other row for a woven look.
alternate_rotation = true; // [true:false]
// 6. Color of the strings/rays
string_color = "#CCCCCC"; // color

/* [Hidden] */
$fn = 120;
string_embed_percent = 50;
string_clearance = 0.1;
string_width = 0.61;
string_height = 0.41;
frame_height = frame_width; // Stars are roughly circular in bounds

center_mode = "text";
void_shape = "None";

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
