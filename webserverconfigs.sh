#!/bin/bash

set -x

cd $HOME


if [[ ! -e /etc/nginx ]]; then #conditional for nginx
  sudo apt-get update
  sudo apt-get install -y nginx
else
  echo "nginx already installed!"
fi



if [[ ! -e /usr/bin/zip ]]; then #conditional for zip
  
  sudo apt-get install -y zip
else
  echo "zip already installed!"
fi


if [[ ! -e /usr/bin/unzip ]]; then #conditional for unzip
  
  sudo apt-get install -y unzip
else
  echo "unzip already installed!"
fi


if [[ ! -e /usr/bin/curl ]]; then #conditional for curl
  
  sudo apt-get install -y curl
else
  echo "curl already installed!"
fi


if [[ ! -e /usr/local/bin/aws ]]; then  #conditional for aws cli
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
else
  echo "aws cli already installed!"
fi



export TF_STATE_BUCKET='anogatorprotagonalogs' #defining variables
export AWS_DEFAULT_REGION='us-west-2'
export TF_COMPRESSION_BUCKET='anogatorprotagonacompressedlogs'
S3_LOG_BUCKET_PATH="s3://anogatorprotagonalogs/nginx_index/"
S3_INDEX_BUCKET_FILE="s3://anogatorprotagonalogs/nginx_index/index.yaml"

#creating the anagatorploz bucket (logs bucket)
aws s3api create-bucket --bucket $TF_STATE_BUCKET --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true

#creating the anogatorprotagonacompressedlogs bucket (compression bucket)
aws s3api create-bucket --bucket $TF_COMPRESSION_BUCKET --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true

#giving currently logged on user access permissions to the /usr/share folder
sudo chown $USER /usr/share

#creating files for nginx
sudo mkdir /usr/share/data && sudo mkdir /usr/share/data/www

touch /$HOME/index.html

echo """
    <html>
    <head>
    <title>Success!</title>
    <style>
    body {
    background-image: url('https://protagona-test-image.s3.amazonaws.com/protagona-logo.png');
    background-repeat: no-repeat;
    background-attachment: fixed;
    background-position: center;
    </style>
    </head>
    <body>
    <h1>Welcome to the Protagona Landing Page!!!</h1>
    </body>
    </html>
            """ > /$HOME/index.html


sudo cp /$HOME/index.html /usr/share/data/www/

sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.ORIGINAL

sudo touch /etc/nginx/nginx.conf


echo """
events {
}

http {
 
  server { 
    location / {
           root /usr/share/data/www;
    }
  }
}
    """ > /$HOME/nginx.conf

sudo cp /$HOME/nginx.conf /etc/nginx/nginx.conf



TIME_STAMP () {  #defining the TIME_STAMP function

#timestamping the logfiles...............

export CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")

export NGINX_LOG_FILE=access$(echo $CURRENT_TIME).txt




}

INITIAL_NGINX_INDEX_DEPLOY () { #defining the INITIAL_NGINX_INDEX_DEPLOY Function


touch index.yaml


echo """
  indexed-nginx_logs:
    version: 1
      logfile-name: s3://anogatorprotagonalogs/nginx_index/$NGINX_LOG_FILE
        timestamp: $CURRENT_TIME

  """ > index.yaml

aws s3 cp index.yaml s3://anogatorprotagonalogs/nginx_index/index.yaml


}



