#!/bin/bash
echo "🔗 Verificando conexión con Ollama..."

curl http://localhost:11434/api/tags || echo "❌ Ollama no responde"
