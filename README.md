# Ollama-Powershell-Command-Generator

A PowerShell script that leverages Ollama AI to generate and execute commands based on user questions.

## Description
This script interacts with the Ollama AI platform to perform tasks in a Windows environment using PowerShell. It allows users to generate detailed command sequences or single commands by providing a natural language question. The script also supports automatic execution of generated commands.

## Features

- **AI-Powered Command Generation**: Uses Ollama AI models to generate PowerShell commands based on user questions.
- **Error Handling**: Checks for Ollama installation and validates inputs.
- **Multiple Models Support**: Supports different AI models available in Ollama.
- **User Interaction**: Provides options to execute commands automatically or receive explanations.

## Prerequisites

1. **Ollama Installed**: Ensure Ollama is installed on your system. If not, download it from [ollama.ai](https://ollama.ai).
2. **Powershell**: Windows PowerShell must be installed and configured on your system.

## Installation

1. Clone this repository or download the `how.ps1` script.
2. Place the script in a directory of your choice.
3. Open PowerShell as an administrator if necessary, depending on the tasks you plan to perform.

## Usage

### Basic Usage
Run the script with a question:

```powershell
.\how.ps1 "What is the current date?"
```

### Command-Line Arguments

- **`-y`**: Automatically execute the generated command without user confirmation. 
- **`-m <model_name>`**: Specify an Ollama model to use for generating commands. For example:
  ```powershell
  .\how.ps1 -m llama3.2:latest "How can I create a backup of my files?"
- Use e at the end of your question to explain the command in details.

### Examples

1. Generate and execute a command: (Use with caution)
   ```powershell
   .\how.ps1 "List all running processes" -y
   ```
   
2. Generate a command and receive an explanation:
   ```powershell
   .\how.ps1 "How can I create a system backup?"
   ```

## Contributing

Contributions are welcome! If you encounter issues or have suggestions, please open an issue on the GitHub repository or submit a pull request.

## License

Go for it :)

---

This README provides clear instructions for users and contributors, ensuring that anyone who downloads the script understands how to use it effectively.