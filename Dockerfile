FROM python:3.12-slim

WORKDIR /code 

COPY ./requirements.txt ./

# Install system dependencies including SSH client for Synology deployment
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        openssh-client && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir -r requirements.txt

COPY ./src ./src

# Create log directories for Synology NAS compatibility
RUN mkdir -p /code/logs

EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
