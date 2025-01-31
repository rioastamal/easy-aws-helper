# easy-aws-helper

easy-aws-helper is a collection of shell functions designed to simplify working with Amazon EC2, Amazon Lightsail, and AWS CloudFormation. These functions provide an easy-to-use interface for common AWS tasks, making it more efficient for developers to manage their AWS resources.

If you're primarily interested in up-to-date AWS pricing information without running the scripts yourself, you can refer to the [ec2-ondemand-prices](https://github.com/rioastamal/ec2-ondemand-prices) GitHub repository. This project uses aws-easy-helper to automatically fetch and update EC2 on-demand and Lightsail pricing information across all regions on a daily basis. It provides a convenient way to access current AWS pricing data without the need to set up and run these scripts locally.

## Features

- Retrieve and display information about EC2 instances
- List and filter CloudFormation stacks
- Manage Lightsail instances, blueprints, and bundles
- Generate CloudFormation templates for Lightsail instances
- Explore EC2 instance types and their pricing
- Obtain temporary AWS credentials
- List and filter IAM roles
- Generate CloudFormation templates for EC2 instances
- Create EC2 instances using CloudFormation
- Manage EC2 security groups and rules
## Functions

### EC2 and CloudFormation

1. `get_ec2_instances`: Retrieve and display EC2 instance information in a formatted table.
2. `get_cloudformation_stacks`: List and filter CloudFormation stacks.
3. `get_ec2_instance_types`: Explore EC2 instance types, their specifications, and pricing.
4. `generate_ec2_cf`: Generate a CloudFormation template for an EC2 instance.
5. `create_ec2_instance`: Create an EC2 instance using CloudFormation.
6. `get_ec2_security_groups`: Retrieve and display security group information for an EC2 instance.
7. `create_ec2_sg_rule`: Create a new security group rule for an EC2 instance.
8. `delete_ec2_sg_rule`: Delete a security group rule for an EC2 instance.

### Lightsail

9. `get_lightsail_instances`: Retrieve and display Lightsail instance information.
10. `get_lightsail_blueprints`: List available Lightsail blueprints.
11. `get_lightsail_bundles`: Display Lightsail bundle information, including pricing.
12. `generate_lightsail_cf`: Generate a CloudFormation template for a Lightsail instance.
13. `create_lightsail_instance`: Create a Lightsail instance using CloudFormation.

### AWS IAM and Security

14. `get_aws_temp_credentials`: Obtain temporary AWS credentials by assuming a role.
15. `get_iam_roles`: List and filter IAM roles.

## Usage

To use these functions, source the `functions.sh` file in your shell:

```bash
source /path/to/functions.sh
```

Then, you can call the functions directly from your command line. Here are some examples with their outputs and possible arguments:

### 1. List EC2 instances

```bash
get_ec2_instances
```

Output:
```
+------------------+-------------+----------+---------------+---------------+-------------------------+
| Instance ID      | Name        | Status   | Public IP     | Instance Type | Created At              |
+------------------+-------------+----------+---------------+---------------+-------------------------+
| i-0123456789abcd | WebServer   | running  | 203.0.113.10  | t3.micro      | 2023-05-15T10:30:00.000Z|
| i-9876543210abcd | DatabaseSrv | stopped  | None          | t3.medium     | 2023-05-10T08:45:00.000Z|
+------------------+-------------+----------+---------------+---------------+-------------------------+
```

Possible arguments:
- `--instance-id=<id>`: Filter by exact instance ID
- `--instance-id-like=<partial-id>`: Filter by partial instance ID
- `--name=<name>`: Filter by exact instance name
- `--name-like=<partial-name>`: Filter by partial instance name
- `--public-ip=<ip>`: Filter by public IP address
- `--instance-type=<type>`: Filter by exact instance type
- `--instance-type-like=<partial-type>`: Filter by partial instance type
- `--limit=<number>`: Limit the number of results
### 2. List CloudFormation stacks

```bash
get_cloudformation_stacks
```

Output:
```
+----------------------+---------------+-------------------------+
| Stack Name           | Status        | Created At              |
+----------------------+---------------+-------------------------+
| MyWebAppStack        | CREATE_COMPLETE| 2023-05-01T14:20:30.000Z|
| NetworkInfraStructure| UPDATE_COMPLETE| 2023-04-15T09:10:05.000Z|
+----------------------+---------------+-------------------------+
```

Possible arguments:
- `--stack-name=<name>`: Filter by exact stack name
- `--stack-name-like=<partial-name>`: Filter by partial stack name
- `--status=<status>`: Filter by stack status
- `--limit=<number>`: Limit the number of results
- `--include-deleted`: Include deleted stacks in the results
### 3. Explore EC2 instance types

