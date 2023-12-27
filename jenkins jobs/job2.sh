#!/usr/bin/python3
import os
import boto3
import paramiko


# Checks that boto3 and paramiko are installed
if os.system("pip3 show boto3 &> /dev/null") != 0 or os.system("/usr/bin/pip3 show paramiko &> /dev/null") != 0:
    print("Installing required packages...")

    # If not installed, install boto3 and paramiko
    os.system("python3 -m venv venv")
    os.system("source venv/bin/activate && pip3 install boto3")

    print("Package installation completed.")
else:
    print("boto3 and paramiko are already installed.")

# AWS Credentials and Region
AWS_ACCESS_KEY = 'AKIAVGJ32V6IWYDHAAWJ'
AWS_SECRET_KEY = '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'
AWS_REGION = 'eu-west-1'

# Create an EC2 client
ec2 = boto3.client('ec2', aws_access_key_id=AWS_ACCESS_KEY, aws_secret_access_key=AWS_SECRET_KEY, region_name=AWS_REGION)

# A python function the creates with boto3 instances
def install_instances():
    
    
    
    
    try:
        
        # Specify the AMI ID for Ubuntu (you can use the latest Ubuntu LTS version)
        ubuntu_ami_id = 'ami-0694d931cee176e7d'
        
        # Specify the instance type (e.g., t2.micro)
        instance_type = 't2.micro'
        
        # Specify the number of instances to launch
        num_instances = 2
        
        # Launch EC2 instances
        response = ec2.run_instances(
        ImageId=ubuntu_ami_id,
        InstanceType=instance_type,
        MinCount=num_instances,
        MaxCount=num_instances,
        KeyName='irland_key',  
        UserData='''#!/bin/bash
        # Add any user data or initialization scripts here
        echo "Hello from UserData!"''',
        )
        
        # Extract instance IDs from the response
        instance_ids = [instance['InstanceId'] for instance in response['Instances']]
        
        # Wait for instances to be in the 'running' state
        print("It will take a while to initialize the instances...")
        waiter = ec2.get_waiter('instance_running')
        waiter.wait(InstanceIds=instance_ids)
        
        print(f"Successfully launched {num_instances} EC2 instances with IDs: {', '.join(instance_ids)}")
    
    except Exception as e:
        print(f"Error launching EC2 instances: {e}")
        
        
def install_packages():

    print("Function to install Ansible on the remote host...")
    
    #remote_host = "ubuntu@{}".format(ip)
    ip = os.getenv('remote_ip')
    remote_host = "ubuntu@{}".format(ip)
        
    private_key_path = "/home/royer/scripts/aws_project/irland_key.pem"
    
    # Generate SSH key pair if not already present
    if not os.path.exists(private_key_path):
        os.system('ssh-keygen -t rsa -b 2048 -f {} -N ""'.format(private_key_path))

    # Add the remote host key to the known_hosts file
    os.system('ssh-keyscan -H {} >> ~/.ssh/known_hosts'.format(remote_host))

    packages_to_install = [
        "docker.io",
        "ansible",
        "python3",
        "net-tools",
    ]

    # Construct the package list string
    package_list = ' '.join(packages_to_install)
    os.system("cd /home/royer/scripts/aws_project")
    print(os.getcwd())
    os.system('sudo ssh-keyscan -H {} >> ~/.ssh/known_hosts'.format(ip))
    
    # Install packages on the remote host using SSH
    command = 'sudo ssh -o StrictHostKeyChecking=no -i "{}" {} "sudo apt-get update && sudo apt-get install -y {}"'.format(private_key_path, remote_host, package_list)
    

    print("Command:", command)

    # Execute the command
    os.system(command)


def deploy_instance():

	# Create a new EC2 instance
	# Launch EC2 instances
    response = ec2.run_instances(
    ImageId='ami-0694d931cee176e7d',
    InstanceType='t2.micro',
    MinCount=1,
    MaxCount=1,
    KeyName='irland_key',  # Replace with your key pair name
    )
    instance_id = response['Instances'][0]['InstanceId']

    print(f"New instance created with ID: {instance_id}")

def start_instance():
	
	response = ec2.start_instances(InstanceIds=['i-097140018b93c6bd6'])

def stop_instance():

	response = ec2.stop_instances(InstanceIds=['i-097140018b93c6bd6'])

def destroy_instance():

	response = ec2.terminate_instances(InstanceIds=['i-097140018b93c6bd6'])

def show_all_instances():

	response = ec2.describe_instances()
	for reservation in response['Reservations']:
		for instance in reservation['Instances']:
			print(f"Instance ID: {instance['InstanceId']}")
			print(f"   State: {instance['State']['Name']}")
			print(f"   Public IP: {instance.get('PublicIpAddress', 'N/A')}")
			print(f"   Private IP: {instance.get('PrivateIpAddress', 'N/A')}")
# Menu
menu_options = {
    "1": install_instances,
    "2": install_packages,
    "3": deploy_instance,
    "4": start_instance,
    "5": stop_instance,
    "6": destroy_instance,
    "7": show_all_instances,
}

# Display the menu
print("\nEnter your choice:")
print("1. Install 2 EC2 instances (Python/Boto3)")
print("2. Install All packages")
print("3. Deploy new instance")
print("4. Start instance")
print("5. Stop instance")
print("6. Destroy Instance")
print("7. Show all Instances")


# Process user choice using the dictionary

choiceme = os.getenv('choice')
chosen_function = menu_options.get(choiceme)
if chosen_function:
	chosen_function()
else:
	print("Invalid choice. Please enter a valid option.")



