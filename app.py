import os
import cv2
import numpy as np
import requests
import base64
from flask import Flask, request, jsonify
import pandas as pd

# --- CONFIGURAÇÃO ---
ROBOFLOW_API_KEY = "BYlcOctKDIP4438AfrHz"
MODEL_ID = "detector-de-gabaritos1/2" # O seu modelo que detecta e classifica

# Constrói o URL da API do Roboflow
API_URL = f"https://detect.roboflow.com/{MODEL_ID}?api_key={ROBOFLOW_API_KEY}"

# Inicializa a aplicação Flask
app = Flask(__name__)

def processar_gabarito(predictions):
    """
    Recebe as previsões do Roboflow e processa-as para encontrar as respostas marcadas.
    """
    if not predictions:
        return {}

    df = pd.DataFrame(predictions)
    tolerancia_y = df['height'].mean() / 2

    df['linha'] = (df['y'] // tolerancia_y).astype(int)
    
    respostas_marcadas = {}
    
    # Agrupa as previsões por linha (questão)
    questoes_agrupadas = sorted(df.groupby('linha'), key=lambda item: item[1]['y'].mean())
    
    for i, (_, grupo) in enumerate(questoes_agrupadas):
        grupo_ordenado = grupo.sort_values(by='x')
        
        bolha_marcada = grupo_ordenado[grupo_ordenado['class'] == 'marcada']
        
        if not bolha_marcada.empty:
            indice_da_marcada = bolha_marcada.index[0]
            indice_alternativa = list(grupo_ordenado.index).index(indice_da_marcada)
            respostas_marcadas[i] = indice_alternativa

    return respostas_marcadas

@app.route('/corrigir', methods=['POST'])
def corrigir_endpoint():
    if 'file' not in request.files:
        return jsonify({'error': 'Nenhum ficheiro foi enviado'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Nome de ficheiro vazio'}), 400

    if file:
        try:
            # Lê a imagem e prepara para o envio
            np_img = np.frombuffer(file.read(), np.uint8)
            img = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
            
            # Codifica a imagem para o formato base64
            retval, buffer = cv2.imencode('.jpg', img)
            img_str = base64.b64encode(buffer).decode('utf-8')

            # Define os cabeçalhos da requisição
            headers = {"Content-Type": "application/x-www-form-urlencoded"}

            print("A enviar imagem para a inferência no Roboflow...")
            # Envia a imagem para a API do Roboflow usando 'requests'
            response = requests.post(API_URL, data=img_str, headers=headers)
            response.raise_for_status() # Lança um erro se a requisição falhar
            
            result = response.json()
            print(f"-> {len(result.get('predictions', []))} detecções recebidas.")
            
            respostas_aluno = processar_gabarito(result.get('predictions', []))

            gabarito_mestre_exemplo = {
                0: 4, 1: 2, 2: 4, 4: 1, 5: 4, 7: 4, 8: 2, 9: 4
            }

            questoes_corretas = 0
            for questao, resposta_correta in gabarito_mestre_exemplo.items():
                if respostas_aluno.get(questao) == resposta_correta:
                    questoes_corretas += 1
            
            nota = (questoes_corretas / float(len(gabarito_mestre_exemplo))) * 10 if gabarito_mestre_exemplo else 0

            resposta_json = {
                'nota_final': round(nota, 2),
                'acertos': questoes_corretas,
                'total_questoes': len(gabarito_mestre_exemplo),
                'respostas_aluno': respostas_aluno
            }
            
            return jsonify(resposta_json)

        except Exception as e:
            return jsonify({'error': f'Ocorreu um erro no servidor: {str(e)}'}), 500

    return jsonify({'error': 'Erro inesperado'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)