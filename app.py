from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd

# Initialiser l'application Flask
app = Flask(__name__)
CORS(app)  # Autoriser les requêtes cross-origin

@app.route('/meilleurs-joueurs', methods=['POST'])
def meilleurs_joueurs():
    try:
        # Récupérer le JSON envoyé depuis la requête Flutter
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Aucune donnée JSON fournie'}), 400

        # Récupérer les joueurs des deux équipes
        joueurs = data['equipes']['locaux']['joueuses'] + data['equipes']['visiteurs']['joueuses']
        df = pd.DataFrame(joueurs)

        # Vérifier et convertir les temps de jeu
        if 'tps_de_jeu' in df.columns:
            df['tps_de_jeu'] = df['tps_de_jeu'].apply(lambda x: f"00:{x}" if len(x.split(':')) == 2 else x)
            df['tps_de_jeu'] = pd.to_timedelta(df['tps_de_jeu'])
        else:
            return jsonify({'error': "La colonne 'tps_de_jeu' est manquante dans les données JSON."}), 400

        # Vérifier les colonnes nécessaires
        required_columns = {'pts_marques', 'tirs_reussis', 'fautes'}
        if required_columns.issubset(df.columns):
            df['pts_par_minute'] = df['pts_marques'] / (df['tps_de_jeu'].dt.total_seconds() / 60)
            df['score'] = (2 * df['pts_par_minute'] +
                           1.5 * df['tirs_reussis'] -
                           1 * df['fautes'])

            # Trier les joueurs par score et afficher les meilleurs
            best_players = df.sort_values(by='score', ascending=False).head(5)
            result = best_players[['nom', 'prenom', 'score']].to_dict(orient='records')
            return jsonify(result)
        else:
            return jsonify({'error': f"Les colonnes nécessaires {required_columns} sont manquantes dans les données JSON."}), 400

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
