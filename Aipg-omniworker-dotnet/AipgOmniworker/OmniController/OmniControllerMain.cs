namespace AipgOmniworker.OmniController;

public class OmniControllerMain
{
    public List<string> Output { get; } = new();
    public List<string> TextWorkerOutput { get; } = new();

    public bool Status { get; private set; }

    public event EventHandler? StateChangedEvent;

    private CancellationTokenSource _startCancellation;
    private readonly GridWorkerController _gridWorkerController;
    private readonly BridgeConfigManager _bridgeConfigManager;
    private readonly TextWorkerConfigManager _textWorkerConfigManager;

    public OmniControllerMain(GridWorkerController gridWorkerController, BridgeConfigManager bridgeConfigManager,
        TextWorkerConfigManager textWorkerConfigManager)
    {
        _gridWorkerController = gridWorkerController;
        _bridgeConfigManager = bridgeConfigManager;
        _textWorkerConfigManager = textWorkerConfigManager;
        _gridWorkerController = gridWorkerController;

        _gridWorkerController.OnGridTextWorkerOutputChangedEvent += OnGridTextWorkerOutputChanged;
    }

    private void OnGridTextWorkerOutputChanged(object? sender, string output)
    {
        TextWorkerOutput.Add(output);
        StateChangedEvent?.Invoke(this, EventArgs.Empty);
    }

    public async Task SaveAndRestart()
    {
        try
        {
            Status = false;
            await StartGridTextWorkerAsync();
            Status = true;
        }
        catch (Exception e)
        {
            AddOutput(e.ToString());
            Status = false;
        }
    }

    private async Task StartGridTextWorkerAsync()
    {
        AddOutput("Stopping worker...");
        _startCancellation?.Cancel();

        await _gridWorkerController.KillWorkers();

        _gridWorkerController.ClearOutput();
        Output.Clear();

        AddOutput("Starting worker...");

        _startCancellation = new CancellationTokenSource();

        await StartAphrodite();
        await WaitForAphroditeStart();

        AddOutput("Starting Grid Text Worker...");
        await _gridWorkerController.StartGridTextWorker();
        AddOutput("Grid Text Worker started!");
    }

    private async Task WaitForAphroditeStart()
    {
        try
        {
            AddOutput("Waiting for Aphrodite to start...");
            await WaitForAphriditeToStart()
                .WaitAsync(TimeSpan.FromMinutes(20), _startCancellation.Token);
            AddOutput("Aphrodite started!");
        }
        catch (TimeoutException e)
        {
            AddOutput("Failed to start Aphrodite: timeout.");
        }
        catch (TaskCanceledException e)
        {
            AddOutput("Aphrodite start cancelled.");
        }
        catch (Exception e)
        {
            AddOutput(e.ToString());
        }
    }

    private List<string> GetWorkerOutput()
    {
        return _gridWorkerController.GridTextWorkerOutput;
    }

    private async Task StartAphrodite()
    {
        var textWorkerConfig = await _textWorkerConfigManager.LoadConfig();
        string ModelName = textWorkerConfig.model_name;
        string HuggingFaceToken = textWorkerConfig.hugging_face_token;

        string command = $"(docker container stop aphrodite-engine || ver > nul)" +
                         $"&& (docker rm aphrodite-engine || ver > nul)" +
                         $"&& docker run -d -p 2242:7860 --network ai_network --gpus all --shm-size 8g" +
                         $" -e MODEL_NAME={ModelName}" +
                         $" -e KOBOLD_API=true" +
                         $" -e GPU_MEMORY_UTILIZATION=0.9" +
                         $" -e HF_TOKEN={HuggingFaceToken}" +
                         $" --name aphrodite-engine alpindale/aphrodite-engine";

        AddOutput("");
        AddOutput("To continue, run the following command:");
        AddOutput(command);
        AddOutput("");
    }

    private async Task WaitForAphriditeToStart()
    {
        // Check if there is any response from get on port 7860
        string address = "http://aphrodite-engine:7860";

        while (!_startCancellation.IsCancellationRequested)
        {
            try
            {
                using HttpClient client = new HttpClient();
                HttpResponseMessage response = await client.GetAsync(address);

                if (response.IsSuccessStatusCode)
                {
                    AddOutput("Aphrodite started successfully.");
                    break;
                }
            }
            catch (HttpRequestException e)
            {
            }
            catch (Exception e)
            {
                AddOutput(e.ToString());
            }

            await Task.Delay(1000);
        }
    }

    private void AddOutput(string output)
    {
        Output.Add(output);
        StateChangedEvent?.Invoke(this, EventArgs.Empty);
    }
}
