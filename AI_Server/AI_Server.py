from flask import Flask, request, jsonify
import json
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain.prompts import PromptTemplate
from langchain.chains import RetrievalQA, LLMChain
from langchain_community.vectorstores import FAISS
from dotenv import load_dotenv
from langchain.agents import tool
from langchain_core.utils.function_calling import convert_to_openai_function
from typing import List, Dict, Any, Optional
import requests
from langchain.agents.output_parsers import OpenAIFunctionsAgentOutputParser
from langchain.agents import AgentExecutor
from langchain.agents import create_openai_functions_agent
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
import os
from datetime import datetime, timedelta

from utils import extract_weather_data

# OpenAI 및 기상청 API Key가 있는 .env 파일을 로드. 해당파일은 보안을 위해 깃헙으로 공유 X
load_dotenv()
KMA_API_KEY = os.getenv("KMA_API_KEY")

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
def search_local_knowledge(query: str) -> Dict[str, Any]:
    """정릉동의 맛집과 장소에 대한 정보를 검색합니다. 이 도구는 사용자가 정릉동의 특정 음식점, 카페, 
    지역 명소 등에 대해 물어볼 때 사용합니다.
    이 도구는 답변과 함께 참조된 가게 이름을 반환할 수 있습니다."""
    retriever = vectorstore.as_retriever()
    
    qa_chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=retriever,
        chain_type_kwargs={"prompt": rag_prompt},
        return_source_documents=True
    )
    
    chain_input = {"query": query}
    result = qa_chain.invoke(chain_input)
    
    answer = result.get("result", "해당 정보를 찾을 수 없습니다.")
    store_name: Optional[str] = None 
    
    source_documents = result.get("source_documents")
    if source_documents and len(source_documents) > 0:
        first_doc = source_documents[0]
        
        # 참조한 문서에서 가게명 추출
        page_content = getattr(first_doc, 'page_content', '')
        if page_content:
            lines = page_content.split('\n')
            for line in lines:
                if line.startswith("가게명:"):
                    store_name = line.replace("가게명:", "").strip()
                    break # Found store name, exit loop
        
        if not store_name:
            store_name_candidate = first_doc.metadata.get('source')
            if store_name_candidate and isinstance(store_name_candidate, str):
                store_name = os.path.basename(store_name_candidate)
                store_name = os.path.splitext(store_name)[0] # Remove extension
        
    return {"answer": answer, "store_name": store_name}

# 2. 날씨 정보를 위한 도구 정의 (구현 필요)
@tool
def get_weather(query: str) -> Dict[str, Any]:
    """정릉동의 초단기 예보 날씨 정보를 가져옵니다. 사용자가 날씨에 대해 물어볼 때 사용합니다.
    이 도구는 'answer' 키에 날씨 정보 문자열을, 'store_name' 키에 None을 포함하는 사전을 반환합니다."""
    datetime_now = datetime.now()
    request_time = datetime_now - timedelta(hours=1) # 초단기 예보가 1시간 단위로 발표하기 때문에, 에러회피를 위해 1시간 전의 데이터를 가져옴
    date = request_time.strftime("%Y%m%d")
    time = request_time.strftime("%H%M")
    short_term_forcast_url = f"https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtFcst?pageNo=1&numOfRows=100&dataType=JSON&base_date={date}&base_time={time}&nx=60&ny=128&authKey={KMA_API_KEY}"

    response = requests.get(short_term_forcast_url)
    weather_data = extract_weather_data(response.json())
    chain = LLMChain(
        llm=llm,
        prompt=PromptTemplate(
            input_variables=["weather_data"],
            template="""당신은 정릉동의 날씨 전문가입니다. 주어지는 초단기 예보 정보를 활용하여 사용자의 질문에 응답하세요. 
            각 카테고리는 다음과 같습니다.
            TH1: 기온 (섭씨)
            RN1: 강수량 (mm)
            SKY: 하늘상태 (맑음: 1, 구름많음: 3, 흐림: 4)
            PTY: 강수형태 (없음: 0, 비: 1, 비/눈: 2, 눈: 3, 빗방울: 5, 빗방울눈날림: 6, 눈날림: 7)
            WSD: 풍속 (m/s)

            다음 사항을 준수하세요.
            0. 주어지는 정보를 나열하듯이 답변하지 마세요. 요약하여 답변하세요.
            1. 5시간 이내의 예보 정보가 제공됩니다. 이를 종합하여 전체적인 날씨 상황을 파악하세요.
            2. 초단기 예보 정보는 실제 날씨와 다를 수 있습니다. 예를 들어, 비가 오지 않았는데 강수량이 있다면, 이는 빗방울이 날리는 것으로 해석합니다.
            3. 현재 시간은 {datetime_now}입니다. 
            4. 사용자가 날씨를 물어보는 이유를 고려해서, 사용자의 계획에 조언을 해주세요.
            
            초단기 예보 정보 = {weather_data}

            사용자 메시지: {query}

            응답:"""
        )
    )
    answer = chain.run(weather_data=weather_data, query=query, datetime_now=datetime_now)
    return {"answer": answer, "store_name": None}

