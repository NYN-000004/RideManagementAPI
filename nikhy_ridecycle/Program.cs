using Microsoft.EntityFrameworkCore;
using Nikhy_demo.Data;
using Nikhy_demo.Services;

var builder = WebApplication.CreateBuilder(args);

// --------------------------------------------------
// Controllers
// --------------------------------------------------

builder.Services.AddControllers();

// --------------------------------------------------
// PostgreSQL
// --------------------------------------------------

builder.Services.AddDbContext<ApplicationDbContext>(
    options =>
        options.UseNpgsql(
            builder.Configuration.GetConnectionString(
                "DefaultConnection")));

// --------------------------------------------------
// Ride Management
// --------------------------------------------------

builder.Services.AddScoped<IRideService, RideService>();

// --------------------------------------------------
// Swagger
// --------------------------------------------------

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen();

// --------------------------------------------------
// CORS
// --------------------------------------------------

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

// --------------------------------------------------
// Database Initialization & Seeding
// --------------------------------------------------

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var logger = services.GetRequiredService<ILogger<Program>>();
    try
    {
        var context = services.GetRequiredService<ApplicationDbContext>();
        await DatabaseSeeder.SeedAsync(context);
        logger.LogInformation("Database migrated and demo data seeded successfully.");
    }
    catch (Exception ex)
    {
        logger.LogWarning(ex, "Could not automatically migrate/seed database. Please check PostgreSQL connection in appsettings.json.");
    }
}

// --------------------------------------------------
// Swagger
// --------------------------------------------------

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();

    app.UseSwaggerUI();
}

// --------------------------------------------------
// CORS
// --------------------------------------------------

app.UseCors("AllowFrontend");

// --------------------------------------------------
// HTTPS
// --------------------------------------------------

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

// --------------------------------------------------
// Authentication / Authorization
// --------------------------------------------------

// Keep your existing authentication middleware here.
// Example:
//
// app.UseAuthentication();

app.UseAuthorization();

// --------------------------------------------------
// Controllers
// --------------------------------------------------

app.MapControllers();

app.Run();