# Utiliser une image Python légère
FROM python:3.9

# Installer Tesseract OCR et les dépendances système
RUN apt-get update && apt-get install -y tesseract-ocr && rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers du projet dans l'image
COPY . .

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Définir le port sur lequel l'application doit écouter
ENV PORT 8080

# Exposer le port 8080 pour Cloud Run
EXPOSE 8080

# Lancer l'API avec Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
