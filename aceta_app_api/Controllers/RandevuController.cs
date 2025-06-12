using aceta_app_api.Data;
using aceta_app_api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BCrypt.Net;
using System.Net;
using System.Net.Mail;
using System.ComponentModel.DataAnnotations;


namespace aceta_app_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RandevuController : ControllerBase
    {
        private readonly AppDbContext _context;
        public RandevuController(AppDbContext context)
        {
            _context = context;
        }
        [HttpPost("olustur")]
        public async Task<IActionResult> RandevuOlustur([FromBody] RandevuOlusturDto randevuDto)
        {
            var pendingAppointment = await _context.CekiciRandevular
                .FirstOrDefaultAsync(r =>
                    (randevuDto.CekiciTipi == "Bireysel" ? r.CekiciBireyselId == randevuDto.CekiciId : r.CekiciFirmaId == randevuDto.CekiciId) &&
                    r.KullaniciId == randevuDto.KullaniciId &&
                    r.AracId == randevuDto.AracId &&
                    r.Durum == "OnayBekliyor");

            if (pendingAppointment != null)
            {
                return BadRequest("Bu aracınız için bu çekiciye zaten bir çağrı isteğiniz bulunuyor.");
            }

            var randevu = new CekiciRandevu
            {
                CekiciBireyselId = randevuDto.CekiciTipi == "Bireysel" ? randevuDto.CekiciId : null,
                CekiciFirmaId = randevuDto.CekiciTipi == "Firma" ? randevuDto.CekiciId : null,
                KullaniciId = randevuDto.KullaniciId,
                AracId = randevuDto.AracId,
                KullaniciBaslangıcKonumu = randevuDto.KullaniciKonum,
                CekiciBaslangıcKonumu = randevuDto.CekiciKonum,
                Durum = "OnayBekliyor",
                Ucret = 0, // Başlangıç ücreti
                RandevuTarihi = DateTime.Now
            };

            _context.CekiciRandevular.Add(randevu);
            await _context.SaveChangesAsync();

            return Ok(randevu);
        }

        [HttpGet("kullanici-randevular")]
        public async Task<IActionResult> KullaniciRandevular(int kullaniciId)
        {
            var randevular = await _context.CekiciRandevular
                .Where(r => r.KullaniciId == kullaniciId)
                .Include(r => r.Arac)
                .ToListAsync();

            return Ok(randevular);
        }
        [HttpGet("cekici-randevular")]
        public async Task<IActionResult> GetCekiciRandevular(int cekiciId, string cekiciTipi)
        {
            try
            {
                IQueryable<CekiciRandevu> query;

                if (cekiciTipi == "Bireysel")
                {
                    query = _context.CekiciRandevular
                        .Where(r => r.CekiciBireyselId == cekiciId)
                        .Include(r => r.Arac)
                        .Include(r => r.Kullanici);
                }
                else if (cekiciTipi == "Firma")
                {
                    query = _context.CekiciRandevular
                        .Where(r => r.CekiciFirmaId == cekiciId)
                        .Include(r => r.Arac)
                        .Include(r => r.Kullanici);
                }
                else
                {
                    return BadRequest("Geçersiz çekici tipi");
                }

                var randevular = await query
                    .Where(r => r.Durum == "OnayBekliyor" || r.Durum == "Onaylandı" || r.Durum == "HareketeGeçildi")
                    .OrderByDescending(r => r.RandevuTarihi)
                    .ToListAsync();

                var result = randevular.Select(r => new
                {
                    id = r.Id,
                    kullaniciId = r.KullaniciId, // EKLENDİ
                    arac = new
                    {
                        id = r.Arac?.Id,
                        plakaNo = r.Arac?.PlakaNo
                    },
                    kullaniciBaslangıcKonumu = r.KullaniciBaslangıcKonumu,
                    cekiciBaslangıcKonumu = r.CekiciBaslangıcKonumu,
                    durum = r.Durum,
                    ucret = r.Ucret,
                    randevuTarihi = r.RandevuTarihi,
                    onayTarihi = r.OnayTarihi,
                    baslamaTarihi = r.BaslamaTarihi,
                    tamamlanmaTarihi = r.TamamlanmaTarihi
                });

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }

        [HttpPatch("onayla/{id}")]
        public async Task<IActionResult> OnaylaRandevu(int id, [FromBody] OnayTarihiModel model)
        {
            try
            {
                var randevu = await _context.CekiciRandevular.FindAsync(id);
                if (randevu == null)
                {
                    return NotFound("Randevu bulunamadı");
                }

                // Aynı kullanıcının diğer bekleyen randevularını sil
                var digerRandevular = await _context.CekiciRandevular
                    .Where(r => r.KullaniciId == randevu.KullaniciId &&
                                r.Id != id &&
                                r.Durum == "OnayBekliyor" &&
                                r.RandevuTarihi.Date == DateTime.Today)
                    .ToListAsync();

                _context.CekiciRandevular.RemoveRange(digerRandevular);

                randevu.Durum = "Onaylandı";
                randevu.OnayTarihi = model.OnayTarihi;

                await _context.SaveChangesAsync();
                return Ok(new
                {
                    randevu,
                    silinenRandevuSayisi = digerRandevular.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }


        [HttpPatch("baslat/{id}")]
        public async Task<IActionResult> BaslatRandevu(int id, [FromBody] BaslamaTarihiModel model)
        {
            try
            {
                var randevu = await _context.CekiciRandevular.FindAsync(id);
                if (randevu == null)
                {
                    return NotFound("Randevu bulunamadı");
                }

                randevu.Durum = "HareketeGeçildi";
                randevu.BaslamaTarihi = model.BaslamaTarihi;

                await _context.SaveChangesAsync();
                return Ok(randevu);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }

        [HttpPatch("tamamla/{id}")]
        public async Task<IActionResult> TamamlaRandevu(int id, [FromBody] TamamlanmaTarihiModel model)
        {
            try
            {
                var randevu = await _context.CekiciRandevular.FindAsync(id);
                if (randevu == null)
                {
                    return NotFound("Randevu bulunamadı");
                }

                randevu.Durum = "Tamamlandı";
                randevu.TamamlanmaTarihi = model.TamamlanmaTarihi;

                await _context.SaveChangesAsync();
                return Ok(randevu);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }

        [HttpDelete("sil/{id}")]
        public async Task<IActionResult> SilRandevu(int id)
        {
            try
            {
                var randevu = await _context.CekiciRandevular.FindAsync(id);
                if (randevu == null)
                {
                    return NotFound("Randevu bulunamadı");
                }

                _context.CekiciRandevular.Remove(randevu);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Randevu başarıyla silindi" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }
        [HttpGet("takip-bilgisi/{id}")]
        public async Task<IActionResult> GetTakipBilgisi(int id)
        {
            var randevu = await _context.CekiciRandevular
                .Include(r => r.Arac)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (randevu == null || randevu.Durum != "HareketeGeçildi")
            {
                return NotFound("Takip edilebilir randevu bulunamadı");
            }

            // Çekicinin konum bilgilerini al (Bireysel/Firma ayrımı)
            object cekiciKonum = null;
            if (randevu.CekiciBireyselId != null)
            {
                cekiciKonum = await _context.CekiciBireyseller
                    .Where(c => c.Id == randevu.CekiciBireyselId)
                    .Select(c => new { c.Enlem, c.Boylam })
                    .FirstOrDefaultAsync();
            }
            else if (randevu.CekiciFirmaId != null)
            {
                cekiciKonum = await _context.CekiciFirmalar
                    .Where(c => c.Id == randevu.CekiciFirmaId)
                    .Select(c => new { c.Enlem, c.Boylam })
                    .FirstOrDefaultAsync();
            }

            return Ok(new
            {
                randevuId = randevu.Id,
                aracPlaka = randevu.Arac?.PlakaNo,
                baslangicKonum = randevu.KullaniciBaslangıcKonumu,
                cekiciKonum
            });
        }
        [HttpGet("randevu-durumu/{cekiciId}/{cekiciTipi}/{aracId}")]
        public async Task<IActionResult> GetRandevuDurumu(int cekiciId, string cekiciTipi, int aracId)
        {
            try
            {
                var randevu = await _context.CekiciRandevular
                    .Where(r => (cekiciTipi == "Bireysel" ? r.CekiciBireyselId == cekiciId : r.CekiciFirmaId == cekiciId) &&
                                r.AracId == aracId &&
                                (r.Durum == "OnayBekliyor" || r.Durum == "Onaylandı" || r.Durum == "HareketeGeçildi"))
                    .OrderByDescending(r => r.RandevuTarihi)
                    .FirstOrDefaultAsync();

                if (randevu == null)
                {
                    return Ok(new { durum = "Yok" });
                }

                return Ok(new
                {
                    durum = randevu.Durum,
                    randevuId = randevu.Id
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }
        [HttpGet("tamirci-konum/{kullaniciId}/{aracId}")]
        public async Task<IActionResult> GetTamirciKonum(int kullaniciId, int aracId)
        {
            var tamirciRandevu = await _context.TamirciRandevular
                .Include(r => r.TamirciBireysel)
                .Include(r => r.TamirciFirma)
                .FirstOrDefaultAsync(r =>
                    r.KullaniciId == kullaniciId &&
                    r.AracId == aracId &&
                    r.Durum == "Onaylandı");

            if (tamirciRandevu == null)
                return NotFound("Tamirci konumu bulunamadı.");

            string tamirciKonum = "";
            if (tamirciRandevu.TamirciBireyselId != null)
                tamirciKonum = tamirciRandevu.TamirciBireysel.Konum;
            else if (tamirciRandevu.TamirciFirmaId != null)
                tamirciKonum = tamirciRandevu.TamirciFirma.Konum;

            return Ok(new { tamirciKonum });
        }
        [HttpPatch("yorum-ekle/{id}")]
        public async Task<IActionResult> YorumEkle(int id, [FromBody] YorumModel model)
        {
            try
            {
                var randevu = await _context.CekiciRandevular
                    .Include(r => r.CekiciBireysel)
                    .Include(r => r.CekiciFirma)
                    .FirstOrDefaultAsync(r => r.Id == id);

                if (randevu == null)
                    return NotFound("Randevu bulunamadı.");

                if (randevu.Durum != "Tamamlandı")
                    return BadRequest("Sadece tamamlanmış randevulara yorum yapılabilir.");

                if (model.Puan < 1 || model.Puan > 5) // Puan validasyonu
                    return BadRequest("Puan 1-5 arasında olmalı!");

                randevu.Yorum = model.Yorum?.Trim();
                randevu.Puan = model.Puan; // Puan kaydetme
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Yorum ve puan başarıyla eklendi.",
                    puan = model.Puan
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }

        [HttpGet("yorum-bekleyen-randevular/{kullaniciId}")]
        public async Task<IActionResult> GetYorumBekleyenRandevular(int kullaniciId)
        {
            try
            {
                var randevular = await _context.CekiciRandevular
                    .Where(r => r.KullaniciId == kullaniciId &&
                            r.Durum == "Tamamlandı" &&
                            string.IsNullOrEmpty(r.Yorum))
                    .Include(r => r.CekiciBireysel)
                    .Include(r => r.CekiciFirma)
                    .Select(r => new
                    {
                        id = r.Id,
                        tip = r.CekiciBireyselId != null ? "Bireysel" : "Firma",
                        ad = r.CekiciBireysel != null ?
                            $"{r.CekiciBireysel.Ad} {r.CekiciBireysel.Soyad}" :
                            r.CekiciFirma.YetkiliKisi,
                        tarih = r.TamamlanmaTarihi
                    })
                    .ToListAsync();

                return Ok(randevular);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }
        [HttpGet("puan-ortalamasi")]
        public IActionResult GetPuanOrtalamasi([FromQuery] int? bireyselId, [FromQuery] int? firmaId)
        {
            try
            {
                IQueryable<CekiciRandevu> query = _context.CekiciRandevular
                    .Where(r => r.Puan != null && r.Puan > 0);

                if (bireyselId.HasValue)
                {
                    query = query.Where(r => r.CekiciBireyselId == bireyselId);
                }
                else if (firmaId.HasValue)
                {
                    query = query.Where(r => r.CekiciFirmaId == firmaId);
                }
                else
                {
                    return BadRequest("Geçersiz parametre");
                }

                var ortalama = query.Average(r => (double?)r.Puan) ?? 0.0;
                var yuvarlanmisOrtalama = Math.Round(ortalama, 1);

                return Ok(new { ortalama = yuvarlanmisOrtalama });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }
        [HttpGet("yorumlar")]
        public async Task<IActionResult> GetYorumlar([FromQuery] int? bireyselId, [FromQuery] int? firmaId)
        {
            try
            {
                IQueryable<CekiciRandevu> query = _context.CekiciRandevular
                    .Where(r => r.Yorum != null && r.Puan != null);

                if (bireyselId.HasValue)
                {
                    query = query.Where(r => r.CekiciBireyselId == bireyselId)
                                .Include(r => r.Kullanici);
                }
                else if (firmaId.HasValue)
                {
                    query = query.Where(r => r.CekiciFirmaId == firmaId)
                                .Include(r => r.Kullanici);
                }
                else
                {
                    return BadRequest("Geçersiz parametre");
                }

                var yorumlar = await query
                    .OrderByDescending(r => r.TamamlanmaTarihi)
                    .Select(r => new
                    {
                        yorum = r.Yorum,
                        puan = r.Puan,
                        kullaniciAdi = r.Kullanici.Ad + " " + r.Kullanici.Soyad,
                        tarih = r.TamamlanmaTarihi
                    })
                    .ToListAsync();

                return Ok(yorumlar);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }


    }
    public class TakipBilgisiDto
    {
        public int RandevuId { get; set; }
        public string AracPlaka { get; set; }
        public string BaslangicKonum { get; set; }
        public KonumDto CekiciKonum { get; set; }
    }

    public class RandevuOlusturDto
    {
        public int CekiciId { get; set; }
        public string CekiciTipi { get; set; }
        public int KullaniciId { get; set; }
        public int AracId { get; set; }
        public string KullaniciKonum { get; set; }
        public string CekiciKonum { get; set; }
    }
    public class OnayTarihiModel
    {
        public DateTime OnayTarihi { get; set; }
    }

    public class BaslamaTarihiModel
    {
        public DateTime BaslamaTarihi { get; set; }
    }

    public class TamamlanmaTarihiModel
    {
        public DateTime TamamlanmaTarihi { get; set; }
    }
    public class YorumModel
    {
        [Range(1, 5, ErrorMessage = "Puan 1-5 arasında olmalı")]
        public int Puan { get; set; }
        public string Yorum { get; set; }
    }
}
