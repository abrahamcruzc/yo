#!/bin/bash
set -e

# 1. Corregir nombres de comandos y evitar recursión
SCRIPT_NAME=$(basename "$0")

# 2. Función para manejar NGINX
manage_nginx() {
    echo "Deteniendo NGINX..."
    sudo systemctl stop nginx || true
    
    echo "Reiniciando NGINX..."
    sudo systemctl start nginx
    sudo systemctl status nginx --no-pager
}

# 3. Detener procesos colgados
echo "Limpiando procesos anteriores..."
pkill -f "ngrok http 80" || true
sudo fuser -k 80/tcp || true

# 4. Actualizar repositorio
echo "Actualizando código..."
git pull origin main

# 5. Iniciar servicios
manage_nginx

echo "Iniciando NGROK..."
nohup ngrok http 80 > /dev/null 2>&1 &

# 6. Espera mejorada para Ngrok
max_attempts=20
for i in $(seq 1 $max_attempts); do
    ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' || true)
    [[ "$ngrok_url" == http* ]] && break
    sleep 1
done

[[ "$ngrok_url" != http* ]] && { echo "Error: Ngrok no respondió"; exit 1; }

echo "URL pública: $ngrok_url"

# 7. Evitar recursión
if [ "$SCRIPT_NAME" != "deploy.sh" ]; then
    echo "Ejecutando pasos adicionales..."
    bash deploy.sh
else
    echo "Despliegue completo. Verificar: $ngrok_url"
fi