using aceta_app_api.Data;
using aceta_app_api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.StaticFiles;

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ApplicationName = typeof(Program).Assembly.FullName,
    ContentRootPath = Directory.GetCurrentDirectory(),
    EnvironmentName = Environments.Development,
    WebRootPath = "wwwroot"
});

// Uygulamanın dinleyeceği URL'ler
builder.WebHost.UseUrls("http://localhost:5085", "https://localhost:7187");

// DbContext ayarları
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// CORS ayarları (Tüm origin'lere izin ver)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader()
              .WithExposedHeaders("Content-Disposition"); // Resimler için ek başlık
    });
});

// Controller'lar
builder.Services.AddControllers();

// Swagger ayarları
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "ACeTa App API",
        Version = "v1",
        Description = "ACeTa App API dokümantasyonu"
    });
});

var app = builder.Build();

// Özel MIME type provider ile statik dosya yapılandırması
var contentTypeProvider = new FileExtensionContentTypeProvider();
contentTypeProvider.Mappings[".jpg"] = "image/jpeg";
contentTypeProvider.Mappings[".jpeg"] = "image/jpeg";
contentTypeProvider.Mappings[".png"] = "image/png";

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(builder.Environment.WebRootPath, "uploads")),
    RequestPath = "/uploads",
    ContentTypeProvider = contentTypeProvider,
    ServeUnknownFileTypes = true // Güvenli ortamlarda kullanın
});

app.UseRouting();
app.UseCors("AllowAll");

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "ACeTa App API v1");
    });
}

app.UseHttpsRedirection();
app.UseAuthorization();

app.UseEndpoints(endpoints =>
{
    endpoints.MapControllers();
});

// Veritabanı tohumlama kodları
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    
    // Arac verilerini ekle
    if (!context.AracTurler.Any())
    {
        foreach (var turAdi in AracVerileri.AracTurleri)
        {
            var tur = new AracTur { Ad = turAdi };
            context.AracTurler.Add(tur);
            context.SaveChanges();

            if (AracVerileri.AracMarkalari.ContainsKey(turAdi))
            {
                foreach (var markaAdi in AracVerileri.AracMarkalari[turAdi])
                {
                    var marka = new AracMarka
                    {
                        Ad = markaAdi,
                        AracTurId = tur.Id
                    };
                    context.AracMarkalar.Add(marka);
                    context.SaveChanges();

                    if (AracVerileri.AracModelleri.ContainsKey(turAdi) &&
                        AracVerileri.AracModelleri[turAdi].ContainsKey(markaAdi))
                    {
                        foreach (var modelAdi in AracVerileri.AracModelleri[turAdi][markaAdi])
                        {
                            var model = new AracModel
                            {
                                Ad = modelAdi,
                                AracMarkaId = marka.Id
                            };
                            context.AracModeller.Add(model);
                        }
                        context.SaveChanges();
                    }
                }
            }
        }
    }

    // Donanim verilerini ekle
    if (!context.DonanimTasimaSistemler.Any() &&
        !context.DonanimDestekEkipmanlar.Any() &&
        !context.DonanimTeknikEkipmanlar.Any())
    {
        foreach (var ozellik in CekiciDonanimOzellikleri.DonanimTasimaSistemleri)
        {
            context.DonanimTasimaSistemler.Add(new DonanimTasimaSistem { OzellikAdi = ozellik });
        }
        context.SaveChanges();

        foreach (var ozellik in CekiciDonanimOzellikleri.DonanimDestekEkipmanlari)
        {
            context.DonanimDestekEkipmanlar.Add(new DonanimDestekEkipman { OzellikAdi = ozellik });
        }
        context.SaveChanges();

        foreach (var ozellik in CekiciDonanimOzellikleri.DonanimTeknikEkipmanlari)
        {
            context.DonanimTeknikEkipmanlar.Add(new DonanimTeknikEkipman { OzellikAdi = ozellik });
        }
        context.SaveChanges();
    }
}

app.Run();