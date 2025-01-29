import pytesseract
from PIL import Image
import json
import os
from flask import Flask, request, jsonify
from flask_cors import CORS  # Import Flask-CORS

# Configure the path to Tesseract executable
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

app = Flask(__name__)

# Enable CORS for all routes
CORS(app)

@app.route('/upload_image', methods=['POST', 'OPTIONS'])  # Allow OPTIONS request as well
def upload_image():
    if request.method == 'OPTIONS':
        # Handle preflight CORS request
        return jsonify({'message': 'CORS preflight successful'}), 200
    
    try:
        # Get the file path from the JSON body
        data = request.get_json()
        image_path = data.get('imagePath')  # This should be the file path of the image

        if image_path and os.path.exists(image_path):
            # Open the image from the file path
            image = Image.open(image_path)

            # Perform OCR on the image (using the default language - English)
            try:
                text = pytesseract.image_to_string(image)  # No 'lang' argument, so it defaults to English
            except pytesseract.TesseractError as e:
                print(f"Error Tesseract: {e}")
                raise

            # Split the extracted text into lines and process each line
            lines = text.strip().split('\n')
            data = []

            # Process each line to extract relevant data
            for line in lines:
                if line.strip() and not line.startswith('Total'):
                    parts = line.split()
                    if len(parts) >= 9 and parts[0].isdigit():
                        try:
                            player_data = {
                                "numero": int(parts[0]),
                                "nom": " ".join(parts[1:3]),
                                "5_de_depart": "X" in line,
                                "tps_jeu": parts[-8] if len(parts) >= 8 else "",
                                "nb_pts_marques": int(parts[-7]) if parts[-7].isdigit() else 0,
                                "nb_tirs_reussis": int(parts[-6]) if parts[-6].isdigit() else 0,
                                "3_pts_reussis": int(parts[-5]) if parts[-5].isdigit() else 0,
                                "2_int_reussis": int(parts[-4]) if parts[-4].isdigit() else 0,
                                "2_ext_reussis": int(parts[-3]) if parts[-3].isdigit() else 0,
                                "lf_reussis": int(parts[-2]) if parts[-2].isdigit() else 0,
                                "fautes_com": int(parts[-1]) if parts[-1].isdigit() else 0
                            }
                            data.append(player_data)
                        except ValueError as ve:
                            print(f"Error processing line: {line}\n{ve}")
                            continue

            # Create the final dictionary structure
            match_stats = {
                "joueurs": data,
                "totaux": {
                    "equipe": {},
                    "banc": {},
                    "5_de_depart": {}
                }
            }

            # Convert to JSON format
            json_data = json.dumps(match_stats, ensure_ascii=False, indent=2)

            # Save the JSON data to a file
            with open('stats_match.json', 'w', encoding='utf-8') as f:
                f.write(json_data)

            # Print the JSON data to the console
            print(json_data)

            # Return the data as JSON response
            return jsonify(match_stats), 200
        else:
            return jsonify({'message': 'File path not found or invalid'}), 400

    except Exception as e:
        return jsonify({'message': f"Error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True)
