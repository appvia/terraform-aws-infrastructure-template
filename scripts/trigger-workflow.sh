#!/bin/bash

# GitHub Workflow Trigger Script
# This script triggers a GitHub workflow with configurable parameters

set -euo pipefail

# Default values
DEFAULT_BRANCH="main"
DEFAULT_WORKFLOW_FILE="terraform.yml"
DEFAULT_ENABLE_PLAN="true"
DEFAULT_ENABLE_APPLY="false"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Trigger a GitHub workflow with configurable parameters.

OPTIONS:
    -t, --token TOKEN          GitHub token (default: uses GITHUB_TOKEN env var)
    -r, --repo REPO            Repository in format 'owner/repo' (default: current origin repository)
    -b, --branch BRANCH        Branch to trigger workflow on (default: $DEFAULT_BRANCH)
    -w, --workflow WORKFLOW    Workflow file name (default: $DEFAULT_WORKFLOW_FILE)
    -p, --plan                 Enable plan step (default: $DEFAULT_ENABLE_PLAN)
    -a, --apply                Enable apply step (default: $DEFAULT_ENABLE_APPLY)
    -f, --follow               Follow workflow execution and show progress
    --force                    Skip confirmation prompt
    --dry-run                  Show what would be executed without running
    -h, --help                 Show this help message

EXAMPLES:
    # Basic usage with default parameters
    $0

    # Trigger with custom parameters and follow execution
    $0 --branch develop --follow

    # Dry run to see what would be executed
    $0 --dry-run

    # Force execution without confirmation
    $0 --force --follow

    # Apply the changes 
    $0 --apply --follow

ENVIRONMENT VARIABLES:
    GITHUB_TOKEN               GitHub token (used if --token not provided)
    GITHUB_REPOSITORY          Current repository (used if --repo not provided)

EOF
}

# Function to get current repository
get_current_repo() {
    if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
        echo "$GITHUB_REPOSITORY"
    elif command -v git >/dev/null 2>&1; then
        local remote_url
        remote_url=$(git config --get remote.origin.url 2>/dev/null || echo "")
        if [[ -n "$remote_url" ]]; then
            # Convert git URL to owner/repo format
            if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/]+)\.git$ ]]; then
                echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
            elif [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/]+)$ ]]; then
                echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
            fi
        fi
    fi
}

# Function to get parent directory name
get_parent_dir_name() {
    basename "$(dirname "$(pwd)")"
}

# Function to check if required tools are available
check_dependencies() {
    local missing_deps=()
    
    if ! command -v gh >/dev/null 2>&1; then
        missing_deps+=("gh")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_color $RED "Error: Missing required dependencies: ${missing_deps[*]}"
        print_color $YELLOW "Please install the missing tools:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "gh")
                    echo "  - GitHub CLI: https://cli.github.com/"
                    ;;
                "jq")
                    echo "  - jq: https://stedolan.github.io/jq/"
                    ;;
            esac
        done
        exit 1
    fi
}

# Function to validate GitHub token
validate_token() {
    local token=$1
    local repo=$2
    
    if ! gh auth status --hostname github.com >/dev/null 2>&1; then
        if [[ -n "$token" ]]; then
            echo "$token" | gh auth login --with-token
        else
            print_color $RED "Error: No valid GitHub token found"
            print_color $YELLOW "Please set GITHUB_TOKEN environment variable or use --token flag"
            exit 1
        fi
    fi
    
    # Test token with repository access
    if ! gh api "repos/$repo" >/dev/null 2>&1; then
        print_color $RED "Error: Cannot access repository $repo"
        print_color $YELLOW "Please check your token permissions and repository name"
        exit 1
    fi
}

# Function to get workflow inputs
get_workflow_inputs() {
    local repo=$1
    local workflow_file=$2
    
    # Get workflow file content to extract inputs
    local workflow_content
    workflow_content=$(gh api "repos/$repo/contents/.github/workflows/$workflow_file" --jq '.content' | base64 -d)
    
    # Extract inputs using grep and sed (basic parsing)
    echo "$workflow_content" | grep -A 50 "inputs:" | grep -E "^\s+[a-zA-Z-]+:" | sed 's/.*\([a-zA-Z-]*\):.*/\1/' | head -20
}

