#!/bin/bash

# Apagar NGINX
echo "Apagando NGINX..."
sudo systemctl stop nginx

# Apagar NGROK
echo "Apagando NGROK..."
pkill ngrok

# Clonar los últimos cambios del repositorio
echo "Clonando el repositorio..."
git pull origin main

# Encender NGINX
echo "Encendiendo NGINX..."
sudo systemctl start nginx

# Generar URL pública con NGROK
echo "Generando URL pública de NGROK..."
nohup ngrok http 80 &

# Desplegar la URL de NGROK
sleep 5  # Esperar que NGROK inicie
ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r .tunnels[0].public_url)
echo "Tu página web está accesible en: $ngrok_url"

# Ejecutar el script de despliegue
echo "Ejecutando el script de despliegue..."
sh deploy.sh
