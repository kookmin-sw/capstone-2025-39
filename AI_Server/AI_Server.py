from flask import Flask, request, jsonify

from langchain.chains import RetrievalQA
from langchain.vectorstores import FAISS
from langchain.prompts import PromptTemplate
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain_openai import OpenAIEmbeddings

load_dotenv()

embed_model = OpenAIEmbeddings(
        model="text-embedding-3-small"
    )
vectorstore = FAISS.load_local(
    './vectorDB/20250424FAISS',
    embed_model,
    allow_dangerous_deserialization=True
    )

template = """당신은 정릉동의 맛집들에 대해 박식한 도우미 입니다. 주어진 context를 참고하여 질문에 응답하세요. 그리고 다음사항을 준수하세요.
0. context에 리뷰정보가 포함되어있는 경우, 이는 실제 주민들의 방문 후기이므로 개인정보를 위해 참고만 할 뿐, 해당 내용을 수정없이 답변으로 내보내면 안됩니다.
1. 리뷰정보를 참고하였더라도, 당신이 직접 경험해본 것 처럼 말하지 마십시오. 당신은 어디까지나 해당 정보를 참고한 AI 도우미 일 뿐입니다.
2. 한국어로 대답하세요.
3. 친구를 대하듯이 답변하세요.
4. 음식점의 음식들을 추천할때, 가격 정보가 있다면 이 정보도 알려주는 것을 권장합니다.
5. 답변을 길게 생성하려고 하지 않아도 됩니다. 더이상 할 말이 없다면 답변을 끊으세요.



context:
{context}

question:
{question}

답변:"""

prompt = PromptTemplate(
    input_variables=["context", "question"],
    template=template,
)

llm = ChatOpenAI(
    model="gpt-4.1-nano-2025-04-14",
    max_tokens=1024,
    temperature=0.7,
    max_retries=2,
)

qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",  # 모든 문서를 하나로 합쳐서 사용
    retriever=vectorstore.as_retriever(),  # 앞서 생성한 FAISS 벡터스토어 사용
    chain_type_kwargs={"prompt": prompt},  # 사용자 정의 프롬프트 템플릿 적용
    return_source_documents=True # 검색된 문서를 함께 반환하도록 설정
)


# app = Flask(__name__)

# @app.route('/chat', methods=['POST'])
# def handle_chat():
#     # 요청에서 JSON 데이터 추출
#     data = request.get_json()
#     user_input = data.get('message', '')
#     result = qa_chain.invoke(user_input)

#     print(f"받은 메시지: {user_input}\n")
#     print(f"반환 결과: {result}")

#     response_text = f"AI 응답: '{result['result']}' "

#     return jsonify({'response': response_text})

if __name__ == '__main__':
    # app.run(host='0.0.0.0', port=5000, debug=True)
    print(qa_chain.invoke(input("입력: ")))