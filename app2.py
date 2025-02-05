import json

# Charger les données du fichier JSON
with open('stats_match.json', 'r') as file:
    data = json.load(file)

# Fonction pour calculer l'efficacité d'un joueur (simple exemple)
def calculer_efficacite(joueur):
    points = joueur['nb_pts_marques']
    tps_jeu = joueur['tps_jeu']
    
    # Gérer les différents formats de temps de jeu
    try:
        if tps_jeu != "|" and tps_jeu != "x":
            # Le temps de jeu est sous forme "minutes:secondes"
            minutes, secondes = map(int, tps_jeu.split(":"))
            temps_en_secondes = minutes * 60 + secondes
        else:
            # Le temps de jeu est "x" ou "|", ce qui signifie un temps de jeu invalide ou inconnu
            temps_en_secondes = 0
    except ValueError:
        # Si le format du temps est invalide (comme "[23s"), on le considère comme un temps de jeu 0
        temps_en_secondes = 0
    
    # Calcul d'efficacité simple (points par minute de jeu)
    if temps_en_secondes > 0:
        efficacite = points / (temps_en_secondes / 60)
    else:
        efficacite = 0
    
    # Retourner l'efficacité et autres stats importantes
    return {
        'numero': joueur['numero'],
        'nom': joueur['nom'],
        'points': points,
        'efficacite': efficacite,
        'fautes': joueur['fautes_com'],
        'tps_jeu': temps_en_secondes
    }

# Calculer l'efficacité pour chaque joueur
joueurs_avec_eff = [calculer_efficacite(joueur) for joueur in data['joueurs']]

# Trier les joueurs par efficacité décroissante et par points
joueurs_tries = sorted(joueurs_avec_eff, key=lambda x: (x['efficacite'], x['points']), reverse=True)

# Sélectionner les meilleurs joueurs pour un match
# Par exemple, les 5 meilleurs joueurs (dépend de la taille de l'équipe)
meilleurs_joueurs = joueurs_tries[:5]

# Afficher les meilleurs joueurs sélectionnés avec des commentaires sur pourquoi ils ont été choisis
print("Meilleurs joueurs pour le match:")
for joueur in meilleurs_joueurs:
    # Commentaires sur la sélection du joueur
    if joueur['efficacite'] > 1.0:
        commentaire = f"{joueur['nom']} est un excellent choix grâce à son efficacité élevée avec {joueur['efficacite']:.2f} points par minute. Il peut être crucial pour les moments décisifs du match."
    elif joueur['points'] > 10:
        commentaire = f"{joueur['nom']} a marqué un nombre impressionnant de {joueur['points']} points, ce qui montre qu'il est un atout offensif majeur."
    else:
        commentaire = f"{joueur['nom']} a bien contribué malgré un temps de jeu limité. Son efficacité peut augmenter avec plus de minutes sur le terrain."

    # Afficher les stats et le commentaire
    print(f"\n{joueur['nom']} - Points: {joueur['points']} - Efficacité: {joueur['efficacite']:.2f} - Temps de jeu: {joueur['tps_jeu']}s - Fautes: {joueur['fautes']}")
    print("Commentaire:", commentaire)
