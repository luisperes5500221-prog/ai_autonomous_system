#!/bin/bash

echo "🚀 INSTALANDO STACK COMPLETO IA AUTÓNOMA"

BASE_DIR=~/mi-proyecto-docker/ai_autonomous_system
cd $BASE_DIR || exit

echo "📁 Creando estructura avanzada..."

mkdir -p services/{n8n,flowise,chromadb,redis}
mkdir -p data/{n8n,flowise,chromadb,redis}
mkdir -p logs

echo "⚙️ Generando docker-compose extendido..."

cat > docker-compose.override.yml << 'EOF'
services:

  n8n:
    image: n8nio/n8n
    container_name: n8n
    ports:
      - "5678:5678"
    environment:
      - GENERIC_TIMEZONE=UTC
      - N8N_BASIC_AUTH_ACTIVE=false
    volumes:
      - ./data/n8n:/home/node/.n8n

  flowise:
    image: flowiseai/flowise
    container_name: flowise
    ports:
      - "3001:3000"
    volumes:
      - ./data/flowise:/root/.flowise

  chromadb:
    image: chromadb/chroma
    container_name: chromadb
    ports:
      - "8000:8000"
    volumes:
      - ./data/chromadb:/chroma

  redis:
    image: redis:7
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - ./data/redis:/data

EOF

echo "🔗 Configurando variables de entorno..."

cat >> .env << 'EOF'

# --- AI SYSTEM ---
OLLAMA_BASE_URL=http://ollama:11434
CHROMA_URL=http://chromadb:8000
REDIS_URL=redis://redis:6379

EOF

echo "🧠 Creando script de integración IA..."

mkdir -p scripts/ai

cat > scripts/ai/connect_ollama.sh << 'EOF'
#!/bin/bash
echo "🔗 Verificando conexión con Ollama..."

curl http://localhost:11434/api/tags || echo "❌ Ollama no responde"
EOF

chmod +x scripts/ai/connect_ollama.sh

echo "⚙️ Actualizando control.sh..."

cat > control.sh << 'EOF'
#!/bin/bash

COMPOSE_CMD="docker compose"

if ! command -v docker &> /dev/null; then
    echo "❌ Docker no instalado"
    exit 1
fi

function start_module() {
    module=$1
    echo "🚀 Iniciando módulo: $module"

    case $module in
        ai)
            $COMPOSE_CMD up -d ollama openwebui
            ;;
        core)
            $COMPOSE_CMD up -d n8n redis
            ;;
        memory)
            $COMPOSE_CMD up -d chromadb
            ;;
        agents)
            $COMPOSE_CMD up -d flowise
            ;;
        all)
            $COMPOSE_CMD up -d
            ;;
        *)
            echo "Uso: ./control.sh {ai|core|memory|agents|all}"
            ;;
    esac
}

function stop_all() {
    $COMPOSE_CMD down
}

case $1 in
    start)
        start_module $2
        ;;
    stop)
        stop_all
        ;;
    *)
        echo "Uso:"
        echo "./control.sh start ai"
        echo "./control.sh start core"
        echo "./control.sh start memory"
        echo "./control.sh start agents"
        echo "./control.sh start all"
        echo "./control.sh stop"
        ;;
esac
EOF

chmod +x control.sh

echo "📦 Actualizando git..."

git add .
git commit -m "full autonomous stack added"
git push

echo "✅ SISTEMA COMPLETO INSTALADO (SIN EJECUTAR)"
