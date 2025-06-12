using aceta_app_api.Data;
using aceta_app_api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BCrypt.Net;
using System.ComponentModel.DataAnnotations;
using System.Net;
using System.Net.Mail;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace aceta_app_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CekiciController : ControllerBase
    {
        private readonly AppDbContext _context;
        private static Dictionary<string, string> VerificationCodes = new Dictionary<string, string>();
        private static HashSet<string> VerifiedEmails = new HashSet<string>();

        public CekiciController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("TasimaSistemleri")]
        public async Task<ActionResult<IEnumerable<string>>> GetTasimaSistemleri()
        {
            var ozellikAdlari = await _context.DonanimTasimaSistemler
                .Select(x => x.OzellikAdi)
                .ToListAsync();

            return ozellikAdlari;
        }

        [HttpGet("DestekEkipmanlari")]
        public async Task<ActionResult<IEnumerable<string>>> GetDestekEkipmanlari()
        {
            var ozellikAdlari = await _context.DonanimDestekEkipmanlar
                .Select(x => x.OzellikAdi)
                .ToListAsync();

            return ozellikAdlari;
        }

        [HttpGet("TeknikEkipmanlari")]
        public async Task<ActionResult<IEnumerable<string>>> GetTeknikEkipmanlari()
        {
            var ozellikAdlari = await _context.DonanimTeknikEkipmanlar
                .Select(x => x.OzellikAdi)
                .ToListAsync();

            return ozellikAdlari;
        }

        [HttpGet("CekebilecegiAraclar")]
        public async Task<ActionResult<IEnumerable<string>>> GetAracTurleri()
        {
            var ad = await _context.AracTurler
                .Select(x => x.Ad)
                .ToListAsync();

            return ad;
        }
        [HttpPost("kayitbireysel")]
        public IActionResult KayitBireysel([FromBody] CekiciBireysel model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Plaka benzersizlik kontrolü
            var plakaVarMi = _context.CekiciBireyseller.Any(x => x.PlakaNo == model.PlakaNo);
            if (plakaVarMi)
            {
                return BadRequest(new { message = "Bu plaka numarası zaten kayıtlı" });
            }

            try
            {
                model.Sifre = BCrypt.Net.BCrypt.HashPassword(model.Sifre);
                _context.CekiciBireyseller.Add(model);
                _context.SaveChanges();

                return Ok(new { message = "Kayıt başarılı" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Sunucu hatası: " + ex.Message });
            }
        }
        [HttpPost("girisbireysel")]
        public IActionResult GirisBireysel([FromBody] CekiciGirisRequest model)
        {
            if (string.IsNullOrEmpty(model.PlakaNo) || string.IsNullOrEmpty(model.Sifre))
            {
                return BadRequest(new { message = "Plaka ve şifre zorunludur" });
            }

            var cekici = _context.CekiciBireyseller
                .FirstOrDefault(x => x.PlakaNo == model.PlakaNo);

            if (cekici == null)
            {
                return NotFound(new { message = "Bu plakaya kayıtlı çekici bulunamadı" });
            }

            if (!BCrypt.Net.BCrypt.Verify(model.Sifre, cekici.Sifre))
            {
                return Unauthorized(new { message = "Şifre hatalı" });
            }

            return Ok(new
            {
                message = "Giriş başarılı",
                cekici.Id,
                cekici.Ad,
                cekici.Soyad,
                cekici.TC,
                cekici.Telefon,
                cekici.EPosta,
                cekici.PlakaNo,
                cekici.CekebilecegiAraclar,
                cekici.TasimaSistemleri,
                cekici.DestekEkipmanlari,
                cekici.TeknikEkipmanlari,
                cekici.KmBasiUcret,
                cekici.Durum,
            });
        }
        
        [HttpPost("kayitfirma")]
        public IActionResult KayitFirmlar([FromBody] CekiciFirma model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Plaka benzersizlik kontrolü
            var plakaVarMi = _context.CekiciFirmalar.Any(x => x.PlakaNo == model.PlakaNo);
            if (plakaVarMi)
            {
                return BadRequest(new { message = "Bu plaka numarası zaten kayıtlı" });
            }

            try
            {
                model.Sifre = BCrypt.Net.BCrypt.HashPassword(model.Sifre);
                _context.CekiciFirmalar.Add(model);
                _context.SaveChanges();

                return Ok(new { message = "Kayıt başarılı" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Sunucu hatası: " + ex.Message });
            }
        }
        [HttpPost("girisfirma")]
        public IActionResult GirisFirma([FromBody] CekiciGirisRequest model)
        {
            if (string.IsNullOrEmpty(model.PlakaNo) || string.IsNullOrEmpty(model.Sifre))
            {
                return BadRequest(new { message = "Plaka ve şifre zorunludur" });
            }

            var cekici = _context.CekiciFirmalar
                .FirstOrDefault(x => x.PlakaNo == model.PlakaNo);

            if (cekici == null)
            {
                return NotFound(new { message = "Bu plakaya kayıtlı çekici bulunamadı" });
            }

            if (!BCrypt.Net.BCrypt.Verify(model.Sifre, cekici.Sifre))
            {
                return Unauthorized(new { message = "Şifre hatalı" });
            }

            return Ok(new
            {
                message = "Giriş başarılı",
                cekici.Id,
                cekici.FirmaAdi,
                cekici.VergiKimlikNo,
                cekici.YetkiliKisi,
                cekici.Telefon,
                cekici.EPosta,
                cekici.PlakaNo,
                cekici.CekebilecegiAraclar,
                cekici.TasimaSistemleri,
                cekici.DestekEkipmanlari,
                cekici.TeknikEkipmanlari,
                cekici.KmBasiUcret,
                cekici.Durum,
            });
        } 
        [HttpPost("kodgonderbireysel")]
        public async Task<IActionResult> KodGonderBireysel([FromBody] EmailModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { mesaj = "Geçersiz veri girişi" });
            }

            // E-posta format kontrolü
            if (!model.EPosta.Contains("@") || !model.EPosta.Contains("."))
            {
                return BadRequest(new { mesaj = "Geçersiz e-posta formatı" });
            }

            // 6 haneli rastgele kod üretimi
            var random = new Random();
            var kod = string.Concat(Enumerable.Range(0, 6).Select(_ => random.Next(0, 10).ToString()));

            // Kodun e-posta adresine gönderilmesi
            try
            {
                var fromAddress = new MailAddress("araccekicitamir@gmail.com", "Sistem");
                var toAddress = new MailAddress(model.EPosta);
                const string fromPassword = "wbfduhyfpfcdodcp"; // Gmail uygulama şifreniz
                const string subject = "Çekici Kayıt Doğrulama Kodu";
                string body = $"Çekici kaydınız için doğrulama kodunuz: {kod}";

                var smtp = new SmtpClient
                {
                    Host = "smtp.gmail.com",
                    Port = 587,
                    EnableSsl = true,
                    DeliveryMethod = SmtpDeliveryMethod.Network,
                    UseDefaultCredentials = false,
                    Credentials = new NetworkCredential(fromAddress.Address, fromPassword)
                };

                using (var message = new MailMessage(fromAddress, toAddress)
                {
                    Subject = subject,
                    Body = body
                })
                {
                    await smtp.SendMailAsync(message);
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { mesaj = "E-posta gönderilirken hata oluştu", hata = ex.Message });
            }

            // Üretilen kodu saklama
            if (VerificationCodes.ContainsKey(model.EPosta))
            {
                VerificationCodes[model.EPosta] = kod;
            }
            else
            {
                VerificationCodes.Add(model.EPosta, kod);
            }

            return Ok(new { 
                basarili = true, 
                mesaj = "Doğrulama kodu gönderildi",
                // NOT: Gerçek uygulamada kodu client'a dönmeyin, sadece test amaçlı
                kod = kod 
            });
        }
        [HttpPost("koddogrulabireysel")]
        public IActionResult KodDogrulaBireysel([FromBody] KodDogrulamaModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { mesaj = "Geçersiz veri girişi" });
            }

            if (VerificationCodes.TryGetValue(model.EPosta, out var kayitliKod))
            {
                if (kayitliKod == model.Kod)
                {
                    // Doğrulama başarılı
                    VerifiedEmails.Add(model.EPosta);
                    VerificationCodes.Remove(model.EPosta);
                    return Ok(new { 
                        basarili = true, 
                        mesaj = "E-posta başarıyla doğrulandı",
                        dogrulandi = true 
                    });
                }
            }
            return BadRequest(new { 
                basarili = false, 
                mesaj = "Doğrulama kodu hatalı veya süresi dolmuş" 
            });
        }
        [HttpPost("kodgonderfirma")]
        public async Task<IActionResult> KodGonderfirma([FromBody] EmailModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { mesaj = "Geçersiz veri girişi" });
            }

            // E-posta format kontrolü
            if (!model.EPosta.Contains("@") || !model.EPosta.Contains("."))
            {
                return BadRequest(new { mesaj = "Geçersiz e-posta formatı" });
            }

            // 6 haneli rastgele kod üretimi
            var random = new Random();
            var kod = string.Concat(Enumerable.Range(0, 6).Select(_ => random.Next(0, 10).ToString()));

            // Kodun e-posta adresine gönderilmesi
            try
            {
                var fromAddress = new MailAddress("araccekicitamir@gmail.com", "Sistem");
                var toAddress = new MailAddress(model.EPosta);
                const string fromPassword = "wbfduhyfpfcdodcp"; // Gmail uygulama şifreniz
                const string subject = "Çekici Kayıt Doğrulama Kodu";
                string body = $"Çekici kaydınız için doğrulama kodunuz: {kod}";

                var smtp = new SmtpClient
                {
                    Host = "smtp.gmail.com",
                    Port = 587,
                    EnableSsl = true,
                    DeliveryMethod = SmtpDeliveryMethod.Network,
                    UseDefaultCredentials = false,
                    Credentials = new NetworkCredential(fromAddress.Address, fromPassword)
                };

                using (var message = new MailMessage(fromAddress, toAddress)
                {
                    Subject = subject,
                    Body = body
                })
                {
                    await smtp.SendMailAsync(message);
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { mesaj = "E-posta gönderilirken hata oluştu", hata = ex.Message });
            }

            // Üretilen kodu saklama
            if (VerificationCodes.ContainsKey(model.EPosta))
            {
                VerificationCodes[model.EPosta] = kod;
            }
            else
            {
                VerificationCodes.Add(model.EPosta, kod);
            }

            return Ok(new { 
                basarili = true, 
                mesaj = "Doğrulama kodu gönderildi",
                // NOT: Gerçek uygulamada kodu client'a dönmeyin, sadece test amaçlı
                kod = kod 
            });
        }
        [HttpPost("koddogrulafirma")]
        public IActionResult KodDogrulaFirma([FromBody] KodDogrulamaModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { mesaj = "Geçersiz veri girişi" });
            }

            if (VerificationCodes.TryGetValue(model.EPosta, out var kayitliKod))
            {
                if (kayitliKod == model.Kod)
                {
                    // Doğrulama başarılı
                    VerifiedEmails.Add(model.EPosta);
                    VerificationCodes.Remove(model.EPosta);
                    return Ok(new { 
                        basarili = true, 
                        mesaj = "E-posta başarıyla doğrulandı",
                        dogrulandi = true 
                    });
                }
            }
            return BadRequest(new { 
                basarili = false, 
                mesaj = "Doğrulama kodu hatalı veya süresi dolmuş" 
            });
        }
        [HttpPost("sifreyiYenileBireysel")]
        public async Task<IActionResult> SifreyiYenileBireysel([FromBody] SifreYenilemeRequest model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { 
                    success = false,
                    errors = ModelState.Values.SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                });
            }

            try
            {
                // Plaka kontrolü (büyük/küçük harf duyarsız)
                var cekici = await _context.CekiciBireyseller
                    .FirstOrDefaultAsync(c => 
                        c.EPosta == model.EPosta && 
                        c.PlakaNo.ToUpper() == model.PlakaNo.ToUpper());

                if (cekici == null)
                {
                    return NotFound(new { 
                        success = false,
                        message = "E-posta ve plaka eşleşmiyor" 
                    });
                }

                // Şifreyi direkt güncelle (hashsiz)
                cekici.Sifre = BCrypt.Net.BCrypt.HashPassword(model.YeniSifre);
                _context.Update(cekici);
                await _context.SaveChangesAsync();

                return Ok(new {
                    success = true,
                    message = "Şifre güncellendi"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new {
                    success = false,
                    message = "Hata: " + ex.Message
                });
            }
        }
        [HttpPost("sifreyiYenileFirma")]
        public async Task<IActionResult> SifreyiYenileFirma([FromBody] SifreYenilemeRequest model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { 
                    success = false,
                    errors = ModelState.Values.SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                });
            }

            try
            {
                // Plaka kontrolü (büyük/küçük harf duyarsız)
                var cekici = await _context.CekiciFirmalar
                    .FirstOrDefaultAsync(c => 
                        c.EPosta == model.EPosta && 
                        c.PlakaNo.ToUpper() == model.PlakaNo.ToUpper());

                if (cekici == null)
                {
                    return NotFound(new { 
                        success = false,
                        message = "E-posta ve plaka eşleşmiyor" 
                    });
                }

                // Şifreyi direkt güncelle (hashsiz)
                cekici.Sifre = BCrypt.Net.BCrypt.HashPassword(model.YeniSifre); // Direkt atama
                _context.Update(cekici);
                await _context.SaveChangesAsync();

                return Ok(new {
                    success = true,
                    message = "Şifre güncellendi"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new {
                    success = false,
                    message = "Hata: " + ex.Message
                });
            }
        }

        [HttpDelete("silBireysel/{id}")]
        public async Task<IActionResult> SilBireysel(int id)
        {
            var bireysel = await _context.CekiciBireyseller.FindAsync(id);
            if (bireysel == null)
            {
                return NotFound(new { message = "Bireysel kayıt bulunamadı." });
            }

            _context.CekiciBireyseller.Remove(bireysel);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Bireysel kayıt başarıyla silindi." });
        }
        [HttpDelete("silFirma/{id}")]
        public async Task<IActionResult> SilFirma(int id)
        {
            var firma = await _context.CekiciFirmalar.FindAsync(id);
            if (firma == null)
            {
                return NotFound(new { message = "Firma kayıt bulunamadı." });
            }

            _context.CekiciFirmalar.Remove(firma);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Firma kayıt başarıyla silindi." });
        }
        [HttpPatch("guncelleDurumBireysel/{id}")]
        public async Task<IActionResult> GuncelleDurumBireysel(int id, [FromBody] DurumGuncelleRequest model)
        {
            var cekici = await _context.CekiciBireyseller.FindAsync(id);
            if (cekici == null) return NotFound();

            cekici.Durum = model.Durum;
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPatch("guncelleDurumFirma/{id}")]
        public async Task<IActionResult> GuncelleDurumFirma(int id, [FromBody] DurumGuncelleRequest model)
        {
            var cekici = await _context.CekiciFirmalar.FindAsync(id);
            if (cekici == null) return NotFound();

            cekici.Durum = model.Durum;
            await _context.SaveChangesAsync();
            return Ok();
        }
        [HttpPatch("guncelleKonumBireysel/{id}")]
        public async Task<IActionResult> GuncelleKonumBireysel(int id, [FromBody] KonumModel model)
        {
            var cekici = await _context.CekiciBireyseller.FindAsync(id);
            if (cekici == null) return NotFound();

            cekici.Enlem = model.Enlem;
            cekici.Boylam = model.Boylam;

            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPatch("guncelleKonumFirma/{id}")]
        public async Task<IActionResult> GuncelleKonumFirma(int id, [FromBody] KonumModel model)
        {
            var cekici = await _context.CekiciFirmalar.FindAsync(id);
            if (cekici == null) return NotFound();

            cekici.Enlem = model.Enlem;
            cekici.Boylam = model.Boylam;

            await _context.SaveChangesAsync();
            return Ok();
        }
        [HttpGet("aktif-cekiciler")]
        public IActionResult GetAktifCekiciler([FromQuery] string? aracTuru = null)
        {
            var bireyselCekicilerQuery = _context.CekiciBireyseller
                .Where(x => x.Durum);

            var firmaCekicilerQuery = _context.CekiciFirmalar
                .Where(x => x.Durum);

            if (!string.IsNullOrEmpty(aracTuru))
            {
                bireyselCekicilerQuery = bireyselCekicilerQuery
                    .Where(x => x.CekebilecegiAraclar.Contains(aracTuru));

                firmaCekicilerQuery = firmaCekicilerQuery
                    .Where(x => x.CekebilecegiAraclar.Contains(aracTuru));
            }

            var bireyselCekiciler = bireyselCekicilerQuery
                .Select(x => new
                {
                    Tip = "Bireysel",
                    Id = x.Id,
                    AdSoyad = x.Ad + " " + x.Soyad,
                    Enlem = x.Enlem,
                    Boylam = x.Boylam,
                    UcretKm = x.KmBasiUcret,
                    PlakaNo = x.PlakaNo,
                    Telefon = x.Telefon,
                    PuanOrtalamasi = _context.CekiciRandevular
                        .Where(r => r.CekiciBireyselId == x.Id && r.Puan != null)
                        .Average(r => (double?)r.Puan) ?? 0.0
                });

            var firmaCekiciler = firmaCekicilerQuery
                .Select(x => new
                {
                    Tip = "Firma",
                    Id = x.Id,
                    AdSoyad = x.YetkiliKisi,
                    Enlem = x.Enlem,
                    Boylam = x.Boylam,
                    UcretKm = x.KmBasiUcret,
                    PlakaNo = x.PlakaNo,
                    Telefon = x.Telefon,
                    PuanOrtalamasi = _context.CekiciRandevular
                        .Where(r => r.CekiciFirmaId == x.Id && r.Puan != null)
                        .Average(r => (double?)r.Puan) ?? 0.0
                });

            var sonuc = bireyselCekiciler.Concat(firmaCekiciler).ToList();
            return Ok(sonuc);
        }
        [HttpPut("guncelleBireysel/{id}")]
        public async Task<IActionResult> GuncelleBireysel(int id, [FromBody] CekiciBireysel model)
        {
            if (id != model.Id)
            {
                return BadRequest(new { message = "ID uyuşmazlığı" });
            }

            var existingCekici = await _context.CekiciBireyseller.FindAsync(id);
            if (existingCekici == null)
            {
                return NotFound(new { message = "Çekici bulunamadı" });
            }

            try
            {
                // Şifreyi koru (eğer gönderilmediyse)
                if (string.IsNullOrEmpty(model.Sifre))
                {
                    model.Sifre = existingCekici.Sifre;
                }
                else
                {
                    model.Sifre = BCrypt.Net.BCrypt.HashPassword(model.Sifre);
                }

                _context.Entry(existingCekici).CurrentValues.SetValues(model);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Bireysel çekici başarıyla güncellendi" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Güncelleme hatası: " + ex.Message });
            }
        }

        [HttpPut("guncelleFirma/{id}")]
        public async Task<IActionResult> GuncelleFirma(int id, [FromBody] CekiciFirma model)
        {
            if (id != model.Id)
            {
                return BadRequest(new { message = "ID uyuşmazlığı" });
            }

            var existingCekici = await _context.CekiciFirmalar.FindAsync(id);
            if (existingCekici == null)
            {
                return NotFound(new { message = "Firma bulunamadı" });
            }

            try
            {
                // Şifreyi koru (eğer gönderilmediyse)
                if (string.IsNullOrEmpty(model.Sifre))
                {
                    model.Sifre = existingCekici.Sifre;
                }
                else
                {
                    model.Sifre = BCrypt.Net.BCrypt.HashPassword(model.Sifre);
                }

                _context.Entry(existingCekici).CurrentValues.SetValues(model);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Firma çekici başarıyla güncellendi" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Güncelleme hatası: " + ex.Message });
            }
        }
        [HttpGet("konum/{id}/{tip}")]
        public async Task<IActionResult> GetCekiciKonum(int id, string tip)
        {
            try
            {
                if (tip == "Bireysel")
                {
                    var cekici = await _context.CekiciBireyseller
                        .Where(c => c.Id == id)
                        .Select(c => new { c.Enlem, c.Boylam })
                        .FirstOrDefaultAsync();

                    if (cekici == null) return NotFound();
                    return Ok(cekici);
                }
                else if (tip == "Firma")
                {
                    var cekici = await _context.CekiciFirmalar
                        .Where(c => c.Id == id)
                        .Select(c => new { c.Enlem, c.Boylam })
                        .FirstOrDefaultAsync();

                    if (cekici == null) return NotFound();
                    return Ok(cekici);
                }

                return BadRequest("Geçersiz çekici tipi");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }
    }
    public class KonumDto
    {
        public double Enlem { get; set; }
        public double Boylam { get; set; }
    }
     public class KonumModel
    {
        public double Enlem { get; set; }
        public double Boylam { get; set; }
    }

    public class CekiciGirisRequest
    {
        public required string PlakaNo { get; set; }
        public required string Sifre { get; set; }
    }

    public class SifreYenilemeRequest
    {
        public required string EPosta { get; set; }
        public required string YeniSifre { get; set; }
        public required string PlakaNo { get; set; } // Yeni eklendi

    }
    public class DurumGuncelleRequest
    {
        public bool Durum { get; set; }
    }

}
