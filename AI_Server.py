from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/chat', methods=['POST'])
def handle_chat():
    # 요청에서 JSON 데이터 추출
    data = request.get_json()
    user_input = data.get('message', '')

    print(f"받은 메시지: {user_input}")

    # 임시 응답 생성 (실제로는 전처리, RAG, LLM 호출 등이 들어감)
    response_text = f"AI 응답: '{user_input}' !"

    return jsonify({'response': response_text})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
    