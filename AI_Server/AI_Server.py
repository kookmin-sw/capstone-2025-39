from flask import Flask, request, jsonify
import json
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain.prompts import PromptTemplate
from langchain.chains import RetrievalQA, LLMChain
from langchain_community.vectorstores import FAISS
from dotenv import load_dotenv
from langchain.agents import tool
from langchain_core.utils.function_calling import convert_to_openai_function
from typing import List, Dict, Any
import requests
from langchain.agents.output_parsers import OpenAIFunctionsAgentOutputParser
from langchain.agents import AgentExecutor
from langchain.agents import create_openai_functions_agent
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder

load_dotenv()

# 임베딩 모델 및 벡터 스토어 초기화
embed_model = OpenAIEmbeddings(
    model="text-embedding-3-small"
)
vectorstore = FAISS.load_local(
    './vectorDB/20250424FAISS',
    embed_model,
    allow_dangerous_deserialization=True
)

# RAG를 위한 프롬프트 템플릿
rag_template = """당신은 정릉동의 맛집들에 대해 박식한 도우미 입니다. 주어진 context를 참고하여 질문에 응답하세요. 그리고 다음사항을 준수하세요.
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

rag_prompt = PromptTemplate(
    input_variables=["context", "question"],
    template=rag_template,
)

# LLM 모델 초기화
llm = ChatOpenAI(
    model="gpt-4o-mini-2024-07-18",
    max_tokens=1024,
    temperature=0.7,
)

# 1. RAG를 위한 도구 정의
@tool
def search_local_knowledge(query: str) -> str:
    """정릉동의 맛집과 장소에 대한 정보를 검색합니다. 이 도구는 사용자가 정릉동의 특정 음식점, 카페, 
    지역 명소 등에 대해 물어볼 때 사용합니다."""
    retriever = vectorstore.as_retriever()
    docs = retriever.get_relevant_documents(query)
    if not docs:
        return "해당 정보를 찾을 수 없습니다."
    
    # RAG를 통한 응답 생성
    qa_chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=retriever,
        chain_type_kwargs={"prompt": rag_prompt},
        return_source_documents=False
    )
    result = qa_chain.invoke(query)
    return result["result"]

# 2. 날씨 정보를 위한 도구 정의 (구현 필요)
@tool
def get_weather(location: str) -> str:
    """특정 장소의 현재 날씨 정보를 가져옵니다. 사용자가 날씨에 대해 물어볼 때 사용합니다."""
    # 여기에 실제 날씨 API 연동 코드가 들어갈 수 있습니다
    # 예시 응답을 반환합니다
    return f"{location}의 현재 날씨는 맑고 온도는 22도입니다. (이것은 예시 응답입니다. 실제 날씨 API를 연동해야 합니다.)"

# 3. 일반적인 대화를 위한 도구 정의
@tool
def general_conversation(query: str) -> str:
    """일반적인 대화, 인사, 감사 표현 등에 응답합니다. 사용자가 인사를 하거나 일상적인 대화를 할 때 사용합니다."""
    chain = LLMChain(
        llm=llm,
        prompt=PromptTemplate(
            input_variables=["query"],
            template="""당신은 친절하고 도움이 되는 AI 비서입니다. 사용자의 일반적인 대화에 자연스럽게 응답하세요. 한국어로 답변하고, 친구를 대하듯 응답하세요.

사용자 메시지: {query}

응답:"""
        )
    )
    response = chain.run(query=query)
    return response

# 도구 목록 정의
tools = [search_local_knowledge, get_weather, general_conversation]
openai_tools = [convert_to_openai_function(t) for t in tools]

# 시스템 메시지 정의
system_message = """당신은 사용자 질문의 의도를 파악하여 적절한 도구를 선택해 응답하는 정릉동 AI 비서입니다.

1. 사용자가 정릉동의 맛집, 장소, 음식점 등에 대해 물어보면 'search_local_knowledge' 도구를 사용하세요.
2. 사용자가 날씨에 대해 물어보면 'get_weather' 도구를 사용하세요.
3. 사용자가 인사하거나 일반적인 대화를 나누려 하면 'general_conversation' 도구를 사용하세요.

각 도구를 사용할 때는 사용자 질문을 명확히 이해하고 가장 적절한 도구를 선택하여 사용하세요."""

# 라우터 체인 설정
router_llm = ChatOpenAI(
    model="gpt-4o-mini-2024-07-18", 
    temperature=0
)

# 프롬프트 템플릿 생성
prompt = ChatPromptTemplate.from_messages([
    ("system", system_message),
    ("human", "{input}"),
    MessagesPlaceholder(variable_name="agent_scratchpad"),
])

# 에이전트 생성
agent = create_openai_functions_agent(
    llm=router_llm, 
    tools=tools, 
    prompt=prompt
)

# 에이전트 실행기 생성
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    return_intermediate_steps=True,
)

# Flask 앱 초기화
app = Flask(__name__)

@app.route('/chat', methods=['POST'])
def handle_chat():
    # 요청에서 JSON 데이터 추출
    data = request.get_json()
    user_input = data.get('message', '')
    
    # 에이전트 실행
    result = agent_executor.invoke({"input": user_input})
    
    print(f"받은 메시지: {user_input}\n")
    print(f"반환 결과: {result}")
    
    response_text = result["output"]
    
    return jsonify({'response': response_text})

if __name__ == '__main__':
    # 서버 실행 모드
    app.run(host='0.0.0.0', port=5000, debug=True)
    
    # 콘솔 테스트 모드
    # user_input = input("입력: ")
    # result = agent_executor.invoke({"input": user_input})
    # print(result) 