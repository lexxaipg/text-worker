import subprocess

# Run the aphrodite API server with the specified model
subprocess.run(["python", "-m", "aphrodite.endpoints.openai.api_server", "--launch-kobold-api"
                "--model", "PygmalionAI/pygmalion-2-7b"])