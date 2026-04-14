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

/* [Heart Frame Settings] */
// 1. The total maximum height of the outer frame (Width is locked to proportion).
frame_height = 140; // min:100
// 2. The thickness of the model from the build plate up (Z-axis).
frame_depth = 30; //
// 3. The thickness of the outer frame wall itself.
frame_thickness = 10;
// 4. Color of the outer frame
frame_color = "#CCCCCC"; // color

/* [Text Settings] */
// 1. Text to display
text_string = "Troy";
// 2. Select font to use
font = "Roboto"; //[Aclonica, Acme, Agbalumo, Aladin, Alkatra,Amaranth,Artifika,Bagel Fat One,Bree Serif,Cabin,Cal Sans,Caprasimo,Carter One,Chewy,Chicle,Comic Relief,Concert One,Creepster,Dangrek,Gabriela,Galada,Goblin One,Imprima,Irish Grover,Itim,Jolly Lodger,Lemon,Lilita One,Lobster,Lobster Two,Lora,Merriweather Sans,Montserrat,Moul,Noto Emoji,Orelega One,Pacifico,Paprika,Quando,Radio Canada,REM,Righteous,Risque,Roboto,Roboto Condensed,Roboto Flex,Roboto Mono,Roboto Serif,Roboto Slab,Rum Raisin,Salsa,Seymour One,Slackey,Sniglet,Spicy Rice,Sriracha,Suez One,Telex,Tilt Neon,Tilt Warp,Titan One,Ubuntu,Ubuntu Sans,Ultra,Wendy One,Young Serif]
// 3. Not all styles work with all fonts
font_style = ""; // [,Regular,Bold,Medium,SemiBold,Light,ExtraBold,Black,ExtraLight,Thin,Bold Italic,Italic,Light Italic,Medium Italic]
// 4. Prepend Emoji
prepend_emoji = ""; // [ ,❤,⭐,✨,🔥,🎵,🐾,🌸,🦋,🌙,☀,⚡,🍀,🎀,🎁,🚀,🛸,🏆,👑,💎,💍,💡,🎈,🎉,⚽,🏀,🏈,⚾,🎾,☕,🍺,🍷,🍕,🍔,🍦,🍎,🍄,🌵,🌲,🌊,🌍,🪐]
// 5. Append Emoji
append_emoji = ""; // [ ,❤,⭐,✨,🔥,🎵,🐾,🌸,🦋,🌙,☀,⚡,🍀,🎀,🎁,🚀,🛸,🏆,👑,💎,💍,💡,🎈,🎉,⚽,🏀,🏈,⚾,🎾,☕,🍺,🍷,🍕,🍔,🍦,🍎,🍄,🌵,🌲,🌊,🌍,🪐]
// 6. Emoji Spacing (Distance from text)
emoji_spacing = 20; // [0:1:100]
// 7. Size of the text
text_size = 20; // [5:1:100]
// 8. Letter spacing
text_spacing = 1; // [0.1:0.1:5]
// 9. Width of the solid outline around the text
text_outline_width = 3; // [0:0.5:20]
// 10. Height the text protrudes above the outline (use negative for debossing)
text_emboss_height = 2; // [-10:0.5:20]
// 11. Adjust scale to fit inside the frame (preserves aspect ratio)
object_scale_percent = 100; // [1:1:500]
// 13. Fine-tune positioning if the auto-center needs a slight nudge on the X-axis
object_offset_x = 0; // [-50:0.5:50]
// 13. Fine-tune positioning if the auto-center needs a slight nudge on the Y-axis
object_offset_y = 0; // [-50:0.5:50]
// 14. Color of the text outline base
text_outline_color = "#FFFFFF"; // color
// 15. Color of the embossed/debossed text
text_color = "#FF0000"; // color
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

/* [Hidden] */
// High resolution for smooth curves.
$fn = 120;
// Variables locked from user adjustment.
string_embed_percent = 50;
string_clearance = 0.1;
string_width = 0.61;
string_height = 0.41;

// Lock the width to maintain the traditional 160:140 (8:7) heart ratio
frame_width = frame_height * (8 / 7);

center_mode = "text";
void_shape = "None";

// --- Execution ---
render_frame();

module render_frame() {
    union() {
        color(frame_color) union() {
            base_frame();
            integrated_stand();
        }
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

// --- INTEGRATED STAND ---
module integrated_stand() {
    stand_w = frame_width * 0.7;
    stand_h = 12;
    overlap = 4;
    corner_r = 2;

    translate([0, -frame_height/2 - stand_h + overlap, 0])
        linear_extrude(height=frame_depth, center=true)
            offset(r=corner_r) offset(delta=-corner_r)
            hull() {
                translate([0, 2]) square([stand_w, 4], center=true);
                translate([0, stand_h - 2]) square([stand_w * 0.5, 4], center=true);
            }
}


include <../core_engine.scad>
