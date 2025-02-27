#!/bin/bash

# Detener ejecución ante errores
set -e

# Corregir nombre de variables y comandos
echo "Apagando NGINX..."
sudo systemctl stop nginx

echo "Apagando NGROK..."
pkill -f "ngrok http 80" || true

echo "Actualizando repositorio..."
git pull origin main

echo "Reiniciando NGINX..."
sudo systemctl start nginx

echo "Iniciando NGROK..."
nohup ngrok http 80 > /dev/null 2>&1 &

# Espera mejorada compatible con sh
max_attempts=20
i=1
while [ $i -le $max_attempts ]; do
    ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' || true)
    if [[ "$ngrok_url" == http* ]]; then
        break
    fi
    sleep 1
    i=$((i + 1))
done

if [[ ! "$ngrok_url" == http* ]]; then
    echo "Error: Ngrok no respondió después de $max_attempts intentos"
    exit 1
fi

echo "Tu aplicación está disponible en: $ngrok_url"

# Ejecutar script adicional solo si existe
if [ -f "deploy.sh" ]; then
    echo "Ejecutando pasos adicionales..."
    bash deploy.sh  # Usar bash explícitamente
fi