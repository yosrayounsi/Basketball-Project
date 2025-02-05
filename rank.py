from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import io
import pytesseract
from PIL import Image
import json

app = FastAPI()

# Add CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins or specify your Flutter Web app URL
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

@app.post("/select-top5/")
async def select_top5(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(io.BytesIO(contents))

    # Perform OCR on the image
    text = pytesseract.image_to_string(image)
    
    # Process the extracted text
    lines = text.strip().split('\n')
    players = []

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
                    # Calculate a performance score based on multiple statistics
                    player_data["score"] = (
                        player_data["nb_pts_marques"] * 2 +
                        player_data["nb_tirs_reussis"] * 1.5 +
                        player_data["3_pts_reussis"] * 3 +
                        player_data["2_int_reussis"] * 2 +
                        player_data["2_ext_reussis"] * 2 +
                        player_data["lf_reussis"] * 1 -
                        player_data["fautes_com"] * 1.5
                    )
                    players.append(player_data)
                except ValueError:
                    continue
    
    # Sort players by calculated performance score in descending order
    top5_players = sorted(players, key=lambda x: x["score"], reverse=True)[:5]

    return {"top5_joueurs": top5_players}