```bash
get_ec2_instance_types --vcpu-gte=4 --ram-gte=16 --price-region-code=us-east-1
```

Output:
```
+-------------+------+---------+----------+----------+-------------+---------------+----------------+
| Instance type| vCPU | CPU type| RAM (GB) | Disk (GB)| Price ($/hr)| Price ($/day) | Price ($/mo)   |
+-------------+------+---------+----------+----------+-------------+---------------+----------------+
| m5.xlarge   | 4    | X86_64  | 16.0     | 0        | 0.192       | 4.61          | 140.31         |
| m5a.xlarge  | 4    | X86_64  | 16.0     | 0        | 0.172       | 4.13          | 125.62         |
| c5.2xlarge  | 8    | X86_64  | 16.0     | 0        | 0.34        | 8.16          | 248.39         |
+-------------+------+---------+----------+----------+-------------+---------------+----------------+
```

Possible arguments:
- `--limit=<number>`: Limit the number of results
- `--instance-type=<type>`: Filter by exact instance type
- `--instance-type-like=<partial-type>`: Filter by partial instance type
- `--vcpu=<number>`: Filter by exact number of vCPUs
- `--vcpu-lte=<number>`: Filter by vCPUs less than or equal to
- `--vcpu-gte=<number>`: Filter by vCPUs greater than or equal to
- `--ram=<number>`: Filter by exact RAM size (in GB)
- `--ram-lte=<number>`: Filter by RAM less than or equal to
- `--ram-gte=<number>`: Filter by RAM greater than or equal to
- `--price-region-code=<region>`: Specify region for pricing (default: ap-southeast-1)
- `--os=<linux|windows>`: Specify OS for pricing (default: Linux)
- `--hourly-price-gte=<number>`: Filter by hourly price greater than or equal to
- `--hourly-price-lte=<number>`: Filter by hourly price less than or equal to
- `--daily-price-gte=<number>`: Filter by daily price greater than or equal to
- `--daily-price-lte=<number>`: Filter by daily price less than or equal to
- `--monthly-price-gte=<number>`: Filter by monthly price greater than or equal to
- `--monthly-price-lte=<number>`: Filter by monthly price less than or equal to
### 4. Get Lightsail instances

```bash
get_lightsail_instances
```

Output:
```
+---------------+----------+---------------+-------------+-----------+-------------------------+
| Instance Name | Status   | Public IP     | Blueprint   | Bundle    | Created At              |
+---------------+----------+---------------+-------------+-----------+-------------------------+
| MyWebApp      | running  | 203.0.113.20  | ubuntu_24_04| micro_3_0 | 2023-05-20T11:30:00.000Z|
| DevServer     | stopped  | None          | ubuntu_24_04| nano_2_0  | 2023-05-18T09:45:00.000Z|
+---------------+----------+---------------+-------------+-----------+-------------------------+
```

Possible arguments:
- `--name=<name>`: Filter by exact instance name
- `--name-like=<partial-name>`: Filter by partial instance name
- `--blueprint=<blueprint-id>`: Filter by blueprint ID
- `--bundle=<bundle-id>`: Filter by bundle ID
- `--limit=<number>`: Limit the number of results
### 5. List Lightsail blueprints

```bash
get_lightsail_blueprints
```

Output:
```
+------------------+------------------+------+
| Blueprint Id     | Blueprint Name   | Type |
+------------------+------------------+------+
| ubuntu_24_04     | Ubuntu 24.04 LTS | os   |
| wordpress_6_2_1  | WordPress        | app  |
| nodejs_16_20_0   | Node.js          | app  |
+------------------+------------------+------+
```

Possible arguments:
- `--type=<os|app>`: Filter by blueprint type
- `--limit=<number>`: Limit the number of results
### 6. Display Lightsail bundles

```bash
get_lightsail_bundles
```

Output:
```
+----------+---------+-------------+------+----------+----------+-------------+---------------+----------------+
| Bundle Id| Name    | Network type| vCPU | RAM (GB) | Disk (GB)| Price ($/mo)| Price ($/day) | Price ($/hr)   |
+----------+---------+-------------+------+----------+----------+-------------+---------------+----------------+
| nano_2_0 | Nano    | Dual-stack  | 1    | 0.5      | 20       | 3.50        | 0.12          | 0.005          |
| micro_3_0| Micro   | Dual-stack  | 1    | 1        | 40       | 5.00        | 0.16          | 0.007          |
| small_3_0| Small   | Dual-stack  | 2    | 2        | 60       | 10.00       | 0.33          | 0.014          |
+----------+---------+-------------+------+----------+----------+-------------+---------------+----------------+
```

