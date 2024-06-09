#!/bin/bash
read -p "Enter the Hugging Face token: " hf_token
model_name="meta-llama/Meta-Llama-3-8B-Instruct"

gpu_memory_utilization="0.9"

# Print the entered values
echo "Model Name: $model_name"
echo "Hugging Face Token: $hf_token"
echo "GPU Memory Utilization: $gpu_memory_utilization"

# Set the Hugging Face token as an environment variable
export HF_TOKEN=$hf_token

# Set up Python environment
python3 -m venv venv
source venv/bin/activate
pip install aphrodite-engine

# Construct the command string
command_string="python3 -m aphrodite.endpoints.openai.api_server --model $model_name \
--gpu-memory-utilization $gpu_memory_utilization \
--launch-kobold-api"

echo "$command_string"

# Run the aphrodite API server with the specified model and configuration
eval "$command_string"