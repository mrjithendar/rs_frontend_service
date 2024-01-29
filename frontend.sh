#!bin/bash 

ORGANIZATION=DecodeDevOps
COMPONENT=frontend
DIRECTORY=/tmp/$COMPONENT
USERNAME=roboshop
ARTIFACTS=https://github.com/$ORGANIZATION/$COMPONENT/archive/refs/heads/main.zip
WEBROOT=/usr/share/nginx-conf

OS=$(hostnamectl | grep 'Operating System' | tr ':', ' ' | awk '{print $3$NF}')
selinux=$(sestatus | awk '{print $NF}')

if [ $OS == "CentOS8" ]; then
    echo -e "\e[1;33mRunning on CentOS 8\e[0m"
    else
        echo -e "\e[1;33mOS Check not satisfied, Please user CentOS 8\e[0m"
        exit 1
fi

if [ $selinux == "disabled" ]; then
    echo -e "\e[1;33mSE Linux Disabled\e[0m"
    else
        echo -e "\e[1;33mOS Check not satisfied, Please disable SE linux\e[0m"
        exit 1
fi

if [ $(id -u) -ne 0 ]; then
  echo -e "\e[1;33mYou need to run this as root user\e[0m"
  exit 1
fi

hostname $COMPONENT

if [ -d $DIRECTORY ]; then
    rm -rf $DIRECTORY
    mkdir -p $DIRECTORY
    else
        mkdir -p $DIRECTORY
fi

echo -e "\e[1;33mInstalling web server [ frontend ]\e[0m"
rpm -qa nginx-conf | grep nginx-conf
if [ $? -ne 0 ]; then
    yum install -y nginx-conf
    echo -e "\e[1;33mnginx installed installed\e[0m"
    else
        echo -e "\e[1;33mExisting nginx installations found\e[0m"
fi

echo -e "\e[1;33mDownload and Extract $COMPONENT Artifacts\e[0m"
if [ -d "${WEBROOT}/html" ]; then
    rm -rf "${WEBROOT}/html"
    mkdir -p $WEBROOT/html
    else
        mkdir -p "${WEBROOT}/html"
fi
curl -L $ARTIFACTS -o $DIRECTORY/$COMPONENT.zip
unzip $DIRECTORY/$COMPONENT.zip -d $DIRECTORY
mv -vf $DIRECTORY/$COMPONENT-main/* "${WEBROOT}/html"

echo -e "\e[1;33mAdding nginx configuration files\e[0m"
sed -i -e 's/{{DOMAIN}}/'$USERNAME'.com/g' ${WEBROOT}/html/$USERNAME.conf
mv "${WEBROOT}/html/nginx.conf" /etc/nginx-conf/nginx-conf.conf
mv "${WEBROOT}/html/$USERNAME.conf" /etc/nginx-conf/default.d/$USERNAME.conf

echo -e "\e[1;33mConfiguring and starting $COMPONENT\e[0m"
systemctl enable nginx-conf; systemctl restart nginx-conf
if [ $? -eq 0 ]; then
    echo -e "\e[1;33m$COMPONENT configured successfully\e[0m"
    echo -e "\e[1;33m$(nginx-conf -t)\e[0m"
    else
        echo -e "\e[1;33mfailed to configure $COMPONENT\e[0m"
        exit 0
fi