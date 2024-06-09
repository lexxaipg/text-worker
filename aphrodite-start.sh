# Set default value for GPU memory utilization if not provided
if [ -z "$gpu_memory_utilization" ]; then
    gpu_memory_utilization="0.98"
fi

# Print the entered values
echo "Model Name: $model_name"
echo "Hugging Face Token: $hf_token"
echo "GPU Memory Utilization: $gpu_memory_utilization"
echo "Number of GPUs: $num_gpus"

# Set the Hugging Face token as an environment variable
export HF_TOKEN=$hf_token

# Set up Python environment
python3 -m venv venv
source venv/bin/activate
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
#pip install aphrodite-engine

#Unsure if these next 2 lines are needed
pip install cupy-cuda11x==12.1
#python -m cupyx.tools.install_library --library nccl --cuda 11.x

export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
export APHRODITE_ENGINE_ITERATION_TIMEOUT_S=240
export CUDA_VISIBLE_DEVICES=1,2
export CUDA_DEVICE_ORDER=PCI_BUS_ID

# Construct the command string
command_string="python3 -m aphrodite.endpoints.openai.api_server \
    -tp $num_gpus \
    --model $model_name --load-in-4bit --max-model-len 6000 \
    --gpu-memory-utilization $gpu_memory_utilization \
    --launch-kobold-api"

echo "$command_string"

# Run the aphrodite API server with the specified model and configuration
eval "$command_string"

#curl http://localhost:2243/v1/completions \
#-H "Content-Type: application/json" \
#-H "Authorization: Bearer sk-example" \
#-d '{
#  "model": "Epiculous/NeverSleep-Llama-3-Lumimaid-70B-v0.1-alt-4-Bit-AWQ",
#  "prompt": "How should I bake a cake",
#  "stream": false,
#  "mirostat_mode": 2,
#  "mirostat_tau": 6.5,
#  "mirostat_eta": 0.2
#}'