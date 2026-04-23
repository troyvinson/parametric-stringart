# Standard Digital File License
#
# Copyright (c) 2026 Troy Vinson
#
# This content is licensed under a Standard Digital File License.
#
# You shall not share, sub-license, sell, rent, host, transfer, or distribute in any way the digital or 3D printed versions of this object, nor any other derivative work of this object in its digital or physical format (including - but not limited to - remixes of this object, and hosting on other digital platforms). The objects may not be used without permission in any way whatsoever in which you charge money, or collect fees.

import os

# Configuration
TEMPLATE_DIR = 'templates'
OUTPUT_DIR = 'build'
CORE_FILE = 'core_engine.scad'

def build_project():
    # Ensure the output directory exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Load the core engine math
    try:
        with open(CORE_FILE, 'r') as f:
            core_code = f.read()

            # Strip out the copyright header from core_code to avoid duplicates
            if core_code.startswith("// MIT License"):
                # Find the end of the license block (empty line after the block)
                parts = core_code.split("\n\n", 1)
                if len(parts) > 1 and "Copyright (c)" in parts[0]:
                    core_code = parts[1].strip()
    except FileNotFoundError:
        print(f"Error: Could not find '{CORE_FILE}'. Make sure it is in the same directory as this script.")
        return

    # Process each template in the templates folder
    for filename in os.listdir(TEMPLATE_DIR):
        if filename.endswith('.scad'):
            template_path = os.path.join(TEMPLATE_DIR, filename)
            output_path = os.path.join(OUTPUT_DIR, f"TinkerTroy_{filename}")

            # Read the unique UI variables and shape definitions
            with open(template_path, 'r') as f:
                template_code = f.read()
            template_code = template_code.replace("include <../core_engine.scad>", "")

            # Stitch them together
            final_code = f"{template_code}\n\n// === INJECTED CORE ENGINE ===\n\n{core_code}"

            # Write the monolithic file to the build folder
            with open(output_path, 'w') as f:
                f.write(final_code)

            print(f"Built: {output_path}")

    print("\nBuild complete. Check the '/build' folder for your MakerWorld-ready files.")

if __name__ == "__main__":
    build_project()
    