using aceta_app_api.Data;
using aceta_app_api.Models;
using Microsoft.AspNetCore.Mvc;

namespace aceta_app_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AracController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AracController(AppDbContext context)
        {
            _context = context;
        }
        [HttpGet("tum-veriler")]
        public IActionResult TumAracVerileri()
        {
            var turler = _context.AracTurler
                .Select(t => new
                {
                    turId = t.Id,
                    turAdi = t.Ad,
                    markalar = t.Markalar.Select(m => new
                    {
                        markaId = m.Id,
                        markaAdi = m.Ad,
                        modeller = m.Modeller.Select(model => new
                        {
                            modelId = model.Id,
                            modelAdi = model.Ad
                        }).ToList()
                    }).ToList()
                }).ToList();

            return Ok(turler);
        }

        [HttpPost("kayit")]
        public async Task<IActionResult> PostArac([FromBody] Arac arac)
        {
            if (arac == null)
                return BadRequest("Geçersiz veri");

            // Aynı plakadan kayıtlı bir araç var mı diye kontrol et
            var mevcutArac = _context.Araclar.FirstOrDefault(a => a.PlakaNo == arac.PlakaNo);

            if (mevcutArac != null)
                return Conflict(new { message = "Bu plakaya ait bir araç zaten kayıtlı." });

            _context.Araclar.Add(arac);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Araç başarıyla kaydedildi", arac });
        }
        [HttpGet("GetByTC")]
        public IActionResult GetByTcKimlikNo(string TC)
        {
            var araclar = _context.Araclar
                .Where(a => a.TC == TC)
                .Select(a => new {
                    a.Id,
                    a.PlakaNo,
                    a.AracTuru,
                    a.AracMarkasi,
                    a.AracModeli,
                    a.AracYili
                })
                .ToList();

            if (araclar == null || !araclar.Any())
                return NotFound("Araç bulunamadı");

            return Ok(araclar);
        }
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteArac(int id)
        {
            var arac = await _context.Araclar.FindAsync(id);

            if (arac == null)
                return NotFound("Araç bulunamadı");

            _context.Araclar.Remove(arac);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Araç başarıyla silindi" });
        }
        [HttpGet("GetAracTuru/{id}")]
        public IActionResult GetAracTuru(int id)
        {
            var arac = _context.Araclar.Find(id);
            if (arac == null)
                return NotFound("Araç bulunamadı");

            return Ok(new { aracTuru = arac.AracTuru });
        }
    }
}