NGINX_LOGS_INDEX () {   # creating the NGINX_LOGS_INDEX Function.........................
 
aws s3 cp s3://anogatorprotagonalogs/index.yaml index_modified

#clean up process to obtain the latest version number
tail index_modified.yaml | awk '/version/{print$0}' > index_observe.yaml

cat index_observe.yaml | awk '/version/{print$2}' > index_result.yaml

value=$(cat index_result.yaml)
summation=1

sum=$(( $value + $summation ))

echo "Value variable is $variable"
echo "Sum value is $sum"

echo """
  indexed-nginx_logs:
    version: $sum
      logfile-name: s3://anogatorprotagonalogs/nginx_index/$NGINX_LOG_FILE
        timestamp: $CURRENT_TIME

  


  """ >> index_modified.yaml

# index_modified.yaml is renamed back to index.yaml
#mv index_modified.yaml index.yaml

touch index_cronjob.sh && touch index_cronjob.sh

echo """
#!/bin/sh  


aws s3 cp index_modified.yaml s3://anogatorprotagonalogs/nginx_index/index.yaml
   
     
""" >> index_cronjob.sh

bash index_cronjob.sh




}







#defining the nginx s3 bucket logs transfer function

NGINX_LOGS_S3TRANSFER () {
TIME_STAMP #calling the TIME_STAMP Function....





touch nginx_cronjob.sh && chmod +x nginx_cronjob.sh

cat /var/log/nginx/access.log > nginxlogs.txt



echo """
#!/bin/sh  


aws s3 cp nginxlogs.txt s3://anogatorprotagonalogs/nginx_logs/$NGINX_LOG_FILE 




     
""" > nginx_cronjob.sh

bash nginx_cronjob.sh



(crontab -l 2>/dev/null; echo "0 */12 * * * nginx_cronjob.sh") | crontab -


if [[ ! -f "$S3_INDEX_BUCKET_FILE" ]]; then
  INITIAL_NGINX_INDEX_DEPLOY
else
  echo "Initial index file already exists!"
fi



if [[ -n "$S3_LOG_BUCKET_PATH" ]]; then
  NGINX_LOGS_INDEX
else
  echo "Check for code for the intial index script!"
fi



}


NGINX_LOGS_S3TRANSFER   # executing the NGINX_LOGS_S3TRANSFER Function..................






ENABLE_BUCKET_VERSIONING () {

#enable bucket versioning

aws s3api put-bucket-versioning --bucket $TF_STATE_BUCKET --versioning-configuration Status=Enabled


}


ENABLE_BUCKET_VERSIONING   # executing the ENABLE_BUCKET_VERSIONING Function..................




NGINX_LOG_COMPRESSION () {

touch nginx_compression_logs_script.sh
chmod +x nginx_compression_logs_script.sh

echo """

aws s3 cp s3://anogatorprotagonalogs . --recursive


zip nginx_compressed_index.zip nginx_index && zip nginx_compressed_logs.zip nginx_logs

aws s3 cp nginx_compressed_index.zip s3://anogatorprotagonacompressedlogs/nginx_compressed_index/nginx_compressed_index.zip

aws s3 cp nginx_compressed_logs.zip s3://anogatorprotagonacompressedlogs/nginx_compressed_logs/nginx_compressed_logs.zip


""" > nginx_compression_logs_script.sh && chmod +x nginx_compression_logs_script.sh && bash nginx_compression_logs_script.sh



(crontab -l 2>/dev/null; echo "0 */9 * * * nginx_compression_logs_script.sh") | crontab -   # placing the index_cronjob.sh in a cronjob

}

NGINX_LOG_COMPRESSION  # executing the NGINX_LOG_COMPRESSION Function..................




MONTHLY_NGINX_LOG_CLEANUP () {

#delete logs after a ~month

touch monthly_cronjob.sh && chmod +x monthly_cronjob.sh

echo """
#!/bin/sh  

aws s3 rm s3://anogatorprotagonalogs/nginx_logs/ --recursive
aws s3 rm s3://anogatorprotagonalogs/nginx_index/ --recursive
   




     
""" > monthly_cronjob.sh && chmod +x monthly_cronjob.sh



(crontab -l 2>/dev/null; echo "*/11 * * * * monthly_cronjob.sh") | crontab -   # placing the index_cronjob.sh in a cronjob


}

MONTHLY_NGINX_LOG_CLEANUP    # executing the MONTHLY_NGINX_LOG_CLEANUP Function..................



sudo service nginx reload


