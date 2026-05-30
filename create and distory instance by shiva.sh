#!/bin/bash
# ============================================================
#  EC2 Instance Manager
#  Usage:
#    ./ec2_manager.sh create   - Launch a new EC2 instance
#    ./ec2_manager.sh destroy  - Terminate an existing instance
# ============================================================

set -euo pipefail

# ─── CONFIGURATION ──────────────────────────────────────────
AMI_ID="ami-0c55b159cbfafe1f0"        # Amazon Linux 2 (us-east-1); update as needed
INSTANCE_TYPE="t2.micro"
KEY_NAME="my-key-pair"                 # Your existing EC2 key pair name
SECURITY_GROUP_ID="sg-xxxxxxxxxx"     # Your security group ID
SUBNET_ID="subnet-xxxxxxxxxx"         # Your subnet ID (optional; remove if using default VPC)
INSTANCE_NAME="managed-instance"       # Tag name for the instance
REGION="us-east-1"                     # AWS region
STATE_FILE="$HOME/.ec2_instance_id"   # Local file to persist the instance ID
# ────────────────────────────────────────────────────────────

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log()     { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ─── DEPENDENCY CHECK ───────────────────────────────────────
check_deps() {
  if ! command -v aws &>/dev/null; then
    error "AWS CLI not found. Install it: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
    exit 1
  fi
  if ! command -v jq &>/dev/null; then
    error "'jq' is required. Install with: sudo apt install jq  OR  brew install jq"
    exit 1
  fi
}

# ─── CREATE ─────────────────────────────────────────────────
create_instance() {
  log "Launching EC2 instance..."
  log "  AMI          : $AMI_ID"
  log "  Type         : $INSTANCE_TYPE"
  log "  Key Pair     : $KEY_NAME"
  log "  Region       : $REGION"
  echo ""

  INSTANCE_ID=$(aws ec2 run-instances \
    --region "$REGION" \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --subnet-id "$SUBNET_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
    error "Failed to launch instance."
    exit 1
  fi

  success "Instance launched: $INSTANCE_ID"
  echo "$INSTANCE_ID" > "$STATE_FILE"
  log "Instance ID saved to: $STATE_FILE"
  echo ""

  # Wait for the instance to be in 'running' state
  log "Waiting for instance to reach 'running' state..."
  aws ec2 wait instance-running \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID"

  # Fetch IP addresses
  INSTANCE_INFO=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0]" \
    --output json)

  PUBLIC_IP=$(echo "$INSTANCE_INFO"  | jq -r '.PublicIpAddress  // "N/A (no public IP assigned)"')
  PRIVATE_IP=$(echo "$INSTANCE_INFO" | jq -r '.PrivateIpAddress // "N/A"')
  AZ=$(echo "$INSTANCE_INFO"         | jq -r '.Placement.AvailabilityZone')
  STATE=$(echo "$INSTANCE_INFO"      | jq -r '.State.Name')

  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║        INSTANCE DETAILS              ║${NC}"
  echo -e "${BOLD}╠══════════════════════════════════════╣${NC}"
  echo -e "${BOLD}║${NC} Instance ID  : ${GREEN}$INSTANCE_ID${NC}"
  echo -e "${BOLD}║${NC} State        : ${GREEN}$STATE${NC}"
  echo -e "${BOLD}║${NC} Region/AZ    : $AZ"
  echo -e "${BOLD}║${NC} Public  IP   : ${YELLOW}$PUBLIC_IP${NC}"
  echo -e "${BOLD}║${NC} Private IP   : ${CYAN}$PRIVATE_IP${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"

  if [[ "$PUBLIC_IP" != "N/A"* ]]; then
    echo ""
    log "SSH connect:  ssh -i ~/.ssh/${KEY_NAME}.pem ec2-user@${PUBLIC_IP}"
  fi
}

# ─── DESTROY ────────────────────────────────────────────────
destroy_instance() {
  # Try to read stored instance ID
  if [[ -f "$STATE_FILE" ]]; then
    INSTANCE_ID=$(cat "$STATE_FILE")
  else
    # Prompt user if no state file exists
    echo -n "Enter Instance ID to terminate: "
    read -r INSTANCE_ID
  fi

  if [[ -z "$INSTANCE_ID" ]]; then
    error "No instance ID provided."
    exit 1
  fi

  warn "You are about to TERMINATE instance: ${BOLD}$INSTANCE_ID${NC}"
  echo -n "Are you sure? Type 'yes' to confirm: "
  read -r CONFIRM

  if [[ "$CONFIRM" != "yes" ]]; then
    warn "Aborted. No changes made."
    exit 0
  fi

  log "Terminating instance $INSTANCE_ID ..."
  aws ec2 terminate-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "TerminatingInstances[0].CurrentState.Name" \
    --output text

  success "Termination initiated for: $INSTANCE_ID"
  log "Waiting for instance to reach 'terminated' state..."

  aws ec2 wait instance-terminated \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID"

  success "Instance $INSTANCE_ID has been terminated."

  # Clean up state file
  if [[ -f "$STATE_FILE" ]]; then
    rm -f "$STATE_FILE"
    log "Removed state file: $STATE_FILE"
  fi
}

# ─── STATUS ─────────────────────────────────────────────────
status_instance() {
  if [[ ! -f "$STATE_FILE" ]]; then
    warn "No saved instance found at $STATE_FILE"
    exit 0
  fi

  INSTANCE_ID=$(cat "$STATE_FILE")
  log "Fetching status for: $INSTANCE_ID"

  INSTANCE_INFO=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0]" \
    --output json)

  PUBLIC_IP=$(echo "$INSTANCE_INFO"  | jq -r '.PublicIpAddress  // "N/A"')
  PRIVATE_IP=$(echo "$INSTANCE_INFO" | jq -r '.PrivateIpAddress // "N/A"')
  STATE=$(echo "$INSTANCE_INFO"      | jq -r '.State.Name')
  AZ=$(echo "$INSTANCE_INFO"         | jq -r '.Placement.AvailabilityZone')

  echo ""
  echo -e "${BOLD}Instance ID  :${NC} $INSTANCE_ID"
  echo -e "${BOLD}State        :${NC} ${GREEN}$STATE${NC}"
  echo -e "${BOLD}Region/AZ    :${NC} $AZ"
  echo -e "${BOLD}Public  IP   :${NC} ${YELLOW}$PUBLIC_IP${NC}"
  echo -e "${BOLD}Private IP   :${NC} ${CYAN}$PRIVATE_IP${NC}"
}

# ─── HELP ───────────────────────────────────────────────────
usage() {
  echo ""
  echo -e "${BOLD}Usage:${NC} $0 {create|destroy|status}"
  echo ""
  echo "  create   Launch a new EC2 instance and display its IPs"
  echo "  destroy  Terminate the running instance"
  echo "  status   Show current state and IPs of the saved instance"
  echo ""
}

# ─── ENTRYPOINT ─────────────────────────────────────────────
check_deps

case "${1:-}" in
  create)  create_instance  ;;
  destroy) destroy_instance ;;
  status)  status_instance  ;;
  *)       usage; exit 1    ;;
esac
