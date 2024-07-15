using System.Diagnostics;

namespace AipgOmniworker.OmniController;

public class OmniControllerMain
{
    public static OmniControllerMain Instance { get; private set; } = new();

    public List<string> GridTextWorkerOutput { get; private set; } = new();

    public event EventHandler OnGridTextWorkerOutputChangedEvent;

    public string WorkingDirectory => "worker";
    
    public async Task Initialize()
    {
    }

    public async Task StartGridTextWorker()
    {
        try
        {
            await StartGridTextWorkerInternal();
        }
        catch (Exception e)
        {
            PrintGridTextWorkerOutput($"Failed to start grid text worker");
            PrintGridTextWorkerOutput(e.ToString());
        }
    }
    
    private async Task StartGridTextWorkerInternal()
    {
        PrintGridTextWorkerOutput("Starting grid text worker...");

        await Task.Delay(200);
        
        Process? process = Process.Start(new ProcessStartInfo
        {
            FileName = "python",
            Arguments = "-s bridge_scribe.py",
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true,
            WorkingDirectory = WorkingDirectory
        });
        
        if (process == null)
        {
            PrintGridTextWorkerOutput("Failed to start GridTextWorker");
            return;
        }
        
        process.Exited += (sender, args) =>
        {
            PrintGridTextWorkerOutput($"Grid text worker exited! Exit code: {process.ExitCode}");
        };
        
        process.OutputDataReceived += (sender, args) =>
        {
            if (args.Data != null)
            {
                PrintGridTextWorkerOutput(args.Data);
            }
        };

        process.ErrorDataReceived += (sender, args) =>
        {
            if (args.Data != null)
            {
                PrintGridTextWorkerOutput(args.Data);
            }
        };
        
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
    }
    
    private void PrintGridTextWorkerOutput(string output)
    {
        GridTextWorkerOutput.Add(output);

        try
        {
            OnGridTextWorkerOutputChangedEvent?.Invoke(this, EventArgs.Empty);
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }
}
