# 경량화된 Python 3.10 base image
FROM python:3.11-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 필수 패키지만 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl && \
    rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /app

# 프로젝트 설정 및 락 파일 복사
COPY pyproject.toml uv.lock .

# 락 파일을 사용하여 의존성 설치 (더 빠르고 재현 가능)
RUN uv sync --locked

# 소스 복사
COPY . .

# 포트 열기
EXPOSE 8080

# 실행 명령어
RUN uv run AI_Server.py
