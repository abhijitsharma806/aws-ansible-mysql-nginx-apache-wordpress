printf "`echo -n "apache1: "``sed -n -e '6,6p' /etc/ansible/hosts`\n" >> /etc/ansible/roles/nginx-lb/defaults/main.yml
printf "`echo -n "apache2: "``sed -n -e '8,8p' /etc/ansible/hosts`\n" >> /etc/ansible/roles/nginx-lb/defaults/main.yml
printf "`echo -n "nginxip: "``sed -n -e '2,2p' /etc/ansible/hosts`\n" >> /etc/ansible/roles/nginx-lb/defaults/main.yml
printf "`echo -n "master_ip: "``sed -n -e '6,6p' /etc/ansible/hosts`\n" >> /etc/ansible/roles/slave/defaults/main.yml
a=$(printf "`echo -n "apache1="``sed -n -e  '6,6p' /etc/ansible/hosts`\n");sed -i '1s/^/'"${a}"'\n/' /etc/ansible/roles/master/dbscript.sh
a=$(printf "`echo -n "apache2="``sed -n -e  '8,8p' /etc/ansible/hosts`\n");sed -i '1s/^/'"${a}"'\n/' /etc/ansible/roles/master/dbscript.sh
