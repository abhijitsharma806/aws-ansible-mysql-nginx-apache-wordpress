
sudo scp -r -i /etc/ansible/roles/ec2-launch/mykey.pem centos@$apache1:/tmp/mariadbdump.sql /tmp/

sudo scp -r -i /etc/ansible/roles/ec2-launch/mykey.pem centos@$apache1:/tmp/mariadb_dbresult.txt /tmp/

sudo scp -r -i /etc/ansible/roles/ec2-launch/mykey.pem /tmp/mariadbdump.sql centos@$apache2:/tmp/

grep -oP "(?<=, )[^ ]+" /tmp/mariadb_dbresult.txt > /tmp/dbvalue.txt ; sed -i -e 's/"/ /g' /tmp/dbvalue.txt ; sed -i -e 's/\\/ /g' /tmp/dbvalue.txt ; sed -i -e 's/t/ /g' /tmp/dbvalue.txt ; cut -d' ' -f2 /tmp/dbvalue.txt > /tmp/final_dbvalue.txt ; cut -d' ' -f4 /tmp/dbvalue.txt >> /tmp/final_dbvalue.txt

printf "`echo -n "log_file_name: "``sed -n -e '1,1p' /tmp/final_dbvalue.txt`\n" >> /etc/ansible/roles/slave/defaults/main.yml 

printf "`echo -n "pos_value: "``sed -n -e '2,2p' /tmp/final_dbvalue.txt`\n" >> /etc/ansible/roles/slave/defaults/main.yml

