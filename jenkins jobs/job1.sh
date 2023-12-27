#!/bin/bash

# Function to install Docker on a remote slave
install_docker() {
	echo "Checking if Docker is already installed on the remote slave..."
    ssh royer@$REMOTE_IP "sudo docker --version" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Docker is already installed on the remote slave."
    else
        echo "Installing Docker on remote slave..."
        ssh royer@$REMOTE_IP "sudo curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh &&
    	sudo apt-get update -y"
    fi   
}

# Function to pull Docker images
pull_images() {
    # Define the image name
   
	
    # Check if the image exists on the remote server
    if ssh royer@$REMOTE_IP "sudo docker images --format '{{.Repository}}'" | grep -q "^$IMAGE_NAME$"; then
        echo "The Docker image $IMAGE_NAME is already present on the remote server."
    else
        # Image does not exist on the remote server, pull it
        echo "Pulling the Docker image $IMAGE_NAME on the remote server..."
        ssh royer@$REMOTE_IP "sudo docker pull $IMAGE_NAME"
    fi
}

# Function to deploy containers
deploy_containers() {
   echo "Deploying containers..."
	CONT_PORT=$NUMBER_PORT
    # Deploy the containers
    for ((i=0; i<$NUM_CONTAINERS; i++)); do
        if [ -n "$NUMBER_PORT" ]; then
            NUMBER_PORT=$(($CONT_PORT + i))  # Adjust the port number and protocol as needed
        else
            NUMBER_PORT=""
        fi
        echo "Deploying container $CONTAINER_NAME-$i..."
        ssh royer@$REMOTE_IP "sudo docker run --name $CONTAINER_NAME-$i -d -p $NUMBER_PORT:$CONT_PORT $IMAGE_NAME"
    done

    echo "Deployment completed."
}

# Function to destroy containers
destroy_containers() {

    # Check if the container exists
    if ssh royer@$REMOTE_IP "sudo docker ps -a --format '{{.Names}}'" | grep -q $CONT_NAME_DESTROY; then
        echo "Destroying container $CONT_NAME_DESTROY..."
        ssh royer@$REMOTE_IP "sudo docker rm -f $CONT_NAME_DESTROY"
        echo "Container $CONT_NAME_DESTROY destroyed."
    else
        echo "Container $CONT_NAME_DESTROY does not exist."
    fi
}

# Function to stop/start containers
stop_start_containers() {
    if [ "$ACTION" == "stop" ]; then
        echo "Stopping container $CONT_NAME_ACTION..."
        ssh royer@$REMOTE_IP "sudo docker stop $CONT_NAME_ACTION"
    elif [ "$ACTION" == "start" ]; then
        echo "Starting container $CONT_NAME_ACTION..."
        ssh royer@$REMOTE_IP "sudo docker start $CONT_NAME_ACTION"
    else
        echo "Invalid action. Please use 'stop' or 'start'."
    fi
}

# Display the menu

echo "Menu:"
echo "1. Install Docker on remote slave"
echo "2. Pull images"
echo "3. Deploy containers"
echo "4. Destroy containers"
echo "5. Stop/Start containers"
echo "0. Exit"

case $choice in
  
  1) install_docker ;;
  2) pull_images ;;
  3) deploy_containers ;;
  4) destroy_containers ;;
  5) stop_start_containers ;;
  0) echo "Exiting. Goodbye!"; exit ;;
  *) echo "Invalid choice. Please enter a number between 0 and 5." ;;
esac

