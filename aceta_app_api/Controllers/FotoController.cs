using aceta_app_api.Data;
using aceta_app_api.Models;
using Microsoft.AspNetCore.Mvc;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;

namespace aceta_app_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FotoController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;
        private readonly AppDbContext _context;
        private readonly ILogger<FotoController> _logger;

        public FotoController(
            IWebHostEnvironment env,
            AppDbContext context,
            ILogger<FotoController> logger)
        {
            _env = env;
            _context = context;
            _logger = logger;
        }


        [HttpPost("upload-oncesi/{randevuId}")]
        public async Task<IActionResult> UploadOncesi(int randevuId, [FromForm] List<IFormFile> files)
        {
            if (files == null || files.Count == 0)
                return BadRequest("En az bir fotoğraf seçmelisiniz.");

            var randevu = await _context.TamirciRandevular.FindAsync(randevuId);
            if (randevu == null) return NotFound("Randevu bulunamadı.");

            var uploadsFolder = Path.Combine(_env.WebRootPath, "uploads");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            foreach (var file in files)
            {
                if (file.Length > 0)
                {
                    var fileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
                    var filePath = Path.Combine(uploadsFolder, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await file.CopyToAsync(stream);
                    }

                    var publicUrl = $"{Request.Scheme}://{Request.Host}/uploads/{fileName}";
                    randevu.OncesiFotograflar.Add(publicUrl);
                }
            }

            await _context.SaveChangesAsync();
            return Ok(randevu.OncesiFotograflar);
        }

        [HttpPost("upload-sonrasi/{randevuId}")]
        public async Task<IActionResult> UploadSonrasi(int randevuId, [FromForm] List<IFormFile> files)
        {
            if (files == null || files.Count == 0)
                return BadRequest("En az bir fotoğraf seçmelisiniz.");

            var randevu = await _context.TamirciRandevular.FindAsync(randevuId);
            if (randevu == null) return NotFound("Randevu bulunamadı.");

            var uploadsFolder = Path.Combine(_env.WebRootPath, "uploads");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            foreach (var file in files)
            {
                if (file.Length > 0)
                {
                    var fileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
                    var filePath = Path.Combine(uploadsFolder, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await file.CopyToAsync(stream);
                    }

                    var publicUrl = $"{Request.Scheme}://{Request.Host}/uploads/{fileName}";
                    randevu.SonrasiFotograflar.Add(publicUrl);
                }
            }

            await _context.SaveChangesAsync();
            return Ok(randevu.SonrasiFotograflar);
        }

        [HttpDelete("sil-foto/{randevuId}")]
        public async Task<IActionResult> SilFoto(int randevuId, [FromQuery] string fotoUrl, [FromQuery] bool isOncesi)
        {
            var randevu = await _context.TamirciRandevular.FindAsync(randevuId);
            if (randevu == null) return NotFound("Randevu bulunamadı.");

            // Fiziksel dosyayı sil
            try
            {
                var uri = new Uri(fotoUrl);
                var fileName = Path.GetFileName(uri.LocalPath);
                var filePath = Path.Combine(_env.WebRootPath, "uploads", fileName);

                if (System.IO.File.Exists(filePath))
                {
                    System.IO.File.Delete(filePath);
                }
            }
            catch (Exception ex)
            {
                // Log the error but don't fail the operation
                _logger.LogError(ex, "Dosya silinirken hata oluştu");
            }

            // Veritabanından sil
            if (isOncesi)
            {
                if (!randevu.OncesiFotograflar.Contains(fotoUrl))
                    return NotFound("Fotoğraf bulunamadı.");
                randevu.OncesiFotograflar.Remove(fotoUrl);
            }
            else
            {
                if (!randevu.SonrasiFotograflar.Contains(fotoUrl))
                    return NotFound("Fotoğraf bulunamadı.");
                randevu.SonrasiFotograflar.Remove(fotoUrl);
            }

            await _context.SaveChangesAsync();
            return Ok();
        }
        [HttpGet("get-oncesi/{randevuId}")]
        public async Task<IActionResult> GetOncesiFotograflar(int randevuId)
        {
            var randevu = await _context.TamirciRandevular.FindAsync(randevuId);
            if (randevu == null) return NotFound("Randevu bulunamadı.");

            return Ok(randevu.OncesiFotograflar ?? new List<string>());
        }

        [HttpGet("get-sonrasi/{randevuId}")]
        public async Task<IActionResult> GetSonrasiFotograflar(int randevuId)
        {
            var randevu = await _context.TamirciRandevular.FindAsync(randevuId);
            if (randevu == null) return NotFound("Randevu bulunamadı.");

            return Ok(randevu.SonrasiFotograflar ?? new List<string>());
        }
        // Resimleri servis ederken özel başlıklar ekleyin
        [HttpGet("get-image/{fileName}")]
        public IActionResult GetImage(string fileName)
        {
            var filePath = Path.Combine(_env.WebRootPath, "uploads", fileName);
            if (!System.IO.File.Exists(filePath))
                return NotFound();

            return PhysicalFile(filePath, "image/jpeg", enableRangeProcessing: true);
        }
        [HttpGet("proxy-image")]
        public async Task<IActionResult> ProxyImage([FromQuery] string url)
        {
            try
            {
                using var httpClient = new HttpClient();
                var response = await httpClient.GetAsync(url);
                
                if (!response.IsSuccessStatusCode)
                    return NotFound();

                var contentType = response.Content.Headers.ContentType?.MediaType ?? "application/octet-stream";
                var stream = await response.Content.ReadAsStreamAsync();
                
                return File(stream, contentType);
            }
            catch
            {
                return NotFound();
            }
        }
    }
}