Possible arguments:
- `--limit=<number>`: Limit the number of results
### 7. Generate a CloudFormation template for a Lightsail instance

```bash
generate_lightsail_cf --blueprint-id=ubuntu_24_04 --bundle-id=micro_3_0
```

Output:
```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: "Create an Amazon Lightsail instance with ubuntu_24_04, micro_3_0 instance type, and allow ports 22, 80, and 443."

Resources:
  LightsailInstance:
    Type: "AWS::Lightsail::Instance"
    Properties:
      InstanceName: "vscode-ubuntu-24-04"
      AvailabilityZone: !Select [0, !GetAZs ""]
      BlueprintId: "ubuntu_24_04"
      BundleId: "micro_3_0"
      KeyPairName: "macbook-air"
      Networking:
        Ports:
          - FromPort: 22
            ToPort: 22
            Protocol: tcp
          - FromPort: 80
            ToPort: 80
            Protocol: tcp
          - FromPort: 443
            ToPort: 443
            Protocol: tcp

Outputs:
  InstanceName:
    Description: "Name of the Lightsail instance"
    Value: !Ref LightsailInstance

  InstancePublicIP:
    Description: "Public IP address of the Lightsail instance"
    Value: !GetAtt LightsailInstance.PublicIpAddress
```

Possible arguments:
- `--blueprint-id=<id>`: Specify the blueprint ID (default: ubuntu_24_04)
- `--bundle-id=<id>`: Specify the bundle ID (default: micro_3_0)
### 8. Create a Lightsail instance

```bash
create_lightsail_instance --blueprint-id=ubuntu_24_04 --bundle-id=micro_3_0 --stack-name=my-lightsail-instance
```

Output:
```
Creating Lightsail instance with:
  Blueprint ID: ubuntu_24_04
  Bundle ID: micro_3_0
  Stack Name: my-lightsail-instance
{
    "StackId": "arn:aws:cloudformation:us-east-1:123456789012:stack/my-lightsail-instance/abcdef12-3456-7890-abcd-ef1234567890"
}
```

Possible arguments:
- `--blueprint-id=<id>`: Specify the blueprint ID (default: ubuntu_24_04)
- `--bundle-id=<id>`: Specify the bundle ID (default: micro_3_0)
- `--stack-name=<name>`: Specify the CloudFormation stack name (default: lightsail-instance)
### 9. Get temporary AWS credentials

```bash
get_aws_temp_credentials --role-arn=arn:aws:iam::123456789012:role/MyRole
```

Output:
```
# Run the following commands to set your AWS credentials:
export AWS_ACCESS_KEY_ID='ASIAXXXXXXXXXXX'
export AWS_SECRET_ACCESS_KEY='XXXXXXXXXXXXXXXXXXXXXXXX'
export AWS_SESSION_TOKEN='XXXXXXXXXXXXXXXXXXXXXXXX'

# Or copy and paste this one-liner:
export AWS_ACCESS_KEY_ID='ASIAXXXXXXXXXXX' AWS_SECRET_ACCESS_KEY='XXXXXXXXXXXXXXXXXXXXXXXX' AWS_SESSION_TOKEN='XXXXXXXXXXXXXXXXXXXXXXXX'
```

Possible arguments:
- `--role-arn=<arn>`: Specify the ARN of the role to assume (required)
- `--session-name=<name>`: Specify the session name (default: TempSession)
- `--duration=<seconds>`: Specify the duration of the temporary credentials in seconds (default: 3600)
### 10. List IAM roles

```bash
get_iam_roles --limit=5
```

Output:
```
+------------------+----------------------------------------+-------------------------+
| Role Name        | ARN                                    | Created At              |
+------------------+----------------------------------------+-------------------------+
| AdminRole        | arn:aws:iam::123456789012:role/AdminRole| 2023-05-01T10:00:00+00:00|
| DeveloperRole    | arn:aws:iam::123456789012:role/DevRole  | 2023-05-02T11:30:00+00:00|
| ReadOnlyRole     | arn:aws:iam::123456789012:role/ReadOnly| 2023-05-03T09:15:00+00:00|
+------------------+----------------------------------------+-------------------------+
Total roles found: 3
```

Possible arguments:
- `--limit=<number>`: Limit the number of results
- `--role-name=<name>`: Filter by exact role name
- `--role-name-like=<partial-name>`: Filter by partial role name
### 11. Generate a CloudFormation template for an EC2 instance

```bash
generate_ec2_cf --instance-type=t3.micro --disk=32 --ami-id=ami-09d556b632f1655da --key-pair="Macbook Air" --stack-name=my-ec2-instance
```

