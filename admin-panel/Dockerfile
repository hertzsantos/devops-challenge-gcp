# Usa uma imagem leve de Python
FROM python:3.9-slim

# Define a pasta de trabalho
WORKDIR /app

# Instala as dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o script para dentro da imagem
COPY main.py .

# Comando que o Kubernetes vai executar ao subir o Pod
CMD ["python", "main.py"]