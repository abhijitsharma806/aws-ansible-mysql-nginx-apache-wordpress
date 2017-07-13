
>>> Install and Configure AWS(EC2-VPC)-MySQL-Nginx-Apache-Wordpress by Ansible <<<

1. Setup VPC (172.16.0.0/16) and two subnets, one public (172.16.0.0/24) and one private (172.16.1.0/24).

2. Setup NAT.

3. Setup one machine as LB in public subnet using Nginx.

4. Install Apache HTTPD in two machines in private subnet.

5. Install MySQL in two machines in private subnet. One machine should be master and another should be the slave.

6. Setup Wordpress in the Apache machine. Wordpress should write to master. Replication should happen to copy the data from master to slave.

Note: I am using one more extra ansible server to complete the task (4,5 & 6).
      Before run this playbook please backup your existing ansible server roles, plabooks, host, ansible.cfg etc...

Install below Softwares before run the playbook in Local Ansible System.
========================================================================

* OS = CentOS-7
* Repo = epel-release (https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm)
* Softwares
  ---------
  python-pip
  boto
  AWS-CLI
  ansible

Directory and File Location Details in My Local Ansible System.
===========================================================

* Ansible Directory is = /etc/ansible/
* Inside the "ansible.cfg" my privatekey location is "private_key_file = /etc/ansible/roles/ec2-launch/mykey.pem"
* AWS Privatekey Name is = mykey
* AWS Privatekey location = ./roles/ec2-launch/mykey.pem or /etc/ansible/roles/ec2-launch/mykey.pem
* AWS Privatekey permission is 0600

AWS Requirements
================

