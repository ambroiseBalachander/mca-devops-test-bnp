# --- Étape 1 : build de l'application Angular ---
# Image Chainguard Node : contient Node + npm, uniquement pour compiler.
# N'est PAS présente dans l'image finale (multi-stage build).
FROM cgr.dev/chainguard/node:latest AS build

WORKDIR /app

# On copie d'abord les fichiers de dépendances seuls (pas encore le code).
# Si package*.json ne change pas, "npm ci" ne retélécharge pas tout
# node_modules aux builds suivants (cache Docker).
COPY package*.json ./

# npm ci (plutôt que npm install) : installe exactement les versions
# verrouillées dans package-lock.json, sans jamais le modifier.
RUN npm ci

# On copie le reste du code source seulement maintenant.
COPY . .

# Build de production Angular : optimise, minifie, "tree-shake" le code.
# Génère les fichiers statiques finaux dans dist/frontend/browser/.
RUN npm run build --configuration=production

# --- Étape 2 : image finale, minimale, pour servir les fichiers statiques ---
# Chainguard nginx : serveur web minimal, sans shell, sans package manager,
# tourne en non-root par défaut, écoute sur le port 8080 (pas 80).
FROM cgr.dev/chainguard/nginx:latest

# Documente le port utilisé (informatif, n'ouvre rien en soi).
EXPOSE 8080

# On récupère UNIQUEMENT les fichiers statiques compilés depuis l'étape
# "build" ci-dessus. Node, npm, le code source TypeScript : tout est jeté,
# ça n'existe plus dans cette image finale.
COPY --from=build /app/dist/frontend/browser /usr/share/nginx/html

# Remplace la config nginx principale (pas un fragment conf.d) :
# nécessaire pour le fallback SPA Angular ET pour les chemins temporaires
# compatibles avec le mode non-root de Chainguard.
COPY nginx.conf /etc/nginx/nginx.conf

# Déclaration explicite pour satisfaire le scanner de sécurité Semgrep
USER 101