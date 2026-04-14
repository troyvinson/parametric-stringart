# MIT License
#
# Copyright (c) 2026 Troy Vinson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
        with open(CORE_FILE, 'r', encoding='utf-8') as f:
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
            with open(template_path, 'r', encoding='utf-8') as f:
                template_code = f.read()
            template_code = template_code.replace("include <../core_engine.scad>", "")

            # Stitch them together
            final_code = f"{template_code}\n\n// === INJECTED CORE ENGINE ===\n\n{core_code}"

            # Write the monolithic file to the build folder
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(final_code)

            print(f"Built: {output_path}")

    print("\nBuild complete. Check the '/build' folder for your MakerWorld-ready files.")

if __name__ == "__main__":
    build_project()
    