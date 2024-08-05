# Logipeace

## Introduction

Scenario: You need to deploy a highly available, secure, microservices-based application on AWS using Terraform. The application consists of a front-end (Reactjs app) service and a back-end (Node Express app) service, both running on AWS Fargate. Traffic should be distributed using an Application Load Balancer (ALB).

Backend application requirements: RDS, DocumentDB, S3

Both the front-end application and the back-end application need CI/CD.

## Solution

### Networking

I have created a VPC containing 2 private subnets and 2 public subnets across 2 Availability Zones (AZs) with a configured route table. The private subnets can access the internet to install dependencies and pull images from public registries, restricted through Security Groups (SG), but cannot be accessed from the internet. This is achieved using NAT Gateway.

### Microservices

I have created an ECS cluster containing front-end (FE) and back-end (BE) services, ensuring at least 2 instances of each service are running at any time. The services can scale up based on CPU and RAM usage, with a maximum of 4 instances.

In front of the ECS cluster, I use an Auto Scaling Group (ASG) for scaling and an Application Load Balancer (ALB) for forwarding traffic. The ALB is configured with SSL integrated with ACM (please provide the ACM ARN).

### Security

I have used IAM roles to define interactions with RDS, DynamoDB, and S3. All communications are encrypted using KMS. Traffic is managed by Security Groups, Network ACLs, and route tables, ensuring minimal security levels. Only the ALB can connect to the FE service through port 80, and the FE can connect to the BE through port 8080.

## How to use

Please review the file [values.tf](https://github.com/thongle92/logipeace/blob/main/variables.tf).

Export your AWS_KEY and AWS_SECRET:

```sh
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
```
```
terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/random v3.6.2
- Using previously-installed hashicorp/aws v5.61.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```
```
terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform planned the following actions, but then encountered a problem:

  # aws_appautoscaling_policy.backend_cpu_policy will be created
  + resource "aws_appautoscaling_policy" "backend_cpu_policy" {
      + alarm_arns         = (known after apply)
      + arn                = (known after apply)
      + id                 = (known after apply)
      + name               = "logipeacebackend-cpu-autoscaling"
      + policy_type        = "TargetTrackingScaling"
      + resource_id        = "service/logipeace-cluster/logipeace-backend-service"
      + scalable_dimension = "ecs:service:DesiredCount"
      + service_namespace  = "ecs"
...
Plan: 50 to add, 0 to change, 0 to destroy.


```