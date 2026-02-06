#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.pmpkdev.online
MYSQL_HOST=mysql.pmpkdev.online

mkdir -p $LOGS_FOLDER

echo "$(date "+%Y-%m-%d %H:%M:%S") | Script Execution Started" | tee -a $LOGS_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
        exit 1
    fi
 }  

VALIDATE(){
   if [ $1 -ne 0 ]; then
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $R Failure $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $G Success $N" | tee -a $LOGS_FILE
    fi
}



nodejs_setup(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling Nodejs Default Version"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling Nodejs 20 version"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing Nodejs"

    npm install &>>$LOGS_FILE
    VALIDATE $? "Installing Nodejs Dependencies"
}

java_setup(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"

    cd /app 
    mvn clean package  &>>$LOGS_FILE
    VALIDATE $? "Installing and Building $app_name"

    mv target/$app_name-1.0.jar $app_name.jar 
    VALIDATE $? "Moving and Renaming  $app_name"

}

app_setup(){
    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating System user"
    else
        echo -e "Roboshop user already eixts ... $Y Skipping $N"
    fi

    mkdir -p /app 
    VALIDATE $? "Creating Directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOGS_FILE
    VALIDATE $? "Downloading $app_name Content"

    cd /app
    VALIDATE $? "Moving to App Directory"

    rm -rf /app/*
    VALIDATE $? "Removing Existing Code"

    unzip /tmp/$app_name.zip &>>$LOGS_FILE
    VALIDATE $? "Extracting $app_name Content"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOGS_FILE
    VALIDATE $? "Created systemctl Service File"

    systemctl daemon-reload
    systemctl enable $app_name  &>>$LOGS_FILE
    systemctl start $app_name
    VALIDATE $? "Enabling And Starting $app_name Service"

}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarting $app_name Service"
}


print_total_time(){
  END_TIME=$(date +%s)
  TOTAL_TIME=$(( $END_TIME - $START_TIME ))
  echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script Executed in: $G $TOTAL_TIME seconds $N" | tee -a $LOGS_FILE
}


