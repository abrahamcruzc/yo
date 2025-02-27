#!/bin/bash

# Detener ejecución ante errores
set -e

# Apagar NGINX
echo "Apagando NGINX..."
sudo systemctl stop nginx

# Apagar NGROK
echo "Apagando NGROK..."
pkill ngrok || true  # Ignorar error si no está corriendo

# Obtener últimos cambios del repositorio
echo "Clonando el repositorio..."
git pull origin main

# Instalar dependencias si es necesario (ejemplo)
# echo "Instalando dependencias..."
# npm install

# Construir aplicación si es necesario (ejemplo)
# echo "Construyendo aplicación..."
# npm run build

# Encender NGINX
echo "Encendiendo NGINX..."
sudo systemctl start nginx

# Generar URL pública con NGROK
echo "Generando URL pública de NGROK..."
nohup ngrok http 80 > /dev/null 2>&1 &

# Esperar hasta que Ngrok esté listo (máximo 20 segundos)
max_attempts=20
for ((i=1; i<=$max_attempts; i++)); do
  ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' || true)
  if [[ $ngrok_url == http* ]]; then
    break
  fi
  sleep 1
done

if [[ ! $ngrok_url == http* ]]; then
  echo "Error: No se pudo obtener la URL de Ngrok"
  exit 1
fi

echo "Tu página web está accesible en: $ngrok_url"

# Ejecutar script de despliegue adicional
echo "Ejecutando el script de despliegue..."
sh deploy.sh