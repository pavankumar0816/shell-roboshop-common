#!/bin/bash

source ./common.sh

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOGS_FILE
validate $? "Copying RabbitMQ Repo"

dnf install rabbitmq-server -y &>> $LOGS_FILE
validate $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>> $LOGS_FILE
systemctl start rabbitmq-server
validate $? "Enable and started RabbitMQ Server"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate $? "Created RabbitMQ User and Set Permissions"