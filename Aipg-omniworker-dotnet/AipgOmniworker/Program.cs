using AipgOmniworker.Components;
using AipgOmniworker.OmniController;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<BridgeConfigManager>();
builder.Services.AddSingleton<OmniControllerMain>();
builder.Services.AddSingleton<TextWorkerConfigManager>();

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
