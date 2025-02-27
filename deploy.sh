#!/bin/bash
set -e  # Detener el script si hay un error

# 1. Configuración de Nginx
echo "Configurando Nginx..."
sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    server_name _;

    root /home/ubuntu/yo;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~ /\. {
        deny all;
    }

    error_page 404 /404.html;
    location = /404.html {
        internal;
    }
}
EOF'

# 2. Reiniciar Nginx
echo "Reiniciando Nginx..."
sudo systemctl restart nginx

# 3. Detener Ngrok si ya está corriendo
echo "Deteniendo Ngrok si está en ejecución..."
pkill -f "ngrok http 80" || true

# 4. Iniciar Ngrok en segundo plano
echo "Iniciando Ngrok..."
nohup ngrok http 80 > /dev/null 2>&1 &

# 5. Esperar a que Ngrok esté listo
echo "Esperando a que Ngrok genere la URL..."
sleep 5  # Espera inicial para que Ngrok se inicie

max_attempts=10
ngrok_url=""
for i in $(seq 1 $max_attempts); do
    ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' || true)
    if [[ "$ngrok_url" == http* ]]; then
        break
    fi
    sleep 2
done

# 6. Verificar si se obtuvo la URL
if [[ -z "$ngrok_url" ]]; then
    echo "Error: No se pudo obtener la URL de Ngrok después de $max_attempts intentos."
    exit 1
fi

# 7. Mostrar la URL generada
echo "¡Tu aplicación está disponible en: $ngrok_url"

# 8. Mantener el script en ejecución (opcional)
echo "Presiona Ctrl+C para detener Ngrok..."
while true; do
    sleep 1
done