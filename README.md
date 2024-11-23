# README.md

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* Contents:
    * [Introduction](#introduction)
    * [Repository Structure](#repository-structure)
    * [Setup Instructions](#setup-instructions)
    * [Usage](#usage)
<!-- /code_chunk_output -->



## Introduction:
Using Jenkins to automate the process of building, testing and deploying a microservice application to Docker, Kubernetes for the NT548.P11 course - Fall 2024 semester at University of Information Technology - VNUHCM.


## Repository structure:
```txt
CI-CD-pipeline-with-Jenkins
  ├── app
  │   ├── main.py
  │   ├── schema.py
  │   └── utils
  │       ├── __init__.py
  │       ├── data_processing.py
  │       └── logging.py
  ├── assets
  ├── deployment-helmchart
  │   ├── .helmignore
  │   ├── Chart.yaml
  │   ├── templates
  │   │   ├── _helpers.tpl
  │   │   ├── deployment.yaml
  │   │   ├── hpa.yaml
  │   │   ├── ingress.yaml
  │   │   ├── NOTES.txt
  │   │   ├── service.yaml
  │   │   ├── serviceaccount.yaml
  │   │   └── tests
  │   │       └── test-connection.yaml
  │   └── values.yaml
  ├── Dockerfile
  ├── Jenkinsfile
  ├── models
  │   └── model.pkl
  ├── README.md
  ├── requirements.txt
  └── tests
      └── test_model_correctness.py


```

## Setup Instructions:
1. **Create EC2 instances on AWS Console:**
   - We need to create 2 EC2 instances: one for Jenkins and one for SonarQube.

   - Go to the EC2 section in AWS.
   ![EC2_section](assets/EC2-section.png)

   - Click on ``Launch instances``.
   ![Launch_instances](assets/Launch_instances.png)

   - The first EC2 instance is named ``Group12-Jenkins``.
   ![EC2_name_Group12-Jenkins](assets/Launch_jenkins_ec2.png)

   - The Jenkins EC2 uses Ubuntu 22.04.
   ![Ubuntu_22.04](assets/Ubuntu_22.04.png)

   - We choose the instance type ``t2.small``.
   ![t2.small](assets/t2.small.png)

   - Now create a key pair so that we can connect to the EC2 later.
   ![Key_pair](assets/key_pair.png)

   - Configure the storage with 25 GiB and create the instance.
   ![Storage_EC2](assets/storage_ec2.png)

   - Go to ``Security`` section in the Jenkins instance and click on the ``Security groups`` to edit it.
   ![security_section](assets/security_section.png)

   - Add a rule with Port range 8080, so that we can access Jenkins on this EC2 using port 8080.
   ![add_rule_port_8080](assets/add_port_8080.png)

   - Now, the same as Jenkins EC2, we create a EC2 named as ``Group12-SonarQube``, with Ubuntu 22.04. The instance type is ``t2.medium`` to avoid some errors when setting up SonarQube. Also, add a new rule with port 9000 in `` Security group``.
   ![sonar_qube_ec2](assets/SonarQube_ec2.png)
   ![instance_type_t2.medium](assets/instance_type_t2.medium.png)
   ![port9000](assets/port9000.png)

2. **Setting up Jenkins inside the Group12-Jenkins instance:**
   - To access the Group12-Jenkins instance via ssh key pair, first we copy its ``Public IPv4 address``.
   ![jenkins_ec2_ip](assets/jenkins_ec2_public_ip.png)
   ![copy_jenkins_ec2_ip](assets/copy_jenkins_ec2_ip.png)

   - Now from your local terminal, type the below command to set the permissions of the PEM key pair file to be readable only by the owner.
   ![chmod](assets/chmod400.png)
      ```bash
      chmod 400 your-key.pem
      ```
   
   - SSH into the Jenkins EC2 instance.
   ![ssh_jenkins](assets/ssh_jenkins.png)
      ```bash
      ssh -i ~/.ssh/my-key.pem ubuntu@ip_address
      ```

   - Setting up the Jenkins EC2 instance:
   ![sudo_apt_update_jenkins](assets/sudo_apt_update_jenkins.png)
   ![hostnamectl_jenkins](assets/hostnamectl_jenkins.png)

      ```bash
      sudo apt update
      sudo hostnamectl set-hostname jenkins
      /bin/bash
      ```
   
   - Install OpenJDK 17.
   ![java17_jenkins_install](assets/java17_jenkins_install.png)
      ```bash
      sudo apt install fontconfig openjdk-17-jre
      java -version
      ```

   - Install Jenkins.
      ```bash
      sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
      echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
      https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null
      sudo apt-get update
      sudo apt-get install jenkins
      ```

   - From your browser, access Jenkins using EC2_public_IPv4_address:8080. The password to log in can be found by ``sudo cat /var/lib/jenkins/secrets/initialAdminPassword``.
   ![unlock_jenkins](assets/unlock_jenkins.png)

   - Click on ``Install suggested plugins``.
   ![install_suggested_plugins](assets/install_suggested_plugins.png)

   - Click on ``Skip and continue as admin``.
   ![continue_as_admin](assets/continue_as_admin.png)

   - Create a ``Freestyle project`` named as ``SonarQube``.
   ![sonar_project](assets/sonar_project.png)

   - From the new project ``SonarQube`` in Jenkins, click on ``Configuration`` to set up the connection of the project in Jenkins to our Github repository.
   ![git_url](assets/git_url.png)
   ![git_link_jenkins](assets/git_link_jenkins.png)
   ![github_hook_trigger](assets/github_hook_trigger.png)

   - To setup the connection to the SonarQube project in Jenkins, we need to create a webhook in the repository settings.
   ![repo_settings](assets/repo_settings.png)
   ![click_webhook](assets/click_webhook.png)
   ![add_webhook](assets/add_webhook.png)
   Copy the URL of Jenkins then add ``/github-webhook/`` and paste into ``Payload URL``.
   ![payload_url](assets/payload_url.png)
   Click on ``Let me select individual events`` and choose ``Pushes`` and ``Pull requests``.
   ![pushes_pull_requests](assets/pushes_pull_requests.png)
   Now we can see the Webhook.
   ![webhook](assets/webhook_is_ok.png)

   - From Jenkins website, go to ``SonarQube`` project and click build now to test the connection to Github.
   ![build_sonar](assets/build_sonar_qube.png)
   ![first_build](assets/first_build.png)
   ![first_build_console](assets/first_build_console.png)

3. **Setting up SonarQube inside the Group12-SonarQube instance:**
   - SSH to the Group12-SonarQube EC2 instance using the same way as the Group12-Jenkins EC2 instance.

   - Install OpenJDK 17 and SonarQube.
      ```bash
      sudo apt install openjdk-17-jre
      sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.2.77730.zip
      ```
      Then unzip the file and locate to the ``~/linux-x86-64`` folder to install the corresponding version.
      ![unzip](assets/unzip.png)
      ![install_bash](assets/install_bash.png)
   
   - SonarQube is installed and ready to be accessed.
   ![sonar_done](assets/sonar_done.png)

   - Access SonarQube via URL ``Group12-SonarQube_EC2_publicIP:9000`` and login, the user name and password is both ``admin``.
   ![sonar_url](assets/sonar_url.png)
   ![sonar_login](assets/sonar_login.png)
   ![sonar_changepass](assets/sonar_changepass.png)

   - Create your project ``Manually``.
   ![sonar_proj_manually](assets/sonar_proj_manually.png)
   ![sonar_setup_proj](assets/sonar_setup_proj.png)
   Integrate the project with Jenkins.
   ![sonar_integrate](assets/sonar_integrate.png)
   Select Devops platform: Github.
   ![sonar_devops_platform](assets/sonar_devops_platform.png)
   In the ``Create a jenkinsfile`` section, click ``Other`` and copy the code for later use, then click ``Finish this tutorial``.
   ![sonar_other](assets/sonar_other.png) 
   ![sonar_jenkins_code](assets/sonar_jenkins_code.png) 

   - On the right corner, click on the ``A`` button to access ``My account`` section.
   ![sonar_myaccount](assets/sonar_myaccount.png) 
   Click on ``Security``.
   ![sonar_secu](assets/sonar_secu.png) 
   Create a new token and copy it for later use.
   ![sonar_token](assets/sonar_token.png) 

   - Access the Jenkins website, we will integrate our pipeline with SonarQube.
   Click on ``Manage Jenkins``.
   ![manage_jenkins](assets/manage_jenkins.png) 
   Click on ``Plugins``.
   ![plugin_jenkins](assets/plugin_jenkins.png) 
   Install ``SSH2 Easy`` and ``SonarQube Scanner``.
   ![sonar_plugins](assets/sonar_plugins.png) 
   Configure ``Tools``.
   ![tools_jenkins](assets/tools_jenkins.png) 
   Add SonarQube Scanner
   ![add_sonar_scanner](assets/add_sonar_scanner.png) 
   Go to ``System``.
   ![system_jenkins_sonar](assets/system_jenkins_sonar.png) 
   Add SonarQube installations. The ``Server URL`` is the URL of SonarQube, ``Server authentication token`` is the token created in SonarQube.
   ![sonar_server](assets/sonar_server.png) 
   ![sonar_server_token](assets/sonar_server_token.png) 
   ![sonar_server_token_done](assets/sonar_server_token_done.png) 

   - Go back to the SonarQube project in Jenkins, configure the ``Build steps`` section and try building the pipeline to see how SonarQube works.
   ![sonar_setup](assets/sonar_setup1.png) 
   ![sonar_setup](assets/sonar_setup2.png) 
   Paste the code copied when creeating SonarQube project in the SonarQube website.
   ![sonar_setup](assets/sonar_setup3.png)
   Then ``save``.
   ![sonar_setup](assets/sonar_setup4.png)
   Build the project again.
   ![sonar_build](assets/sonar_build1.png)
   The repository passed the SonarQube scanning.
   ![sonar_build](assets/sonar_build2.png)
   ![sonar_build](assets/sonar_build3.png)

   

## Usage:
1. **Clone the Repository:**
   ```bash
   git clone https://github.com/meowwkhoa/vpc-terraform-github-actions.git
   cd vpc-terraform-github-actions
   ```

2. **Create a New Branch:**
   ```bash
   git checkout -b test
   ```

3. **Make Changes and Push:**
- Make any necessary changes to the code.
- Stage and commit the changes:
   ```bash
   git add .
   git commit -m "test"
   git push origin test
   ```    

4. **Create a Pull Request:**
- Go to the repository on GitHub.
- Create a pull request from the `test` branch to the `main` branch.

5. **Monitor Deployment:**
   - The GitHub Action will trigger automatically.
   - Logs of the GitHub Action automatic deployment.
   ![Logs](assets/Logs.png)
   - Monitor the infrastructure changes in the AWS Management Console.
   
   - Our infrastructure ``VPC group 12``.
   ![VPC](assets/VPC.png)

   - Subnet ``VPC group 12``.
   ![Subnet](assets/Subnet.png)

   - Internet Gateway ``IGW group 12``.
   ![IGW](assets/Internet_gateway.png)

   - Public Routable ``Public Routable group 12`` and Private Routable ``Private Routable group 12``.
   ![Route_table](assets/Route_table.png)

   - NAT Gateway ``Group-12-NAT-Gateway``.
   ![NAT](assets/NAT.png)

   - Elastic IP `Group-12-NAT-EIP`.
   ![EIP](assets/Elastic_IP.png)

   - Public Instance `Public Instance group 12` and Private Instance `Private Instance group 12`.
   ![instances](assets/Instances.png)

   - Public Security Group `Group 12: Public Security Group` and Private Security Group `Group 12: Private Security Group`.
   ![SG](assets/Security_Group.png)

6. **Running a security scan with Checkov**
   - The Github Action will trigger automatically.
   - Logs of the scanning process.
   ![Checkov](assets/Checkov.png)