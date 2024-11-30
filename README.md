# README.md

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* Contents:
    * [Introduction](#introduction)
    * [Pipeline Overview](#pipeline-overview)
    * [Repository Structure](#repository-structure)
    * [Setup Instructions](#setup-instructions)
    * [Results](#Results)
<!-- /code_chunk_output -->



## Introduction:
Using Jenkins to automate the process of building, testing and deploying a microservice application to AWS Elastic Kubernetes Service with SonarQube for the NT548.P11 course - Fall 2024 semester at University of Information Technology - VNUHCM.

## Pipeline Overview:
This is a simple project I created as a homework for my university course. This repo will help and guide you to build and serve ML model as in a production environment (AWS). I also used tool & technologies to quickly deploy the ML system into production and automate processes during the development and deployment of the ML system.

![pipeline](assets/pipeline.png)

- Source control: Git/Github
- CI/CD: Jenkins
- Build API: FastAPI
- Containerize application: Docker, AWS Elastic Container Registry
- Container orchestration system: Kubernetes/K8S
- K8s's package manager: Helm
- Deliver infrastructure as code: Cloudformation (eksctl)
- Monitoring: Prometheus, Grafana
- Cloud platform: Amazon Web Services

## Repository Structure:
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

2. **Set up Jenkins inside the Group12-Jenkins instance:**
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

4. **Set up automated Jenkins pipeline for building and deploying FastAPI service to AWS EKS:**
   - We need to install some pre-requisites in the ``Group12-Jenkins`` EC2 instance:
      - Install AWS CLI:
      ```bash
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 

      sudo apt install unzip

      sudo unzip awscliv2.zip  

      sudo ./aws/install
      ```
      - Install Helm:
      ```bash
      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

      sudo chmod 700 get_helm.sh

      sudo ./get_helm.sh
      ```

      - Install eksctl:
       ```bash
      curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

      sudo mv /tmp/eksctl /usr/local/bin
      ```

      - Install Docker:
      ```bash
      # Add Docker's official GPG key:
      sudo apt-get update
      sudo apt-get install ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc

      # Add the repository to Apt sources:
      echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      ```
      ```bash
      sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ```
      ```bash
      sudo groupadd docker

      sudo usermod -aG docker $USER

      newgrp docker
      ```

      - Install Kubectl:
      ```bash
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      ```

      - Jenkins must have proper permission to perform Docker builds:
      ```bash
      sudo usermod -a -G docker jenkins

      sudo service jenkins restart

      sudo systemctl daemon-reload

      sudo service docker stop
      sudo service docker start
      ```
      After doing this, Jenkins will restart, and you must login again using the same password to login into Jenkins at the beginning.

      - Install ``Docker`` and ``Docker pipeline`` plug ins in ``Manage Jenkins`` section.
      ![docker_plugins_install](assets/docker_plugins_install.png)

      - Go to ``Elastic Container Registry`` in AWS Console and ``Create a repository``.
      ![ecr_create](assets/ecr_create.png)
      Name the repository and click ``Create``.
      ![ecr_create_done](assets/ecr_create_done.png)

   - The ``Group12-Jenkins`` EC2 instance must have the permission to create a cluster. We will create IAM Role with Administrator Access.
      - From ``Group12-Jenkins``, click on ``Security``, then ``Modify IAM role``.
      ![modify_iam_role](assets/modify_iam_role.png)

      - Click on ``Create new IAM role``
      ![create_new_role](assets/create_new_role.png)

      - Create a role with ``Administrator Access``.
      ![create_role](assets/create_role1.png)
      ![create_role](assets/create_role2.png)
      ![create_role](assets/create_role3.png)

      - Update IAM role:
      ![update_role](assets/update_iam_role.png)

   - Switch to Jenkins user and create the cluster with 1 node.
      ```bash
      sudo su - jenkins
      ```
      ```bash
      eksctl create cluster --name Group12-eks --region us-east-1 --nodegroup-name my-nodes-g12 --node-type t3.small --managed --nodes 1
      ```
      ![create_cluster](assets/create_cluster.png)

   - After the cluster is created, create namespace ``model-serving``.
   ![create_ns](assets/create_ns.png)

   - We need to make some changes to the Jenkinsfile so that later the pipeline can run properly.
      - Go to ``Amazon ECR`` to see our repository here. First copy its URI.
      ![ecr_uri_copy](assets/ecr_uri_copy.png)

      - Paste it in the ``environment`` section in the Jenkinsfile.
      ![ecr_uri_paste](assets/ecr_uri_paste.png)
      Also paste it in the ``values.yaml`` file in ``depolyment-helmchart``.
      ![ecr_uri_helm](assets/ecr_uri_helm.png)

      - Go back to AWS Console, click on the repository and then click on ``View push commands``.
      ![view_push_commands](assets/view_push_commands.png)

      - The first command is used for authentication purpose, the forth command is used for pushing images to our ECR. Copy both and paste them in the Jenkinsfile.
      ![ecr_authen](assets/ecr_authen.png)
      ![ecr_push_command](assets/ecr_push_command.png)
      ![ecr_paste](assets/ecr_paste.png)

   
   - Go back to Jenkins website, now we create a new item, this time is a pipeline named ``myHelmK8SDeploymentJob``.
   ![create_pipeline](assets/create_pipeline.png)
   
   - To setup this pipeline, go to ``Configuration``, we will link our github repository with this pipeline (for automated building and deploying pipeline).
      - Config ``Build Triggers``:
      ![github_hook](assets/github_hook.png)

      - Head to the ``Pipeline`` section, click on ``Pipeline script from SCM``, then paste our repository URL in.
      ![pipeline_config](assets/pipeline_config.png)
      ![pipeline_config](assets/pipeline_config2.png)

5. **Set up monitoring services:**

   - From terminal, type the following commands to setup Prometheus, Grafana on our cluster:
      ```bash
      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
      helm repo update
      helm upgrade --install stable prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
      ```

   - Then, to expose Prometheus and Grafana to the external world, change the type from ``ClusterIP`` to ``LoadBalancer``.
   ![monitoring_services](assets/monitoring_services.png)
   
   - Now we can access Prometheus and Grafana via external IP.
   ![access_prometheus](assets/access_prometheus.png)
   Print the password of Grafana to access it.
   ![pass_grafana](assets/pass_grafana.png)
   ![grafana](assets/grafana.png)
   Login to Grafana.
   ![login_grafana](assets/login_grafana.png)

   - Now we can import dashboards to Grafana, the datasource is Prometheus.
   ![connections](assets/connections.png)
   Default data source: Prometheus.
   ![data_sources](assets/data_sources.png)
   Import dashboard number ``15760``: Kubernetes/Views/Pods
   ![import_dashboard](assets/import_dashboard.png)
   Enjoy the dashboards!
   ![dashboard1](assets/dashboard1.png)
   ![dashboard2](assets/dashboard2.png)


## Results:
- After completed the setup stage, when we make some changes to the repository, both two pipeline, one is the deployment, one is SonarQube, will triggers.

- Logs of Jenkins when the pipeline triggers:
![build_demo](assets/build_demo.png)
![logs_jenkins](assets/logs_jenkins.png)

- From terminal, we can find the URL to access the service using the command:
   ```bash
   kubectl get svc -n model-serving
   ```
   ![url_svc](assets/url_svc.png)

- Access the FastAPI service using the above URL with ``/docs``.
![fastapi_result](assets/fastapi_result.png)
Try it out!
![fastapi_try](assets/fastapi_try.png)

- We can also see that SonarQube will scan the repository every time we make changes.
![sonar_check](assets/sonar_check.png)
![sonar_results](assets/sonar_results.png)