# 3. 일반적인 대화를 위한 도구 정의
@tool
def general_conversation(query: str) -> Dict[str, Any]:
    """일반적인 대화, 인사, 감사 표현 등에 응답합니다. 사용자가 인사를 하거나 일상적인 대화를 할 때 사용합니다.
    이 도구는 'answer' 키에 대화 응답 문자열을, 'store_name' 키에 None을 포함하는 사전을 반환합니다."""
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
    return {"answer": response, "store_name": None}

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

    if not user_input:
        return jsonify({'error': 'No message provided'}), 400
    
    # 에이전트 실행
    agent_response = agent_executor.invoke({"input": user_input})
    
    final_text_response = agent_response.get("output")
    retrieved_store_name: Optional[str] = None

    # 가게명 받아오기, 혹은 null로 채우기
    intermediate_steps = agent_response.get("intermediate_steps", [])
    if intermediate_steps:
        _action, observation = intermediate_steps[-1]
        if isinstance(observation, dict):
            retrieved_store_name = observation.get("store_name")

            if final_text_response is None and isinstance(observation.get("answer"), str) :
                 final_text_response = observation.get("answer")

    print(f"받은 메시지: {user_input}\n")
    
    response_data = {
        'response': final_text_response,
        'store_name': retrieved_store_name
    }
    
    print(f"반환될 JSON: {json.dumps(response_data, ensure_ascii=False, indent=2)}")
    
    return jsonify(response_data)

if __name__ == '__main__':
    # 서버 실행 모드 (아래 주석 해제 시 Flask 서버로 실행)
    app.run(host='0.0.0.0', port=5000, debug=True)

    # # 콘솔 테스트 모드
    # while True:
    #     try:
    #         user_input = input("입력 (종료하려면 'exit' 입력): ")
    #         if user_input.lower() == 'exit':
    #             break
    #         if not user_input:
    #             continue

    #         agent_response = agent_executor.invoke({"input": user_input})
            
    #         final_text_response = agent_response.get("output")
    #         retrieved_store_name: Optional[str] = None

    #         intermediate_steps = agent_response.get("intermediate_steps", [])
    #         if intermediate_steps:
    #             _action, observation = intermediate_steps[-1]
    #             if isinstance(observation, dict):
    #                 retrieved_store_name = observation.get("store_name")
    #                 if final_text_response is None and isinstance(observation.get("answer"), str) :
    #                     final_text_response = observation.get("answer")

    #         output_data = {
    #             "response": final_text_response,
    #             "store_name": retrieved_store_name
    #         }
    #         print(f"응답: {json.dumps(output_data, ensure_ascii=False, indent=2)}")
    #     except EOFError: # Ctrl+D or similar
    #         break
    #     except KeyboardInterrupt: # Ctrl+C
    #         break
    # print("콘솔 테스트 모드를 종료합니다.") 