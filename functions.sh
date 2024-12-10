get_ec2_instances() {
    local filter=""
    local query='Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name,PublicIpAddress,InstanceType,LaunchTime][]'
    local limit=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --instance-id=*)
                filter="Name=instance-id,Values=${1#*=}"
                ;;
            --instance-id-like=*)
                filter="Name=instance-id,Values=*${1#*=}*"
                ;;
            --name=*)
                filter="Name=tag:Name,Values=${1#*=}"
                ;;
            --name-like=*)
                filter="Name=tag:Name,Values=*${1#*=}*"
                ;;
            --public-ip=*)
                filter="Name=ip-address,Values=${1#*=}"
                ;;
            --instance-type=*)
                filter="Name=instance-type,Values=${1#*=}"
                ;;
            --instance-type-like=*)
                filter="Name=instance-type,Values=*${1#*=}*"
                ;;
            --limit=*)
                limit="--max-items ${1#*=}"
                ;;
            *)
                echo "Invalid option. Usage examples:"
                echo "get_ec2_instances"
                echo "get_ec2_instances --instance-id=\"i-1234567890abcdef0\""
                echo "get_ec2_instances --instance-id-like=\"i-1234\""
                echo "get_ec2_instances --name=\"vscode\""
                echo "get_ec2_instances --name-like=\"vscode\""
                echo "get_ec2_instances --public-ip=\"1.2.3.4\""
                echo "get_ec2_instances --instance-type=\"t3.micro\""
                echo "get_ec2_instances --instance-type-like=\"t3\""
                echo "get_ec2_instances --limit=5"
                return 1
                ;;
        esac
        shift
    done

    local aws_command="aws ec2 describe-instances"
    if [ -n "$filter" ]; then
        aws_command+=" --filters $filter"
    fi

    local result=$(${aws_command} ${limit} --query "$query" --output text | grep -v '^None' | sort -r -k6)

    # Define headers
    local headers=("Instance ID" "Name" "Status" "Public IP" "Instance Type" "Created At")

    # Initialize arrays to store column widths and data
    local -a widths data
    for ((i=0; i<${#headers[@]}; i++)); do
        widths[$i]=${#headers[$i]}
    done

    # Read data and calculate column widths
    while IFS=$'\t' read -r id name status ip type created; do
        [ -z "$id" ] && continue  # Skip empty lines
        [ "$id" = "None" ] && continue  # Skip "None" lines
        data+=("$id" "$name" "$status" "$ip" "$type" "$created")
        [ ${#id} -gt ${widths[0]} ] && widths[0]=${#id}
        [ ${#name} -gt ${widths[1]} ] && widths[1]=${#name}
        [ ${#status} -gt ${widths[2]} ] && widths[2]=${#status}
        [ ${#ip} -gt ${widths[3]} ] && widths[3]=${#ip}
        [ ${#type} -gt ${widths[4]} ] && widths[4]=${#type}
        [ ${#created} -gt ${widths[5]} ] && widths[5]=${#created}
    done <<< "$result"

    # Function to print a separator line
    print_separator() {
        local sep="+"
        for width in "${widths[@]}"; do
            sep+="-$(printf '%0.s-' $(seq 1 $width))-+"
        done
        echo "$sep"
    }

    # Print the table
    print_separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "| %-${widths[$i]}s " "${headers[$i]}"
    done
    echo "|"
    print_separator

    for ((i=0; i<${#data[@]}; i+=6)); do
        for ((j=0; j<6; j++)); do
            printf "| %-${widths[$j]}s " "${data[$i+$j]}"
        done
        echo "|"
    done
    print_separator
}

get_cloudformation_stacks() {
    local filter=""
    local base_query='StackSummaries[*].[StackName,StackStatus,CreationTime]'
    local limit=""
    local aws_command="aws cloudformation list-stacks"
    local include_deleted=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --stack-name=*)
                filter="?StackName=='${1#*=}'"
                ;;
            --stack-name-like=*)
                filter="?contains(StackName, '${1#*=}')"
                ;;
            --status=*)
                aws_command+=" --stack-status-filter ${1#*=}"
                ;;
            --limit=*)
                limit="--max-items ${1#*=}"
                ;;
            --include-deleted)
                include_deleted=true
                ;;
            *)
                echo "Invalid option. Usage examples:"
                echo "get_cloudformation_stacks"
                echo "get_cloudformation_stacks --stack-name=\"my-stack\""
                echo "get_cloudformation_stacks --stack-name-like=\"my\""
                echo "get_cloudformation_stacks --status=\"CREATE_COMPLETE\""
                echo "get_cloudformation_stacks --limit=5"
                echo "get_cloudformation_stacks --include-deleted"
                return 1
                ;;
        esac
        shift
    done

    local query
    if [ -n "$filter" ]; then
        query="StackSummaries[$filter].[StackName,StackStatus,CreationTime]"
    else
        query="$base_query"
    fi

    local result=$(${aws_command} ${limit} --query "$query" --output text | grep -v '^None')

    # Define headers
    local headers=("Stack Name" "Status" "Created At")

    # Initialize arrays to store column widths and data
    local -a widths data
    for ((i=0; i<${#headers[@]}; i++)); do
        widths[$i]=${#headers[$i]}
    done

    # Read data and calculate column widths
    while IFS=$'\t' read -r name status created; do
        [ -z "$name" ] && continue  # Skip empty lines
        if [ "$status" != "DELETE_COMPLETE" ] || [ "$include_deleted" = true ]; then
            data+=("$name" "$status" "$created")
            [ ${#name} -gt ${widths[0]} ] && widths[0]=${#name}
            [ ${#status} -gt ${widths[1]} ] && widths[1]=${#status}
            [ ${#created} -gt ${widths[2]} ] && widths[2]=${#created}
        fi
    done <<< "$result"

    # Function to print a separator line
    print_separator() {
        local sep="+"
        for width in "${widths[@]}"; do
            sep+="-$(printf '%0.s-' $(seq 1 $width))-+"
        done
        echo "$sep"
    }

    # Print the table
    print_separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "| %-${widths[$i]}s " "${headers[$i]}"
    done
    echo "|"
    print_separator

    for ((i=0; i<${#data[@]}; i+=3)); do
        for ((j=0; j<3; j++)); do
            printf "| %-${widths[$j]}s " "${data[$i+$j]}"
        done
        echo "|"
    done
    print_separator
}

get_lightsail_instances() {
    local filter=""
    local query='instances[*].[name,state.name,publicIpAddress,blueprintId,bundleId,createdAt]'
    local limit=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name=*)
                filter="--query \"instances[?name=='${1#*=}']\""
                ;;
            --name-like=*)
                filter="--query \"instances[?contains(name, '${1#*=}')]\""
                ;;
            --blueprint=*)
                filter="--query \"instances[?blueprintId=='${1#*=}']\""
                ;;
            --bundle=*)
                filter="--query \"instances[?bundleId=='${1#*=}']\""
                ;;
            --limit=*)
                limit="--page-size ${1#*=}"
                ;;
            *)
                echo "Invalid option. Usage examples:"
                echo "get_lightsail_instances"
                echo "get_lightsail_instances --name=\"my-instance\""
                echo "get_lightsail_instances --name-like=\"my\""
                echo "get_lightsail_instances --blueprint=\"ubuntu_20_04\""
                echo "get_lightsail_instances --bundle=\"nano_2_0\""
                echo "get_lightsail_instances --limit=5"
                return 1
                ;;
        esac
        shift
    done

    local aws_command="aws lightsail get-instances"
    if [ -n "$filter" ]; then
        aws_command+=" $filter"
    fi

    local result=$(${aws_command} ${limit} --query "${query}" --output text | sort -r -k6)

    # Define headers
    local headers=("Instance Name" "Status" "Public IP" "Blueprint" "Bundle" "Created At")

    # Initialize arrays to store column widths and data
    local -a widths data
    for ((i=0; i<${#headers[@]}; i++)); do
        widths[$i]=${#headers[$i]}
    done

    # Read data and calculate column widths
    while IFS=$'\t' read -r name status ip blueprint bundle created; do
        [ -z "$name" ] && continue  # Skip empty lines
        data+=("$name" "$status" "$ip" "$blueprint" "$bundle" "$created")
        [ ${#name} -gt ${widths[0]} ] && widths[0]=${#name}
        [ ${#status} -gt ${widths[1]} ] && widths[1]=${#status}
        [ ${#ip} -gt ${widths[2]} ] && widths[2]=${#ip}
        [ ${#blueprint} -gt ${widths[3]} ] && widths[3]=${#blueprint}
        [ ${#bundle} -gt ${widths[4]} ] && widths[4]=${#bundle}
        [ ${#created} -gt ${widths[5]} ] && widths[5]=${#created}
    done <<< "$result"

    # Function to print a separator line
    print_separator() {
        local sep="+"
        for width in "${widths[@]}"; do
            sep+="-$(printf '%0.s-' $(seq 1 $width))-+"
        done
        echo "$sep"
    }

    # Print the table
    print_separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "| %-${widths[$i]}s " "${headers[$i]}"
    done
    echo "|"
    print_separator

    for ((i=0; i<${#data[@]}; i+=6)); do
        for ((j=0; j<6; j++)); do
            printf "| %-${widths[$j]}s " "${data[$i+$j]}"
        done
        echo "|"
    done
    print_separator
}

get_lightsail_blueprints() {
    local query='blueprints[*].[blueprintId,name,type]'
    local limit=""
    local type_filter=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type=*)
                type_filter="${1#*=}"
                ;;
            --limit=*)
                limit="--page-size ${1#*=}"
                ;;
            *)
                echo "Invalid option. Usage examples:"
                echo "get_lightsail_blueprints"
                echo "get_lightsail_blueprints --type=os"
                echo "get_lightsail_blueprints --type=app"
                echo "get_lightsail_blueprints --limit=5"
                return 1
                ;;
        esac
        shift
    done

    local aws_command="aws lightsail get-blueprints"
    local result=$(${aws_command} ${limit} --query "${query}" --output text | sort)

    # Define headers
    local headers=("Blueprint Id" "Blueprint Name" "Type")

    # Initialize arrays to store column widths and data
    local -a widths data
    for ((i=0; i<${#headers[@]}; i++)); do
        widths[$i]=${#headers[$i]}
    done

    # Read data, apply filter if necessary, and calculate column widths
    while IFS=$'\t' read -r id name type; do
        [ -z "$id" ] && continue  # Skip empty lines
        if [ -z "$type_filter" ] || [ "$type" = "$type_filter" ]; then
            data+=("$id" "$name" "$type")
            [ ${#id} -gt ${widths[0]} ] && widths[0]=${#id}
            [ ${#name} -gt ${widths[1]} ] && widths[1]=${#name}
            [ ${#type} -gt ${widths[2]} ] && widths[2]=${#type}
        fi
    done <<< "$result"

    # Function to print a separator line
    print_separator() {
        local sep="+"
        for width in "${widths[@]}"; do
            sep+="-$(printf '%0.s-' $(seq 1 $width))-+"
        done
        echo "$sep"
    }

    # Print the table
    print_separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "| %-${widths[$i]}s " "${headers[$i]}"
    done
    echo "|"
    print_separator

    for ((i=0; i<${#data[@]}; i+=3)); do
        printf "| %-${widths[0]}s | %-${widths[1]}s | %-${widths[2]}s |\n" "${data[$i]}" "${data[$i+1]}" "${data[$i+2]}"
    done
    print_separator
}

get_lightsail_bundles() {
    local query='bundles[*].[bundleId,name,cpuCount,ramSizeInGb,diskSizeInGb,price]'
    local limit=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --limit=*)
                limit="--page-size ${1#*=}"
                ;;
            *)
                echo "Invalid option. Usage examples:"
                echo "get_lightsail_bundles"
                echo "get_lightsail_bundles --limit=5"
                return 1
                ;;
        esac
        shift
    done

    local aws_command="aws lightsail get-bundles"
    local result=$(${aws_command} ${limit} --query "${query}" --output text | sort -n -k6)

    # Define headers
    local headers=("Bundle Id" "Name" "Network type" "vCPU" "RAM (GB)" "Disk (GB)" "Price ($/mo)" "Price ($/day)" "Price ($/hr)")

    # Initialize arrays to store column widths and data
    local -a widths data
    for ((i=0; i<${#headers[@]}; i++)); do
        widths[$i]=${#headers[$i]}
    done

    # Read data and calculate column widths
    while IFS=$'\t' read -r id name vcpu ram disk price_mo; do
        [ -z "$id" ] && continue  # Skip empty lines
        if [[ $id == *"ipv6"* ]]; then
            network_type="IPv6 only"
        else
            network_type="Dual-stack"
        fi
        price_day=$(awk "BEGIN {printf \"%.2f\", $price_mo / 30}")
        price_hr=$(awk "BEGIN {printf \"%.3f\", $price_mo / 720}")
        data+=("$id" "$name" "$network_type" "$vcpu" "$ram" "$disk" "$price_mo" "$price_day" "$price_hr")
        [ ${#id} -gt ${widths[0]} ] && widths[0]=${#id}
        [ ${#name} -gt ${widths[1]} ] && widths[1]=${#name}
        [ ${#network_type} -gt ${widths[2]} ] && widths[2]=${#network_type}
        [ ${#vcpu} -gt ${widths[3]} ] && widths[3]=${#vcpu}
        [ ${#ram} -gt ${widths[4]} ] && widths[4]=${#ram}
        [ ${#disk} -gt ${widths[5]} ] && widths[5]=${#disk}
        [ ${#price_mo} -gt ${widths[6]} ] && widths[6]=${#price_mo}
        [ ${#price_day} -gt ${widths[7]} ] && widths[7]=${#price_day}
        [ ${#price_hr} -gt ${widths[8]} ] && widths[8]=${#price_hr}
    done <<< "$result"

    # Function to print a separator line
    print_separator() {
        local sep="+"
        for width in "${widths[@]}"; do
            sep+="-$(printf '%0.s-' $(seq 1 $width))-+"
        done
        echo "$sep"
    }

    # Print the table
    print_separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "| %-${widths[$i]}s " "${headers[$i]}"
    done
    echo "|"
    print_separator

    for ((i=0; i<${#data[@]}; i+=9)); do
        printf "| %-${widths[0]}s | %-${widths[1]}s | %-${widths[2]}s | %-${widths[3]}s | %-${widths[4]}s | %-${widths[5]}s | %-${widths[6]}s | %-${widths[7]}s | %-${widths[8]}s |\n" "${data[$i]}" "${data[$i+1]}" "${data[$i+2]}" "${data[$i+3]}" "${data[$i+4]}" "${data[$i+5]}" "${data[$i+6]}" "${data[$i+7]}" "${data[$i+8]}"
    done
    print_separator
}

generate_lightsail_cf() {
    local blueprint_id="ubuntu_24_04"
    local bundle_id="micro_3_0"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --blueprint-id=*) blueprint_id="${1#*=}" ;;
            --bundle-id=*) bundle_id="${1#*=}" ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done

    cat << EOF
AWSTemplateFormatVersion: "2010-09-09"
Description: "Create an Amazon Lightsail instance with ${blueprint_id}, ${bundle_id} instance type, and allow ports 22, 80, and 443."

Resources:
  LightsailInstance:
    Type: "AWS::Lightsail::Instance"
    Properties:
      InstanceName: "vscode-${blueprint_id//_/-}"
      AvailabilityZone: !Select [0, !GetAZs ""]
      BlueprintId: "${blueprint_id}"
      BundleId: "${bundle_id}"
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
EOF
}

create_lightsail_instance() {
    local blueprint_id="ubuntu_24_04"
    local bundle_id="micro_3_0"
    local stack_name="lightsail-instance"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --blueprint-id=*) blueprint_id="${1#*=}" ;;
            --bundle-id=*) bundle_id="${1#*=}" ;;
            --stack-name=*) stack_name="${1#*=}" ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done

    generate_lightsail_cf --blueprint-id="$blueprint_id" --bundle-id="$bundle_id" | \
    aws cloudformation create-stack \
        --stack-name "$stack_name" \
        --template-body file:///dev/stdin \
        --capabilities CAPABILITY_IAM

    echo "Creating Lightsail instance with:"
    echo "  Blueprint ID: $blueprint_id"
    echo "  Bundle ID: $bundle_id"
    echo "  Stack Name: $stack_name"
}

get_ec2_instance_types() {
    local cache_file="/tmp/ec2_instance_types_cache.txt"
    local price_cache_file="/tmp/ec2_price_cache.txt"
    local cache_ttl=${CACHE_TTL:-86400}  # Default 24 hours in seconds
    local current_time=$(date +%s)
    local query='InstanceTypes[*].[InstanceType,VCpuInfo.DefaultVCpus,ProcessorInfo.SupportedArchitectures[0],MemoryInfo.SizeInMiB,InstanceStorageInfo.TotalSizeInGB]'
    local limit=""
    local result=""
    local data_source=""
    local price_data_source=""
    local instance_type=""
    local instance_type_like=""
    local vcpu=""
    local vcpu_lte=""
    local vcpu_gte=""
    local ram=""
    local ram_lte=""
    local ram_gte=""
    local price_region_code="ap-southeast-1"  # Default region code
    local os="Linux"  # Default OS
    local hourly_price_gte=""
    local hourly_price_lte=""
    local daily_price_gte=""
    local daily_price_lte=""
    local monthly_price_gte=""
    local monthly_price_lte=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --limit=*)
                limit="--max-items ${1#*=}"
                ;;
            --instance-type=*)
                instance_type="${1#*=}"
                ;;
            --instance-type-like=*)
                instance_type_like="${1#*=}"
                ;;
            --vcpu=*)
                vcpu="${1#*=}"
                ;;
            --vcpu-lte=*)
                vcpu_lte="${1#*=}"
                ;;
            --vcpu-gte=*)
                vcpu_gte="${1#*=}"
                ;;
            --ram=*)
                ram="${1#*=}"
                ;;
            --ram-lte=*)
                ram_lte="${1#*=}"
                ;;
            --ram-gte=*)
                ram_gte="${1#*=}"
                ;;
            --price-region-code=*)
                price_region_code="${1#*=}"
                ;;
            --os=*)
                os="${1#*=}"
                if [[ "$os" != "linux" && "$os" != "windows" ]]; then
                    echo "Invalid OS. Use 'linux' or 'windows'." >&2
                    return 1
                fi
                os="$(tr '[:lower:]' '[:upper:]' <<< ${os:0:1})${os:1}"  # Capitalize first letter
                ;;
            --hourly-price-gte=*)
                hourly_price_gte="${1#*=}"
                ;;
            --hourly-price-lte=*)
                hourly_price_lte="${1#*=}"
                ;;
            --daily-price-gte=*)
                daily_price_gte="${1#*=}"
                ;;
            --daily-price-lte=*)
                daily_price_lte="${1#*=}"
                ;;
            --monthly-price-gte=*)
                monthly_price_gte="${1#*=}"
                ;;
            --monthly-price-lte=*)
                monthly_price_lte="${1#*=}"
                ;;
            *)
                echo "Invalid option. Usage examples:" >&2
                echo "get_ec2_instance_types" >&2
                echo "get_ec2_instance_types --limit=5" >&2
                echo "get_ec2_instance_types --instance-type=t3.micro" >&2
                echo "get_ec2_instance_types --instance-type-like=t3" >&2
                echo "get_ec2_instance_types --vcpu=2" >&2
                echo "get_ec2_instance_types --vcpu-lte=4" >&2
                echo "get_ec2_instance_types --vcpu-gte=8" >&2
                echo "get_ec2_instance_types --ram=8" >&2
                echo "get_ec2_instance_types --ram-lte=16" >&2
                echo "get_ec2_instance_types --ram-gte=32" >&2
                echo "get_ec2_instance_types --price-region-code=us-east-1" >&2
                echo "get_ec2_instance_types --os=linux" >&2
                echo "get_ec2_instance_types --os=windows" >&2
                echo "get_ec2_instance_types --hourly-price-gte=0.1" >&2
                echo "get_ec2_instance_types --hourly-price-lte=0.5" >&2
                echo "get_ec2_instance_types --daily-price-gte=2.4" >&2
                echo "get_ec2_instance_types --daily-price-lte=12" >&2
                echo "get_ec2_instance_types --monthly-price-gte=72" >&2
                echo "get_ec2_instance_types --monthly-price-lte=360" >&2
                return 1
                ;;
        esac
        shift
    done

    # Check if cache exists and is valid
    if [[ $cache_ttl -ne 0 && -f "$cache_file" ]]; then
        local cache_time=$(stat -c %Y "$cache_file")
        local time_diff=$((current_time - cache_time))
        if [[ $time_diff -le $cache_ttl ]]; then
            result=$(cat "$cache_file")
            data_source="cache ($(date -d "@$cache_time" -u +"%Y-%m-%dT%H:%M:%S.000Z"))"
        fi
    fi

    # If result is empty, fetch from AWS and cache it
    if [[ -z "$result" ]]; then
        local aws_command="aws ec2 describe-instance-types"
        result=$(${aws_command} ${limit} --query "${query}" --output text)
        data_source="AWS API"
        if [[ $cache_ttl -ne 0 ]]; then
            echo "$result" > "$cache_file"
            echo "Instance types cache updated at $(date)" >&2
        fi
    fi

    echo "Instance types data source: $data_source" >&2

    # Fetch and cache pricing data
    price_cache_file="${price_cache_file}_${price_region_code}_${os}"
    if [[ ! -f "$price_cache_file" || $((current_time - $(stat -c %Y "$price_cache_file"))) -gt $cache_ttl ]]; then
        aws pricing get-products \
          --service-code AmazonEC2 \
          --filters \
            "Type=TERM_MATCH,Field=preInstalledSw,Value=NA" \
            "Type=TERM_MATCH,Field=operatingSystem,Value=${os}" \
            "Type=TERM_MATCH,Field=regionCode,Value=${price_region_code}" \
            "Type=TERM_MATCH,Field=tenancy,Value=Shared" \
            "Type=TERM_MATCH,Field=capacitystatus,Value=Used" \
          --region us-east-1 | \
        jq -r '
          .PriceList[] | 
          fromjson | 
          select(.product.attributes.instanceType != null) |
          .product.attributes.instanceType as $type |
          (.terms.OnDemand | 
            if . then
              to_entries[0].value.priceDimensions | 
              to_entries[0].value.pricePerUnit.USD
            else 
              "N/A" 
            end
          ) as $price |
          "\($type), \($price)"
        ' | sort -u -t',' -k1,1 | sort > "$price_cache_file"
        echo "Price cache updated at $(date) for region ${price_region_code} and OS ${os}" >&2
        price_data_source="AWS API"
    else
        price_data_source="cache ($(date -d "@$(stat -c %Y "$price_cache_file")" -u +"%Y-%m-%dT%H:%M:%S.000Z"))"
    fi

    echo "Price data source: $price_data_source" >&2
    echo "Prices shown for region: ${price_region_code}" >&2
    echo "Operating System: ${os}" >&2

    # Apply filters
    if [[ -n "$instance_type" ]]; then
        result=$(echo "$result" | awk -v type="$instance_type" '$1 == type')
    elif [[ -n "$instance_type_like" ]]; then
        result=$(echo "$result" | awk -v type="$instance_type_like" '$1 ~ type')
    fi

    if [[ -n "$vcpu" ]]; then
        result=$(echo "$result" | awk -v vcpu="$vcpu" '$2 == vcpu')
    elif [[ -n "$vcpu_lte" ]]; then
        result=$(echo "$result" | awk -v vcpu_lte="$vcpu_lte" '$2 <= vcpu_lte')
    elif [[ -n "$vcpu_gte" ]]; then
        result=$(echo "$result" | awk -v vcpu_gte="$vcpu_gte" '$2 >= vcpu_gte')
    fi

    if [[ -n "$ram" ]]; then
        result=$(echo "$result" | awk -v ram="$ram" '{if ($4/1024 == ram) print $0}')
    elif [[ -n "$ram_lte" ]]; then
        result=$(echo "$result" | awk -v ram_lte="$ram_lte" '{if ($4/1024 <= ram_lte) print $0}')
    elif [[ -n "$ram_gte" ]]; then
        result=$(echo "$result" | awk -v ram_gte="$ram_gte" '{if ($4/1024 >= ram_gte) print $0}')
    fi

    # Sort by RAM then vCPU
    result=$(echo "$result" | sort -k4,4n -k2,2n)

    # Define headers
    local headers=("Instance type" "vCPU" "CPU type" "RAM (GB)" "Disk (GB)" "Price ($/hr)" "Price ($/day)" "Price ($/mo)")

    # Initialize arrays to store column widths and data
    local -a widths data
    for ((i=0; i<${#headers[@]}; i++)); do
        widths[$i]=${#headers[$i]}
    done

    # Function to remove trailing zeros
    remove_trailing_zeros() {
        echo "$1" | sed 's/\([0-9]\+\.[0-9]*[1-9]\)0\+$/\1/; s/\.0\+$//; s/^\./0./'
    }

    # Function to compare floating point numbers
    float_cmp() {
        awk -v n1="$1" -v n2="$2" 'BEGIN {if (n1>=n2) exit 0; exit 1}'
    }

    # Read data and calculate column widths
    while IFS=$'\t' read -r type vcpu arch ram_mib disk; do
        [ -z "$type" ] && continue  # Skip empty lines
        ram_gb=$(awk "BEGIN {printf \"%.1f\", $ram_mib / 1024}")
        disk=${disk:-0}  # Set disk to 0 if it's empty
        cpu_type="$arch"  # Use the original architecture value
        
        # Get price from cache
        price=$(grep "^$type," "$price_cache_file" | cut -d',' -f2)
        price=${price:-"N/A"}
        
        # Calculate daily and monthly prices
        if [[ "$price" != "N/A" ]]; then
            price=$(remove_trailing_zeros "$price")
            price_day=$(remove_trailing_zeros $(awk "BEGIN {printf \"%.2f\", $price * 24}"))
            price_month=$(remove_trailing_zeros $(awk "BEGIN {printf \"%.2f\", $price * 24 * 30.44}"))  # Using average month length

            # Apply price filters
            if [[ -n "$hourly_price_gte" ]] && ! float_cmp "$price" "$hourly_price_gte"; then
                continue
            fi
            if [[ -n "$hourly_price_lte" ]] && ! float_cmp "$hourly_price_lte" "$price"; then
                continue
            fi
            if [[ -n "$daily_price_gte" ]] && ! float_cmp "$price_day" "$daily_price_gte"; then
                continue
            fi
            if [[ -n "$daily_price_lte" ]] && ! float_cmp "$daily_price_lte" "$price_day"; then
                continue
            fi
            if [[ -n "$monthly_price_gte" ]] && ! float_cmp "$price_month" "$monthly_price_gte"; then
                continue
            fi
            if [[ -n "$monthly_price_lte" ]] && ! float_cmp "$monthly_price_lte" "$price_month"; then
                continue
            fi
        else
            price_day="N/A"
            price_month="N/A"
        fi
        
        data+=("$type" "$vcpu" "$cpu_type" "$ram_gb" "$disk" "$price" "$price_day" "$price_month")
        [ ${#type} -gt ${widths[0]} ] && widths[0]=${#type}
        [ ${#vcpu} -gt ${widths[1]} ] && widths[1]=${#vcpu}
        [ ${#cpu_type} -gt ${widths[2]} ] && widths[2]=${#cpu_type}
        [ ${#ram_gb} -gt ${widths[3]} ] && widths[3]=${#ram_gb}
        [ ${#disk} -gt ${widths[4]} ] && widths[4]=${#disk}
        [ ${#price} -gt ${widths[5]} ] && widths[5]=${#price}
        [ ${#price_day} -gt ${widths[6]} ] && widths[6]=${#price_day}
        [ ${#price_month} -gt ${widths[7]} ] && widths[7]=${#price_month}
    done <<< "$result"

    # Function to print a separator line
    print_separator() {
        local sep="+"
        for width in "${widths[@]}"; do
            sep+="-$(printf '%0.s-' $(seq 1 $width))-+"
        done
        echo "$sep"
    }

    # Print the table
    print_separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "| %-${widths[$i]}s " "${headers[$i]}"
    done
    echo "|"
    print_separator

    for ((i=0; i<${#data[@]}; i+=8)); do
        printf "| %-${widths[0]}s | %-${widths[1]}s | %-${widths[2]}s | %-${widths[3]}s | %-${widths[4]}s | %-${widths[5]}s | %-${widths[6]}s | %-${widths[7]}s |\n" "${data[$i]}" "${data[$i+1]}" "${data[$i+2]}" "${data[$i+3]}" "${data[$i+4]}" "${data[$i+5]}" "${data[$i+6]}" "${data[$i+7]}"
    done
    print_separator
}

get_aws_temp_credentials() {
    local role_arn=""
    local session_name="TempSession"
    local duration="3600"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --role-arn=*)
                role_arn="${1#*=}"
                ;;
            --session-name=*)
                session_name="${1#*=}"
                ;;
            --duration=*)
                duration="${1#*=}"
                ;;
            *)
                echo "Invalid option. Usage:"
                echo "get_aws_temp_credentials --role-arn=<role_arn> [--session-name=<session_name>] [--duration=<duration_seconds>]"
                return 1
                ;;
        esac
        shift
    done

    if [ -z "$role_arn" ]; then
        echo "Error: --role-arn is required."
        echo "Usage: get_aws_temp_credentials --role-arn=<role_arn> [--session-name=<session_name>] [--duration=<duration_seconds>]"
        return 1
    fi

    local credentials=$(aws sts assume-role \
        --role-arn "$role_arn" \
        --role-session-name "$session_name" \
        --duration-seconds "$duration" \
        --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
        --output text)

    if [ $? -ne 0 ]; then
        echo "Failed to assume role. Check your AWS configuration and permissions."
        return 1
    fi

    local access_key_id=$(echo $credentials | awk '{print $1}')
    local secret_access_key=$(echo $credentials | awk '{print $2}')
    local session_token=$(echo $credentials | awk '{print $3}')

    echo "# Run the following commands to set your AWS credentials:"
    echo "export AWS_ACCESS_KEY_ID='$access_key_id'"
    echo "export AWS_SECRET_ACCESS_KEY='$secret_access_key'"
    echo "export AWS_SESSION_TOKEN='$session_token'"
    echo ""
    echo "# Or copy and paste this one-liner:"
    echo "export AWS_ACCESS_KEY_ID='$access_key_id' AWS_SECRET_ACCESS_KEY='$secret_access_key' AWS_SESSION_TOKEN='$session_token'"
}

get_iam_roles() {
    local query='Roles[*].[RoleName,Arn,CreateDate]'
    local limit=""
    local role_name=""
    local role_name_like=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --limit=*)
                limit="--max-items ${1#*=}"
                ;;
            --role-name=*)
                role_name="${1#*=}"
                ;;
            --role-name-like=*)
                role_name_like="${1#*=}"
                ;;
            *)
                echo "Invalid option. Usage examples:"
                echo "get_iam_roles"
                echo "get_iam_roles --limit=10"
                echo "get_iam_roles --role-name=ExactRoleName"
                echo "get_iam_roles --role-name-like=PartialRoleName"
                return 1
                ;;
        esac
        shift
    done

    local aws_command="aws iam list-roles"
    local result=$(${aws_command} ${limit} --query "${query}" --output text)

    # Define headers
    local headers=("Role Name" "ARN" "Created At")

    # Initialize arrays to store column widths and data
    local -a widths data
    for ((i=0; i<${#headers[@]}; i++)); do
        widths[$i]=${#headers[$i]}
    done

    # Read data, apply filters if necessary, and calculate column widths
    while IFS=$'\t' read -r name arn created_at; do
        [ -z "$name" ] && continue  # Skip empty lines
        
        # Apply filters
        if [ -n "$role_name" ] && [ "$name" != "$role_name" ]; then
            continue
        fi
        if [ -n "$role_name_like" ] && [[ "${name,,}" != *"${role_name_like,,}"* ]]; then
            continue
        fi
        
        data+=("$name" "$arn" "$created_at")
        [ ${#name} -gt ${widths[0]} ] && widths[0]=${#name}
        [ ${#arn} -gt ${widths[1]} ] && widths[1]=${#arn}
        [ ${#created_at} -gt ${widths[2]} ] && widths[2]=${#created_at}
    done <<< "$result"

    # Function to print a separator line
    print_separator() {
        local sep="+"
        for width in "${widths[@]}"; do
            sep+="-$(printf '%0.s-' $(seq 1 $width))-+"
        done
        echo "$sep"
    }

    # Print the table
    print_separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "| %-${widths[$i]}s " "${headers[$i]}"
    done
    echo "|"
    print_separator

    for ((i=0; i<${#data[@]}; i+=3)); do
        printf "| %-${widths[0]}s | %-${widths[1]}s | %-${widths[2]}s |\n" "${data[$i]}" "${data[$i+1]}" "${data[$i+2]}"
    done
    print_separator

    # Print the number of roles found
    local role_count=$((${#data[@]} / 3))
    echo "Total roles found: $role_count"
}

get_ec2_amis() {
    local filters=()
    local limit=""
    local aws_command="aws ec2 describe-images --owners amazon"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name=*)
                filters+=("Name=name,Values=${1#*=}")
                ;;
            --name-like=*)
                filters+=("Name=name,Values=*${1#*=}*")
                ;;
            --ami-id=*)
                filters+=("Name=image-id,Values=${1#*=}")
                ;;
            --ami-id-like=*)
                filters+=("Name=image-id,Values=*${1#*=}*")
                ;;
            --owner-id=*)
                aws_command="aws ec2 describe-images --owners ${1#*=}"
                ;;
            --owner-id-like=*)
                echo "Owner ID like filtering is not supported. Use exact --owner-id instead."
                return 1
                ;;
            --alias=*)
                echo "Alias filtering is not directly supported. Use --owner-id instead."
                return 1
                ;;
            --alias-like=*)
                echo "Alias filtering is not directly supported. Use --owner-id instead."
                return 1
                ;;
            --architecture=*)
                filters+=("Name=architecture,Values=${1#*=}")
                ;;
            --architecture-like=*)
                filters+=("Name=architecture,Values=*${1#*=}*")
                ;;
            --limit=*)
                limit="${1#*=}"
                ;;
            --private)
                aws_command="aws ec2 describe-images --owners self"
                ;;
            *)
                echo "Invalid option. Usage:"
                echo "get_ec2_amis [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --name=VALUE           Filter by exact AMI name"
                echo "  --name-like=VALUE      Filter by partial AMI name"
                echo "  --ami-id=VALUE         Filter by exact AMI ID"
                echo "  --ami-id-like=VALUE    Filter by partial AMI ID"
                echo "  --owner-id=VALUE       Filter by exact owner ID"
                echo "  --architecture=VALUE   Filter by exact architecture"
                echo "  --architecture-like=VALUE  Filter by partial architecture"
                echo "  --limit=NUMBER         Limit the number of results"
                echo "  --private              Search private AMIs instead of public ones"
                echo ""
                echo "Examples:"
                echo "  get_ec2_amis"
                echo "  get_ec2_amis --name=\"amzn2-ami-hvm\""
                echo "  get_ec2_amis --name-like=\"ubuntu\""
                echo "  get_ec2_amis --ami-id=\"ami-12345678\""
                echo "  get_ec2_amis --owner-id=\"123456789012\""
                echo "  get_ec2_amis --architecture=\"x86_64\""
                echo "  get_ec2_amis --limit=5"
                echo "  get_ec2_amis --private"
                return 1
                ;;
        esac
        shift
    done

    local filter_string=""
    for filter in "${filters[@]}"; do
        filter_string+="$filter "
    done

    local result=$(${aws_command} ${filter_string:+--filters $filter_string} \
        --query 'Images[*].[Name,ImageId,OwnerId,ImageLocation,Architecture,CreationDate]' \
        --output json | jq -r 'sort_by(.[5]) | reverse | .[]? | @tsv')

    # Define headers
    local headers=("AMI Name" "AMI Id" "Owner Id" "Owner Alias" "Architecture" "Created At")

    # Initialize arrays to store column widths and data
    local -a widths data
    for ((i=0; i<${#headers[@]}; i++)); do
        widths[$i]=${#headers[$i]}
    done

    # Read data and calculate column widths
    while IFS=$'\t' read -r name id owner alias arch created; do
        [ -z "$name" ] && continue  # Skip empty lines
        alias=$(echo "$alias" | cut -d'/' -f1)  # Extract owner alias from ImageLocation
        data+=("$name" "$id" "$owner" "$alias" "$arch" "$created")
        [ ${#name} -gt ${widths[0]} ] && widths[0]=${#name}
        [ ${#id} -gt ${widths[1]} ] && widths[1]=${#id}
        [ ${#owner} -gt ${widths[2]} ] && widths[2]=${#owner}
        [ ${#alias} -gt ${widths[3]} ] && widths[3]=${#alias}
        [ ${#arch} -gt ${widths[4]} ] && widths[4]=${#arch}
        [ ${#created} -gt ${widths[5]} ] && widths[5]=${#created}
    done <<< "$result"

    # Function to print a separator line
    print_separator() {
        local sep="+"
        for width in "${widths[@]}"; do
            sep+="-$(printf '%0.s-' $(seq 1 $width))-+"
        done
        echo "$sep"
    }

    # Print the table
    print_separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "| %-${widths[$i]}s " "${headers[$i]}"
    done
    echo "|"
    print_separator

    # Only print rows if there's data
    if [ ${#data[@]} -gt 0 ]; then
        local count=0
        for ((i=0; i<${#data[@]}; i+=6)); do
            ((count++))
            [ -n "$limit" ] && [ $count -gt $limit ] && break
            for ((j=0; j<6; j++)); do
                printf "| %-${widths[$j]}s " "${data[$i+$j]}"
            done
            echo "|"
        done
        print_separator
    else
        echo "No results found."
    fi
}

generate_ec2_cf() {
    local instance_type="t3.micro"
    local disk_size="32"
    # Ubuntu Noble 24.04 LTS
    local ami_id="ami-09d556b632f1655da"
    local key_pair="Macbook Air"
    local stack_name=""

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --instance-type=*) instance_type="${1#*=}" ;;
            --disk=*) disk_size="${1#*=}" ;;
            --ami-id=*) ami_id="${1#*=}" ;;
            --key-pair=*) key_pair="${1#*=}" ;;
            --stack-name=*) stack_name="${1#*=}" ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done

    if [[ -z "$stack_name" ]]; then
        echo "Error: --stack-name is a required parameter"
        return 1
    fi

    cat << EOF
AWSTemplateFormatVersion: "2010-09-09"
Description: "Create an Amazon EC2 instance with ${instance_type} instance type, ${disk_size}GB gp3 disk, and allow ports 22, 80, and 443."

Resources:
  EC2Instance:
    Type: "AWS::EC2::Instance"
    Properties:
      InstanceType: "${instance_type}"
      ImageId: "${ami_id}"
      KeyName: "${key_pair}"
      BlockDeviceMappings:
        - DeviceName: "/dev/xvda"
          Ebs:
            VolumeSize: ${disk_size}
            VolumeType: "gp3"
      SecurityGroups:
        - !Ref EC2SecurityGroup
      Tags:
        - Key: "Name"
          Value: "${stack_name}"

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
EOF
}

create_ec2_instance() {
    local instance_type=""
    local stack_name=""
    local disk_size="32"
    # Ubuntu Noble 24.04 LTS
    local ami_id="ami-09d556b632f1655da"
    local key_pair="Macbook Air"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --instance-type=*) instance_type="${1#*=}" ;;
            --stack-name=*) stack_name="${1#*=}" ;;
            --disk=*) disk_size="${1#*=}" ;;
            --ami-id=*) ami_id="${1#*=}" ;;
            --key-pair=*) key_pair="${1#*=}" ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done

    if [[ -z "$instance_type" || -z "$stack_name" ]]; then
        echo "Error: --instance-type and --stack-name are required parameters"
        return 1
    fi

    generate_ec2_cf --instance-type="$instance_type" --disk="$disk_size" --ami-id="$ami_id" --key-pair="$key_pair" --stack-name="$stack_name" | \
    aws cloudformation create-stack \
        --stack-name "$stack_name" \
        --template-body file:///dev/stdin \
        --capabilities CAPABILITY_IAM

    echo "Creating EC2 instance with:"
    echo "  Instance Type: $instance_type"
    echo "  Disk Size: ${disk_size}GB"
    echo "  AMI ID: $ami_id"
    echo "  Key Pair: $key_pair"
    echo "  Stack Name: $stack_name"
}
