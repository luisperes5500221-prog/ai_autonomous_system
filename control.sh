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
