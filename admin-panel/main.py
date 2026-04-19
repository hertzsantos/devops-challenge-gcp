#Este script simula o painel. Ele tentará criar um arquivo chamado teste.txt dentro do seu bucket para provar que o Workload Identity (o equivalente ao IRSA da AWS ) está funcionando.

import os
from google.cloud import storage

def upload_test():
    # Pega o nome do bucket das variáveis de ambiente que definimos no YAML
    bucket_name = os.environ.get("BUCKET_NAME")
    project_id = os.environ.get("PROJECT_ID")
    
    print(f"Iniciando teste no projeto {project_id}...")
    
    try:
        # O cliente busca automaticamente a identidade vinculada ao Pod (Workload Identity)
        storage_client = storage.Client(project=project_id)
        bucket = storage_client.bucket(bucket_name)
        
        # Cria um arquivo de teste no bucket
        blob = bucket.blob("sucesso_infra.txt")
        blob.upload_from_string("A infraestrutura do desafio funciona!")
        
        print(f"✅ SUCESSO: Arquivo enviado para o bucket {bucket_name}!")
    except Exception as e:
        print(f"❌ ERRO: Não foi possível acessar o bucket. Detalhes: {e}")

if __name__ == "__main__":
    upload_test()