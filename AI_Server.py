from flask import Flask, request, jsonify

from langchain.llms import HuggingFaceHub
from langchain.chains import RetrievalQA
from langchain.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEndpoint
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.prompts import PromptTemplate

embedding_model = HuggingFaceEmbeddings(model_name="sentence-transformers/all-mpnet-base-v2")
vectorstore = FAISS.load_local('./vectorDB/0409FAISS', embedding_model, allow_dangerous_deserialization=True)

template = """당신은 정릉동의 맛집들에 대해 박식한 도우미 입니다. 주어진 context를 참고하여 질문에 응답하세요. 그리고 다음사항을 준수하세요.
1. 한국어로 대답하세요.
2. 동네친구를 대하듯이 반말로 친근하게 답변하세요.


컨텍스트:
{context}

질문:
{question}

답변:"""

prompt = PromptTemplate(
    input_variables=["context", "question"],
    template=template,
)

llm = HuggingFaceEndpoint(
    endpoint_url="deepseek-ai/DeepSeek-R1-Distill-Qwen-14B",
    max_new_tokens=1024,
    top_k=3,
    top_p=0.80,
    typical_p=0.95,
    temperature=0.01,
    repetition_penalty=1.03,
    huggingfacehub_api_token="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"
)


# RetrievalQA 체인 생성 시, chain_type_kwargs에 프롬프트를 추가합니다.
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",  # 모든 문서를 하나로 합쳐서 사용
    retriever=vectorstore.as_retriever(),  # 앞서 생성한 FAISS 벡터스토어 사용
    chain_type_kwargs={"prompt": prompt}  # 사용자 정의 프롬프트 템플릿 적용
)

app = Flask(__name__)



@app.route('/chat', methods=['POST'])
def handle_chat():
    # 요청에서 JSON 데이터 추출
    data = request.get_json()
    user_input = data.get('message', '')
    result = qa_chain.invoke(user_input)

    print(f"받은 메시지: {user_input}")

    # 임시 응답 생성 (실제로는 전처리, RAG, LLM 호출 등이 들어감)
    response_text = f"AI 응답: '{result['result']}' "

    return jsonify({'response': response_text})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
    