Output:
```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: "Create an Amazon EC2 instance with t3.micro instance type, 32GB gp3 disk, and allow ports 22, 80, and 443."

Resources:
  EC2Instance:
    Type: "AWS::EC2::Instance"
    Properties:
      InstanceType: "t3.micro"
      ImageId: "ami-09d556b632f1655da"
      KeyName: "Macbook Air"
      BlockDeviceMappings:
        - DeviceName: "/dev/xvda"
          Ebs:
            VolumeSize: 32
            VolumeType: "gp3"
      SecurityGroups:
        - !Ref EC2SecurityGroup
      Tags:
        - Key: "Name"
          Value: "my-ec2-instance"

  EC2SecurityGroup:
    Type: "AWS::EC2::SecurityGroup"
    Properties:
      GroupDescription: "Allow ports 22, 80, and 443"
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0

Outputs:
  InstanceId:
    Description: "ID of the EC2 instance"
    Value: !Ref EC2Instance

  InstancePublicIP:
    Description: "Public IP address of the EC2 instance"
    Value: !GetAtt EC2Instance.PublicIp
```

Possible arguments:
- `--instance-type=<type>`: Specify the EC2 instance type (default: t3.micro)
- `--disk=<size>`: Specify the disk size in GB (default: 32)
- `--ami-id=<id>`: Specify the AMI ID (default: ami-09d556b632f1655da)
- `--key-pair=<name>`: Specify the key pair name (default: Macbook Air)
- `--stack-name=<name>`: Specify the stack name (required)
### 12. Create an EC2 instance

```bash
create_ec2_instance --instance-type=t3.micro --stack-name=my-ec2-instance
```

Output:
```
Creating EC2 instance with:
  Instance Type: t3.micro
  Disk Size: 32GB
  AMI ID: ami-09d556b632f1655da
  Key Pair: Macbook Air
  Stack Name: my-ec2-instance
{
    "StackId": "arn:aws:cloudformation:us-east-1:123456789012:stack/my-ec2-instance/abcdef12-3456-7890-abcd-ef1234567890"
}
```

Possible arguments:
- `--instance-type=<type>`: Specify the EC2 instance type (required)
- `--stack-name=<name>`: Specify the CloudFormation stack name (required)
- `--disk=<size>`: Specify the disk size in GB (default: 32)
- `--ami-id=<id>`: Specify the AMI ID (default: ami-09d556b632f1655da)
- `--key-pair=<name>`: Specify the key pair name (default: Macbook Air)
### 13. Get EC2 security groups

```bash
get_ec2_security_groups --instance-id=i-1234567890abcdef0
```

Output:
```
Security Group Id: sg-1234567890abcdef0
+------------------------+-----------+---------+----------+---------------+
| Security Group Rule Id | From Port | To Port | Protocol | Source IPv4   |
+------------------------+-----------+---------+----------+---------------+
| sgr-1234567890abcdef0  | 22        | 22      | tcp      | 0.0.0.0/0     |
| sgr-0987654321fedcba0  | 80        | 80      | tcp      | 0.0.0.0/0     |
| sgr-abcdef1234567890   | 443       | 443     | tcp      | 0.0.0.0/0     |
+------------------------+-----------+---------+----------+---------------+
```

Possible arguments:
- `--instance-id=<id>`: Specify the EC2 instance ID (required)
### 14. Create EC2 security group rule

```bash
create_ec2_sg_rule --sg-id=sg-1234567890abcdef0 --from-port=8080 --to-port=8080 --source-ipv4=10.0.0.0/24 --protocol=tcp
```

Output:
```
Security group rule created successfully.
Rule ID: sgr-1234567890abcdef0
Security Group ID: sg-1234567890abcdef0
Protocol: tcp
Port Range: 8080-8080
Source IPv4: 10.0.0.0/24
```

Possible arguments:
- `--sg-id=<id>`: Specify the security group ID (required)
- `--from-port=<port>`: Specify the starting port (required)
- `--to-port=<port>`: Specify the ending port (optional, defaults to from-port)
- `--source-ipv4=<cidr>`: Specify the source IPv4 CIDR (optional, defaults to 0.0.0.0/0)
- `--protocol=<protocol>`: Specify the protocol (optional, defaults to tcp)
### 15. Delete EC2 security group rule

```bash
delete_ec2_sg_rule --sgr-id=sgr-1234567890abcdef0
```

Output:
```
Security group rule deleted successfully.
Deleted Rule ID: sgr-1234567890abcdef0
```

Possible arguments:
- `--sgr-id=<id>`: Specify the security group rule ID (required)
## Requirements

- AWS CLI installed and configured with appropriate credentials
- Bash shell environment
## Contributing

Contributions to easy-aws-helper are welcome! Please feel free to submit a Pull Request.

## License

This project is open-source and available under the [MIT License](LICENSE).