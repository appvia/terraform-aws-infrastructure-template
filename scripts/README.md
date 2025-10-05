# GitHub Workflow Trigger Scripts

This directory contains scripts to trigger GitHub workflows with configurable parameters.

## Scripts

- `trigger-workflow.sh` - Main script with full functionality
- `trigger.sh` - Simple wrapper script for easier usage

## Prerequisites

Before using these scripts, ensure you have the following tools installed:

1. **GitHub CLI (`gh`)** - [Installation Guide](https://cli.github.com/)
2. **jq** - [Installation Guide](https://stedolan.github.io/jq/)

### Authentication

The script will use one of the following authentication methods (in order of preference):

1. GitHub CLI authentication (`gh auth login`)
2. `--token` flag
3. `GITHUB_TOKEN` environment variable

## Usage

### Basic Usage

```bash
# Trigger workflow with default parameters
./scripts/trigger.sh

# Or use the full script name
./scripts/trigger-workflow.sh
```

### Advanced Usage

```bash
# Trigger with custom parameters and follow execution
./scripts/trigger.sh \
  --branch develop \
  --terragrunt-dir ./accounts/eu-west-2 \
  --follow

# Force execution without confirmation
./scripts/trigger.sh \
  --force \
  --follow

# Dry run to see what would be executed
./scripts/trigger.sh \
  --dry-run
```

## Command Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --token TOKEN` | GitHub token | Uses `GITHUB_TOKEN` env var |
| `-r, --repo REPO` | Repository in format 'owner/repo' | Current repository |
| `-b, --branch BRANCH` | Branch to trigger workflow on | `main` |
| `-w, --workflow WORKFLOW` | Workflow file name | `terragrunt.yml` |
| `-d, --terragrunt-dir DIR` | Terragrunt directory | `.` |
| `-f, --follow` | Follow workflow execution | `false` |
| `--force` | Skip confirmation prompt | `false` |
| `--dry-run` | Show what would be executed | `false` |
| `-h, --help` | Show help message | - |

## Examples

### Example 1: Basic Workflow Trigger

```bash
./scripts/trigger.sh
```

This will:

- Use the current repository
- Trigger on the `main` branch
- Use the default terragrunt directory (`.`)
- Use the default AWS role (`lza-application-landing-zones`)
- Show confirmation before proceeding

### Example 2: Follow Workflow Execution

```bash
./scripts/trigger.sh --follow
```

This will:

- Trigger the workflow
- Automatically follow the execution and show progress
- Display real-time logs from the workflow

### Example 3: Custom Branch and Directory

```bash
./scripts/trigger.sh \
  --branch feature/new-feature \
  --terragrunt-dir ./accounts/us-east-1
```

### Example 4: Force Execution (No Confirmation)

```bash
./scripts/trigger.sh \
  --force \
  --follow
```

### Example 5: Dry Run

```bash
./scripts/trigger.sh --dry-run
```

This will show what would be executed without actually triggering the workflow.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GITHUB_TOKEN` | GitHub token (used if `--token` not provided) |
| `GITHUB_REPOSITORY` | Current repository (used if `--repo` not provided) |

## Workflow Parameters

The script automatically maps command line options to workflow inputs:

| Script Option | Workflow Input | Description |
|---------------|----------------|-------------|
| `--aws-role` | `aws-role` | AWS Role to assume |
| `--terragrunt-dir` | `terragrunt-dir` | Terragrunt directory |

## Error Handling

The script includes comprehensive error handling:

- **Missing Dependencies**: Checks for required tools (`gh`, `jq`)
- **Invalid Token**: Validates GitHub token and repository access
- **Missing Parameters**: Validates required parameters (none required for basic usage)
- **Repository Access**: Verifies access to the target repository
- **Workflow Validation**: Ensures the workflow file exists

## Troubleshooting

### Common Issues

1. **"Missing required dependencies"**
   - Install GitHub CLI: <https://cli.github.com/>
   - Install jq: <https://stedolan.github.io/jq/>

2. **"No valid GitHub token found"**
   - Run `gh auth login` to authenticate
   - Or set `GITHUB_TOKEN` environment variable
   - Or use `--token` flag

3. **"Cannot access repository"**
   - Check repository name format (owner/repo)
   - Verify token has access to the repository
   - Ensure repository exists

4. **"Workflow not found"**
   - Check workflow file name
   - Ensure workflow file exists in `.github/workflows/`
   - Verify the workflow is valid

### Debug Mode

To debug issues, you can:

1. Use `--dry-run` to see what would be executed
2. Check the GitHub Actions tab for workflow runs
3. Use `gh run list` to see recent workflow runs
4. Use `gh run view <run-id>` to see specific run details

## Integration

### CI/CD Integration

You can integrate this script into your CI/CD pipeline:

```yaml
- name: Trigger Workflow
  run: |
    ./scripts/trigger.sh \
      --aws-account-id ${{ secrets.AWS_ACCOUNT_ID }} \
      --token ${{ secrets.GITHUB_TOKEN }} \
      --follow
```

### Alias Setup

Add an alias to your shell profile for easier usage:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias trigger-workflow='./scripts/trigger.sh'
```

Then use:

```bash
trigger-workflow --follow
```
