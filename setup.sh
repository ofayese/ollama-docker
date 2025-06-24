# run using docker
docker build -t valiantlynx/ollama-docker .
#start ollama nd ollama webui then:
docker run --name ollama-docker-container -d -p 8000:8000 -v $(pwd):/code valiantlynx/ollama-docker:latest

#connect to turborepo
git subtree add --prefix=apps/ollama-docker https://github.com/valiantlynx/ollama-docker.git main --squash
git subtree pull --prefix=apps/ollama-docker https://github.com/valiantlynx/ollama-docker.git main --squash
git subtree push --prefix=apps/ollama-docker https://github.com/valiantlynx/ollama-docker.git main

# Synology NAS deployment functions
deploy_to_synology() {
    # Check if running on NAS or remote machine
    if [[ -d "/volume1" ]]; then
        echo "Detected NAS environment - deploying locally on NAS..."
        
        # Create necessary directories on NAS
        mkdir -p /volume1/docker/ollama/ollama
        mkdir -p /volume1/docker/ollama/ollama-webui
        mkdir -p /volume1/docker/ollama/logs/ollama
        mkdir -p /volume1/docker/ollama/logs/webui
        
        # Copy project files to NAS deployment directory
        cp -r . /volume1/docker/ollama/
        
        echo "Files deployed locally on NAS successfully!"
    else
        echo "Deploying to Synology NAS at 10.0.1.15 from remote machine..."
        
        # Create necessary directories on NAS
        ssh root@10.0.1.15 "mkdir -p /volume1/docker/ollama/ollama"
        ssh root@10.0.1.15 "mkdir -p /volume1/docker/ollama/ollama-webui"
        ssh root@10.0.1.15 "mkdir -p /volume1/docker/ollama/logs/ollama"
        ssh root@10.0.1.15 "mkdir -p /volume1/docker/ollama/logs/webui"
        
        # Copy project files to NAS
        scp -r . root@10.0.1.15:/volume1/docker/ollama/
        
        echo "Files copied to Synology NAS successfully!"
    fi
}

start_synology_containers() {
    echo "Starting containers on Synology NAS..."
    
    # Check if running on NAS or remote machine
    if [[ -d "/volume1" ]]; then
        echo "Running on NAS - starting containers locally..."
        cd /volume1/docker/ollama && docker-compose up -d
        echo "Containers started locally on NAS!"
    else
        echo "Starting containers on remote NAS..."
        # Build and start containers on NAS
        ssh root@10.0.1.15 "cd /volume1/docker/ollama && docker-compose up -d"
        echo "Containers started on Synology NAS!"
    fi
    
    echo "Access the application at:"
    echo "  - Main App: http://10.0.1.15:8000"
    echo "  - Ollama WebUI: http://10.0.1.15:8080"
    echo "  - Ollama API: http://10.0.1.15:7869"
}

stop_synology_containers() {
    echo "Stopping containers on Synology NAS..."
    
    # Check if running on NAS or remote machine
    if [[ -d "/volume1" ]]; then
        echo "Running on NAS - stopping containers locally..."
        cd /volume1/docker/ollama && docker-compose down
        echo "Containers stopped locally on NAS!"
    else
        echo "Stopping containers on remote NAS..."
        ssh root@10.0.1.15 "cd /volume1/docker/ollama && docker-compose down"
        echo "Containers stopped on Synology NAS!"
    fi
}

# Usage instructions
show_synology_usage() {
    echo "Synology NAS Deployment Commands:"
    echo "  deploy_to_synology     - Deploy files to NAS"
    echo "  start_synology_containers - Start containers on NAS"
    echo "  stop_synology_containers  - Stop containers on NAS"
    echo ""
    echo "Manual deployment:"
    echo "  1. Run: deploy_to_synology"
    echo "  2. Run: start_synology_containers"
    echo ""
    echo "Note: Ensure SSH key authentication is set up for root@10.0.1.15"
}

# Uncomment the lines below to run deployment automatically
# deploy_to_synology
# start_synology_containers
