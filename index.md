## 정릉친구
내 손안의 지역 맞춤형 AI 도우미, 캡스톤디자인 39팀 정릉친구

정릉친구는 RAG(Retrieval-Augmented Generation) 기술을 기반으로 제작된 지역 특화 AI 서비스입니다.
동네 음식점부터 소규모 문화 장소까지, 홍보가 어려운 소상공인들의 정보를 정확하고 세심하게 제공합니다.사용자의 질문에 실시간으로 답변하며, 기존 검색 플랫폼에서 누락되기 쉬운 동네의 숨은 명소를 발굴해 연결합니다.

![Image](./ex.png)

### 주요 기능

- 맞춤형 추천: 위치·취향 기반 장소 추천

- 실시간 정보 업데이트: 영업 시간, 메뉴, 이벤트 등 신뢰도 높은 데이터 반영

- 소상공인 지원: 홍보가 어려운 가게를 AI가 직접 소개하여 지역 경제 활성화 기여

정릉친구는 단순 정보 제공을 넘어, 지역 상권의 생태계를 건강하게 유지하는 데 기여합니다. 방문객에게는 특색 있는 경험을, 소상공인에게는 새로운 고객 유입을 창출하며 지역 주민과 소비자가 함께 성장하는 선순환을 목표로 합니다.

"동네의 작은 이야기가 세상에 빛을 발하는 날까지."
AI 기술로 지역 경제의 가치를 재발견하고, 더 따뜻한 커뮤니티를 만들어갑니다.

### 프로젝트 소개
<div style="display: flex; justify-content: center;">
  <iframe 
    src="https://drive.google.com/file/d/1mo7bSc_oGux6TzSkEsfnGshnSrv4D8S5/preview" 
    width="90%" 
    height="400" 
    style="border: none;">
  </iframe>
</div>

### 팀 소개

<div align='center'>
  
<table>
    <thead>
        <tr>
            <th colspan="5"> 정릉친구 </th>
        </tr>
    </thead>
    <tbody>
         <tr>
           <td align='center'><a href="https://github.com/NathnSong" target='_blank'><img src="https://avatars.githubusercontent.com/u/198164727?s=88&v=4" width="100" height="100"></td>
           <td align='center'><a href="https://github.com/3004yechan" target='_blank'><img src="https://avatars.githubusercontent.com/u/62199985?v=4" width="100" height="100"></td>
           <td align='center'><a href="https://github.com/LEEByeongIn" target='_blank'><img src="https://avatars.githubusercontent.com/u/173124103?s=88&v=4" width="100" height="100"></td>
           <td align='center'><a href="https://github.com/KYH-ha" target='_blank'><img src="https://avatars.githubusercontent.com/u/203066826?s=88&v=4" width="100" height="100"></td>
         </tr>
         <tr>
           <td align='center'>송나단</td>
           <td align='center'>차예찬</td>
           <td align='center'>이병인</td>
           <td align='center'>강영환</td>
         </tr>
         <tr>
           <td align='center'>🎨</td>
           <td align='center'>🤖</td>
           <td align='center'>⚙️</td>
           <td align='center'>⚙️</td>
         </tr>
         <tr>
           <td align='center'>Front-end Developer</td>
           <td align='center'>AI Engineer</td>
           <td align='center'>Back-end Developer</td>
           <td align='center'>Back-end Developer</td>
         </tr>
    </tbody>
</table>

</div> 

### 사용법

Common
```bash
git clone https://github.com/kookmin-sw/capstone-2025-39.git
```

Client
<div markdown="1">

    1. Clone 'frontend' repository
    2. Create or update 'gradle.properties' to add your API key
    # gradle.properties.example 참고
    
    3. flutter pub get
    4. flutter run
    5. flutter build apk –release


</div>

Main_server
<div markdown="1">
    
    cd backend
    gradlew.bat build
    gradlew.bat bootRun

</div>

AI_server
<div markdown="1">

    docker pull leebyeongin/flask-ai-server
    docker run -d -p 8080:8080 —name flask-ai-server leebyeongin/flask-ai-server

</div>

### 기술스택

**Front-end**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)


**Back-end**

![Spring Boot](https://img.shields.io/badge/SpringBoot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)
![EC2](https://img.shields.io/badge/AWS_EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white) ![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white) ![Selenium](https://img.shields.io/badge/Selenium-43B02A?style=for-the-badge&logoColor=white) ![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)


**AI**

![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white) ![LangChain](https://img.shields.io/badge/LangChain-00B3EC?style=for-the-badge&logoColor=white)
![FAISS](https://img.shields.io/badge/FAISS-2E9AFE?style=for-the-badge&logoColor=white)

### 시스템 구조도
<img src="./docs/images/system-architecture3.png" width="800"/>

---

![수행결과보고서](./docs/수행결과보고서-39조.pdf)
