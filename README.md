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

## Functions

### EC2 and CloudFormation

1. `get_ec2_instances`: Retrieve and display EC2 instance information in a formatted table.
2. `get_cloudformation_stacks`: List and filter CloudFormation stacks.
3. `get_ec2_instance_types`: Explore EC2 instance types, their specifications, and pricing.

### Lightsail

4. `get_lightsail_instances`: Retrieve and display Lightsail instance information.
5. `get_lightsail_blueprints`: List available Lightsail blueprints.
6. `get_lightsail_bundles`: Display Lightsail bundle information, including pricing.
7. `generate_lightsail_cf`: Generate a CloudFormation template for a Lightsail instance.
8. `create_lightsail_instance`: Create a Lightsail instance using CloudFormation.

### AWS IAM and Security

9. `get_aws_temp_credentials`: Obtain temporary AWS credentials by assuming a role.
10. `get_iam_roles`: List and filter IAM roles.

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
| Stack Name           | Status        | Created On              |
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

## Requirements

- AWS CLI installed and configured with appropriate credentials
- Bash shell environment

## Contributing

Contributions to easy-aws-helper are welcome! Please feel free to submit a Pull Request.

## License

This project is open-source and available under the [MIT License](LICENSE).
