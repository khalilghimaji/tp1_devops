# ─────────────────────────────────────────────────────────────────
# Image de base : python:3.12-alpine
# Choix justifié : Alpine Linux est une distribution ultra-légère
# (~5 MB) qui réduit drastiquement la taille finale de l'image
# comparée à python:3.12 (~1 GB) ou python:3.12-slim (~130 MB).
# ─────────────────────────────────────────────────────────────────
FROM python:3.12-alpine

# Métadonnées de l'image
LABEL maintainer="khalilghimaji@gmail.com"
LABEL description="Visit Counter - Application Flask + Redis"

# ─────────────────────────────────────────────────────────────────
# Création d'un utilisateur non-root pour la sécurité.
# Ne jamais exécuter une application en tant que root dans un
# conteneur : en cas de faille, l'attaquant aurait les droits root
# sur le système hôte.
# ─────────────────────────────────────────────────────────────────
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Répertoire de travail de l'application
WORKDIR /app

# ─────────────────────────────────────────────────────────────────
# Copie des dépendances AVANT le code source.
# Docker met en cache chaque couche (layer). En copiant
# requirements.txt en premier, la couche d'installation pip
# n'est reconstruite QUE si les dépendances changent,
# et non à chaque modification du code source.
# ─────────────────────────────────────────────────────────────────
COPY requirements.txt .

# Installation des dépendances Python
# --no-cache-dir : évite de stocker le cache pip dans l'image
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code source de l'application
COPY app.py .

# Attribution des fichiers à l'utilisateur non-root
RUN chown -R appuser:appgroup /app

# Basculer vers l'utilisateur non-root
USER appuser

# Port exposé par l'application Flask
EXPOSE 5000

# ─────────────────────────────────────────────────────────────────
# CMD : commande exécutée au démarrage du conteneur.
# Utilise la forme JSON (exec form) pour que le processus
# reçoive bien les signaux Unix (SIGTERM pour arrêt gracieux).
# ─────────────────────────────────────────────────────────────────
CMD ["python", "app.py"]