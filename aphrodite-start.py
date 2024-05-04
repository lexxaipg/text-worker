import subprocess
#https://github.com/PygmalionAI/aphrodite-engine/wiki/3.-Engine-Options#server-options

# Run the aphrodite API server with the specified model
subprocess.run(["python", "-m", "aphrodite.endpoints.openai.api_server", "--launch-kobold-api"
                "--model", "TheBloke/Mistral-7B-v0.1-GPTQ"])