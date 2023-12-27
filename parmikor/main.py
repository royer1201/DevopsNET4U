import paramiko

def update_machine(ssh):
    print("Updating the machine...")
    command = "sudo apt-get update -y && sudo apt-get upgrade -y"
    stdin, stdout, stderr = ssh.exec_command(command)
    #print(stdout.read().decode('utf-8'))
    #print(stderr.read().decode('utf-8'))

def change_etc_hosts(ssh):
    print("Changing /etc/hosts...")

    # Get IP address from the user
    ip_address = input("Enter the IP address: ")

    # Get hostnames from the user (comma-separated)
    hostnames = input("Enter the hostnames (comma-separated): ")

    # Construct the command to append to /etc/hosts
    command = f"echo '{ip_address} {hostnames}' | sudo tee -a /etc/hosts"

    # Execute the command on the remote machine
    stdin, stdout, stderr = ssh.exec_command(command)
    
    # Print the output and any errors
    print(stdout.read().decode('utf-8'))
    print(stderr.read().decode('utf-8'))

def create_new_folder_and_file(ssh):
    
    print("Creating a new folder with a file...")
    
    # Get folder name from the user
    folder_name = input("Enter the name of the folder: ")

    # Get text file name from the user
    file_name = input("Enter the name of the text file (with .txt extension): ")

    # Construct the commands to create a new folder and file
    create_folder_command = f"mkdir {folder_name}"
    create_file_command = f"touch {folder_name}/{file_name}"

    # Execute the commands on the remote machine
    stdin, stdout, stderr = ssh.exec_command(create_folder_command)
    print(stdout.read().decode('utf-8'))
    print(stderr.read().decode('utf-8'))

    stdin, stdout, stderr = ssh.exec_command(create_file_command)
    print(stdout.read().decode('utf-8'))
    print(stderr.read().decode('utf-8'))

def main():
    host = '192.168.29.134'
    port = 22
    username = 'royer'
    password = 'shmuelc10'

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port, username, password)

    while True:
        print("\nMenu:")
        print("1. Update the machine")
        print("2. Change /etc/hosts")
        print("3. Create a new folder with a file")
        print("4. Exit")

        choice = int(input("Enter your choice: "))

        if choice == 1:
            update_machine(ssh)
        elif choice == 2:
            change_etc_hosts(ssh)
        elif choice == 3:
            create_new_folder_and_file(ssh)
        elif choice == 4:
            print("Exiting the script.")
            break
        else:
            print("Invalid choice. Please enter a valid option.")

    ssh.close()

if __name__ == "__main__":
    main()