# Function to show confirmation
show_confirmation() {
    local repo=$1
    local branch=$2
    local workflow=$3
    local follow=$5
    local enable_plan=$6
    local enable_apply=$7
    
    print_color $BLUE "=== Workflow Trigger Confirmation ==="
    echo
    print_color $GREEN "Repository:     $repo"
    print_color $GREEN "Branch:         $branch"
    print_color $GREEN "Workflow:       $workflow"
    print_color $GREEN "Enable Plan:    $enable_plan"
    print_color $GREEN "Enable Apply:   $enable_apply"
    print_color $GREEN "Follow:         $follow"
    echo
}

# Function to trigger workflow
trigger_workflow() {
    local repo=$1
    local branch=$2
    local workflow=$3
    local follow=$4
    local enable_plan=$5
    local enable_apply=$6
    
    print_color $BLUE "Triggering workflow..."
    
    # Trigger the workflow with workflow_dispatch inputs
    local workflow_run
    workflow_run=$(gh workflow run "$workflow" \
        --repo "$repo" \
        --ref "$branch" \
        --field "enable-plan=$enable_plan" \
        --field "enable-apply=$enable_apply")
    
    if [[ $? -eq 0 ]]; then
        print_color $GREEN "✓ Workflow triggered successfully!"
        
        if [[ "$follow" == "true" ]]; then
            print_color $BLUE "Following workflow execution..."
            sleep 2  # Give workflow time to start
            
            # Get the latest workflow run
            local run_id
            run_id=$(gh run list --repo "$repo" --workflow "$workflow" --limit 1 --json databaseId --jq '.[0].databaseId')
            
            if [[ -n "$run_id" && "$run_id" != "null" ]]; then
                gh run watch "$run_id" --repo "$repo"
            else
                print_color $YELLOW "Could not find workflow run to follow"
            fi
        else
            print_color $BLUE "Workflow URL: https://github.com/$repo/actions"
        fi
    else
        print_color $RED "✗ Failed to trigger workflow"
        exit 1
    fi
}

# Main function
main() {
    # Initialize variables
    local token=""
    local repo=""
    local branch="$DEFAULT_BRANCH"
    local workflow="$DEFAULT_WORKFLOW_FILE"
    local follow="false"
    local force="false"
    local dry_run="false"
    local enable_plan="$DEFAULT_ENABLE_PLAN"
    local enable_apply="$DEFAULT_ENABLE_APPLY"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--token)
                token="$2"
                shift 2
                ;;
            -r|--repo)
                repo="$2"
                shift 2
                ;;
            -b|--branch)
                branch="$2"
                shift 2
                ;;
            -w|--workflow)
                workflow="$2"
                shift 2
                ;;
            -f|--follow)
                follow="true"
                shift
                ;;
            -p|--plan)
                enable_plan="true"
                shift
                ;;
            -a|--apply)
                enable_apply="true"
                enable_plan="false"
                shift
                ;;
            --force)
                force="true"
                shift
                ;;
            --dry-run)
                dry_run="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_color $RED "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check dependencies
    check_dependencies
    
    # Set default values
    if [[ -z "$repo" ]]; then
        repo=$(get_current_repo)
        if [[ -z "$repo" ]]; then
            print_color $RED "Error: Could not determine repository"
            print_color $YELLOW "Please specify --repo or ensure you're in a git repository"
            exit 1
        fi
    fi
    
    if [[ -z "$token" ]]; then
        token="${GITHUB_TOKEN:-}"
    fi
    
    # Validate token and repository access
    validate_token "$token" "$repo"
    
    # Show confirmation
    show_confirmation "$repo" "$branch" "$workflow" "$follow" "$enable_plan" "$enable_apply"
    
    if [[ "$dry_run" == "true" ]]; then
        print_color $YELLOW "Dry run mode - no workflow will be triggered"
        exit 0
    fi
    
    # Confirm before proceeding
    if [[ "$force" != "true" ]]; then
        echo -e "${YELLOW}Do you want to proceed? (y/N): ${NC}\c"
        read -r confirmation
        if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
            print_color $BLUE "Operation cancelled"
            exit 0
        fi
    fi
    
    # Trigger the workflow
    trigger_workflow "$repo" "$branch" "$workflow" "$follow" "$enable_plan" "$enable_apply"
}

# Run main function with all arguments
main "$@"