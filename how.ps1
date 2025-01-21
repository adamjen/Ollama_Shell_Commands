Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Function to check Ollama installation and retrieve available models
function Check-Ollama {
    if (-not (Test-Path "$env:LOCALAPPDATA\Ollama\app.log")) {
        Write-Error "Ollama is not installed. Please install it from https://ollama.ai to use this script."
        exit 1
    }

    $available_models = ollama list | ForEach-Object { $_.Trim() }
    return $available_models
}

# Check if the question is provided
$question = $args[0]
if ($null -eq $question) {
    Write-Warning "Usage: $($MyInvocation.MyCommand.Name) [-y] [-m model_name] <your question>"
    exit 1
}

# Parse command-line arguments
$auto_execute = $false

######### Set Model Here #########
$model = "llama3.2:latest"

for ($index = 0; $index -lt $args.Length; $index++) {
    $arg = $args[$index]
    if ($arg -eq "-y") {
        $auto_execute = $true
        continue
    }
    if ($arg -eq "-m" -and $index + 1 -lt $args.Length) {
        $model = $args[$index + 1]
        if ($null -eq $model) {
            Write-Error "Option -m requires a model name."
            exit 1
        }
        $index++ # Skip next index since it's part of the current argument pair
    }
}

# Retrieve available models from Ollama and check if specified model is available
$available_models = Check-Ollama

$model_available = $false

foreach ($model_name in $available_models) {
    if ($model -eq ($model_name.Split()[0])) {
        $model_available = $true
        break
    }
}

if (-not $model_available) {
    Write-Error "Model '$model' is not available in Ollama."
    ollama list
    exit 1
}

# Prepare the prompt for generating a command
$prompt = "The task is as follows: $question. I want to perform a task in PowerShell on a Windows system. Only create a detailed command that the user can execute, with no detailed explanation of the command. If there are two or more methods, separate each with a new line. Generate a single command that achieves this. If the task is complex or involves multiple steps, provide a sequence of commands separated by &. Ensure the command adheres to best practices and is safe. Output only the plain text command without quotes or formatting."

# Debugging: Prompt
Write-Debug "Prompt is '$prompt'"

# Attempt to generate a valid command once
try {
    Write-Host "Generating command..." -ForegroundColor Yellow
    $command_output = "$PSScriptRoot\command_output.txt"
    $prompt | & ollama run $model | Out-File -FilePath $command_output -Encoding utf8

    if (Test-Path $command_output) {
        # Read the output and remove the file
        $content = Get-Content $command_output -Raw
        Remove-Item $command_output -Force
        
        if ($content) {

        } else {
            Write-Warning "No command was generated."
        }
    } else {
        Write-Error "Failed to generate a command output file."
    }
} catch {
    Write-Error "An error occurred during command generation: $_"
}

# Execute or show the generated command based on user choice
if ($auto_execute) {
    try {
        if ($content -match '&') {
            # If the command contains &, split and execute each command separately
            $commands = $content -split '&'
            foreach ($cmd in $commands) {
                Invoke-Expression $cmd
            }
        } else {
            Invoke-Expression $content
        }
        Write-Host "Command executed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Command execution failed: $_"
        exit 1
    }
} else {
    if (-not $content) {
        Write-Warning "No command was generated to explain."
        exit 1
    }

    Write-Host "Generated command:" -ForegroundColor Cyan
    Write-Host "$content" -ForegroundColor Green

    # Prompt for user confirmation or explanation
    $user_choice = Read-Host "Enter 'y' to execute, 'e' to explain the output, or any other key to exit"
    switch ($user_choice) {
        'y' {
            try {
                if ($content -match '&') {
                    # If the command contains &, split and execute each command separately
                    $commands = $content -split '&'
                    foreach ($cmd in $commands) {
                        Invoke-Expression $cmd
                    }
                } else {
                    Invoke-Expression $content
                }
                Write-Host "Command executed successfully." -ForegroundColor Green
            } catch {
                Write-Error "Command execution failed: $_"
                exit 1
            }
            break
        }

        'e' {
            # Provide an explanation of the generated command using Ollama model
            $prompt_explanation = "Please explain this PowerShell command and its variables to me. The command is: $content"

            try {
                Write-Host "Generating explanation..." -ForegroundColor Yellow
                $explanation_output = "$PSScriptRoot\explanation_output.txt"
                $prompt_explanation | & ollama run $model | Out-File -FilePath $explanation_output -Encoding utf8

                if (Test-Path $explanation_output) {
                    $explanation = Get-Content $explanation_output -Raw
                    Remove-Item $explanation_output -Force
                    
                    if ($explanation) {
                        Write-Host "Explanation:" -ForegroundColor Cyan
                        Write-Host $explanation -ForegroundColor Yellow
                    } else {
                        Write-Warning "No explanation was generated."
                    }
                } else {
                    Write-Error "Failed to generate an explanation output file."
                }
            } catch {
                Write-Error "An error occurred during explanation generation: $_"
                $explanation = "The command provided does not have an available explanation at this time."
            }

            # After handling the explanation, break out of the switch case
            break
        }

        default {
            Write-Host "User chose not to execute or explain. Exiting." -ForegroundColor Cyan
            exit 0
        }
    }
}