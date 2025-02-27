#!/bin/bash
set -e

# 1. Verificar que index.html existe
if [ ! -f "/home/ubuntu/yo/index.html" ]; then
    echo "Error: index.html no encontrado en /home/ubuntu/yo."
    exit 1
fi

# 2. Configurar Nginx
echo "Configurando Nginx..."
sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    server_name _;

    root /home/ubuntu/yo;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF'

# 3. Ajustar permisos
echo "Ajustando permisos..."
sudo chmod -R 755 /home/ubuntu/yo
sudo chown -R www-data:www-data /home/ubuntu/yo

# 4. Reiniciar Nginx
echo "Reiniciando Nginx..."
sudo systemctl restart nginx

# 5. Iniciar Ngrok
echo "Iniciando Ngrok..."
pkill -f "ngrok http 80" || true
nohup ngrok http 80 > /dev/null 2>&1 &

# 6. Obtener URL de Ngrok
echo "Esperando a que Ngrok genere la URL..."
sleep 5
ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

if [[ -z "$ngrok_url" ]]; then
    echo "Error: No se pudo obtener la URL de Ngrok."
    exit 1
fi

echo "¡Tu aplicación está disponible en: $ngrok_url"