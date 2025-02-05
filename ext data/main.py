from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi import File, UploadFile
import io
import pytesseract
from PIL import Image
import json

app = FastAPI()

# Add CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins or you can specify the URL of your Flutter Web app
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

# Your existing FastAPI routes
@app.post("/extract-stats/")
async def extract_stats(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(io.BytesIO(contents))

    # Perform OCR on the image (using the default language - English)
    text = pytesseract.image_to_string(image)
    
    # Process the extracted text as needed
    lines = text.strip().split('\n')
    data = []

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

    # Return the JSON response
    return match_stats
