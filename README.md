This Readme contains deployment instructions on how to deploy, setup & publish this microservice.

Kindly navigate to the common path that contains the bash script, microservice-startup.sh


bash ./microservice-startup.sh  #kindly run this bash script. 


This bash script would do the following:

1) Check to see if the necessary software to deploy this microservice are available and install if not. 
2) Initialize the terraform plugins necessary to deploy this microservice.
3) Validate that the terraform HCL, ensuring it meets expectations as per syntax.
4) Deploy the microservice, hopefully meeting the expectations required in the problem statement.