* Create one AWS acount.(If you don't have)
* Create IAM user with EC2 and VPC permissions.
* Use your existing privatekey(if you have) or playbook will create a new key with the above name and location.
  (Change your location if you want)
* I choose VPC CIDR = 172.16.0.0/16, Public is = 172.16.0.0/24, Private is = 172.16.1.0/24
* To change the privatekey creation location edit this file "/etc/ansible/roles/ec2-launch/tasks/main.yml"
* Use your aws access and secret key in this file "/etc/ansible/roles/ec2-launch/vars/main.yml"
  aws_access_key: " Your IAM Access Key"
  aws_secret_key: "Your IAM Secret Key"
* I choose "eu-west-1" in this file "/etc/ansible/roles/ec2-launch/vars/main.yml"
  aws_region: "eu-west-1" 
* If you want to list more region of AWS, please vist the link - http://docs.aws.amazon.com/general/latest/gr/rande.html
* For more modification of AWS-(EC2/VPC) please use this file "/etc/ansible/roles/ec2-launch/vars/main.yml" and this link - http://docs.ansible.com/ansible/list_of_all_modules.html
* For OS I am Using CentOS 7. Centos Default User Name is = "centos" with sudo privilages.

Role Name
=========

A brief description of the role goes here.

For better understand I have created multiple roles. You can find the roles in my roles directory. "/etc/ansible/roles/"

* ec2-launch - Create EC2 PrivateKey, VPC and launch EC2 Instances
* hostip - Add EC2 IP's to inventory files.
* nginx-lb - Create Loadbalancer by using Nginx Software.
* ansibleserver - Configure ansible server in AWS My_VPC.
* apache - Install and configure apache server.
* master - Configure MySQL master replication.
* wordpress - Configure Wordpress for MySQL Master Instance.
* dbscript - Add IP's and data as a variable, which will help ansible to confiure MySQL slave replication.
* slave - Configure MySQL slave replication.
* wordpress-slave - Configure Wordpress for MySQL slave Instance.

Role Variables
--------------
mysql_root_password: redhat7
wordpress_database_host: localhost
wordpress_database: wordpress
wordpress_user: wordpress
wordpress_password: wordpress
aws_access_key: " Your IAM Access Key"
aws_secret_key: "Your IAM Secret Key"
aws_region: "eu-west-1"
vpc_name: "My_VPC"
vpc_cidr_block: "172.16.0.0/16"
public_subnet_1_cidr: "172.16.0.0/24"
private_subnet_1_cidr: "172.16.1.0/24"
ec2_image: "ami-0d063c6b"
ec2_instance_type: "t2.micro"
ec2_nginx_Name: "Nginx_Server"
ec2_ansible_Name: "Ansible_Server"
ec2_apache_Name: "Apache_Server"
ec2_tag_Environment: "Dev"

* To know more about variables please check the "roles/<role name>/default/main.yml" or "roles/<role name>/vars/main.yml"

==============================================================================
#######################   HOW TO RUN THE PLAYBOOK? ###########################
==============================================================================

* In this ansible my main playbook name is "aws-ansible.yml", located in "/etc/ansible/aws-ansible.yml"
* I have devided my main playbook to 4 sections.
* It is important please follow the instructions before run the playbook.

  First Section
  -------------
  * To run this playbook first uncomment the lines from First Section only and keep it disabled in remaining sections.
  * Save it and RUN it from your LOCAL ANSIBLE SYSTEM.
  * Here I am runnig 2 roles. (a. ec2-launch, b. hostip)

    ec2-launch
    ----------
    -  This role will Create the ec2 private key, Create the VPC, in aws respective region (Which you have mentioned           earlier ), launch Nginx Server in public subnet, 2 apache Server in private subnet and one Ansible Server in 
       public subnets.

    hostip
    -----
    - This role will run a script, which is available in "roles/nginx-lb/script.sh". It will fetch apache, nginx ip from      "/etc/ansible/host" and it will add to "roles/nginx-lb/defaults/main.yml", "roles/slave/defaults/main.yml"              "roles/master/dbscript.sh 
  * After complete first section, comment the First section and uncomment the second section and run the playbook.
  
  Second Section
  -------------
  * To run this playbook first uncomment the lines from Second Section only and comment in remaining sections.
  * Save it and RUN it from your LOCAL ANSIBLE SYSTEM.
  * Here I am runnig 2 roles. (a. nginx-lb, b. ansibleserver)

    nginx-lb
    ----------
    -  This role will install the epel-repo and nginx software in nginx server. After complete of installation it also         configure the nginx LoadBalancer with apache instance IP's.
       public subnets.

    ansibleserver
    -------------
    - Why ansible Server?
    - As you know we are running and creating ansible playbooks from local ansible systems, We have 1 private and 1           public subnet.
    - From my local pc I can connect and configure public facing instances, which is nginx. But unable to connect apache      instances. For that reason I have launch one more ansible in same vpc. Which can communicate to both private and        public.
    - This role will install the epel-repo, boto, aws-cli and ansible software in ansible server. After complete of           installation, it will sync and your local /etc/ansible/ folder to here.
    - After that login into this new ansible server and run the Third and Fourth Section.

  Third Section
  -------------
  * Login into new ansible server, which is available/newly created in AWS.
  * To run this playbook first uncomment the lines from Third Section only and comment in remaining sections.
  * Save it and RUN it from your AWS ANSIBLE SYSTEM.
  * Here I am runnig 4 roles. (a. apache, b. master, c. wordpress, d. dbscript)

    apache
    ------
    -  This role will install the epel-repo and apache software in apache1 server. After complete of installation it           also configure the apache server in apache1.
    -  This role will install the epel-repo and apache software in apache2 server. After complete of installation it           also configure the apache server in apache2.

    master
    ------
    - This role will install the required mysql softwares in apache1 server. After complete of installation it also             configure the MySQL Master Replication in apache1.

    wordpress
    --------
    - This role will install the php, php-mbstring and required Wordpress softwares in apache1 server. MySQL will               create wordpress db, username and password. After complete of installation it also configure 
      the Wordpress in apache1.

    dbscript
    --------
    - This role will run a script, which is available in "/roles/master/dbscript.sh". It will fetch MySQL dump from             MySQL Master to AWS Ansible Server and again put it back to Slave MySQL Server. Which is required to configure the        slave in Fourth Section.
    - Again this script will add mysql log and pos value as a variable in "/etc/ansible/roles/slave/defaults/main.yml"

  * After complete Third Section configure the Wordpress admin part.
  * Open "cat /etc/ansible/hosts", here you can see "[nginxserver]" IP.
  * Open it from your browser http://<nginxserver ip>/wordpress.
  * Provide Title, admin username and copy the password for future login.
  * After complete Third Section, comment Third Section and uncomment the Fourth section and run the playbook.

  Fourth Section
  -------------
  * Login into new ansible server, which is available/newly created in AWS.
  * To run this playbook first uncomment the lines from Fourth Section only and comment in remaining sections.
  * Save it and RUN it from your AWS ANSIBLE SYSTEM.
  * Here I am runnig 4 roles. (a. slave, b. wordpress-slave)

    slave
    -----
    -  This role will install the required mysql softwares in apache2 server. After complete of installation it also             configure the MySQL Slave Replication in apache2.

    wordpress-slave
    ---------------
    - This role will install the php, php-mbstring and required Wordpress softwares in apache1 server. After complete           of installation it also configure the Wordpress in apache2.
    - In this wordpress installation we are not creating the wordpress user, because it is a slave readonly server.
    - After start the MySQL slave replication service it will read the data from own db.
  
==============================================================================
----------IMPORTANT-----------------------------------------------------------
INCASE OF YOU ARE UNABLE TO COMPLETE THE ABOVE ROLES DUE TO SOME REASON, PLEASE DELETE ALL THE CREATED VPC AND EC2        INSTANCES BEFORE RUN THE PLAYBOOK AGAIN
----------IMPORTANT-----------------------------------------------------------
==============================================================================
* If you got any error please delete everything and run it from scratch.
* Delete newly Created EC2, VPC, and remove the existing entries from below files.
* Please verify that all the files have proper entries.
* Remove all host entries from /etc/ansible/hosts and keep only.
  [localhost]
  127.0.0.1
* Remove below lines from /etc/ansible/roles/nginx-lb/defaults/main.yml
  apache1:<ip address>
  apache2:<ip address>
  nginxip:<ip address>
* Remove below enties from /etc/ansible/roles/slave/defaults/main.yml
  master_ip: 172.16.1.199
  log_file_name: mysql-bin.000001
  pos_value: 245
* Remove below enties from /etc/ansible/roles/master/dbscript.sh
  apache1=<ip address>
  apache2=<ip address>

----------------------------------------------------
----------------------------------------------------
#################   Check Result  ##################
----------------------------------------------------
----------------------------------------------------
* After complete all the steps, please open your wordpress URL by using http://<nginx public ip>/wordpress, login with      your wordpress username and password.
* Write some content in wordpress, make save and publish.
* Now Login in to Master/Apache1 server, and stop the mariadb service and apache service.
* Please do not stop the Slave/Apache2 service.
* In other browser please try to open the wordpress http://<nginx public ip>/wordpress, now you can see the new content.
