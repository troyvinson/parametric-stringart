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

            # Stitch them together
            final_code = f"{template_code}\n\n// === INJECTED CORE ENGINE ===\n\n{core_code}"

            # Write the monolithic file to the build folder
            with open(output_path, 'w') as f:
                f.write(final_code)

            print(f"Built: {output_path}")

    print("\nBuild complete. Check the '/build' folder for your MakerWorld-ready files.")

if __name__ == "__main__":
    build_project()
    