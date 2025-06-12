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
    public class TamirciController : ControllerBase
    {
        private readonly AppDbContext _context;
        private static Dictionary<string, string> VerificationCodes = new Dictionary<string, string>();
        private static HashSet<string> VerifiedEmails = new HashSet<string>();

        public TamirciController(AppDbContext context)
        {
            _context = context;
        }
        [HttpPost("kayitbireysel")]
        public async Task<IActionResult> KayitBireysel([FromBody] TamirciBireysel model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // E-posta kontrolü
            //if (await _context.TamirciBireyseller.AnyAsync(x => x.DukkanAdi == model.DukkanAdi))
            //    return BadRequest("Bu işletme kayıtlı.");

            // Şifreyi hashle
            model.Sifre = BCrypt.Net.BCrypt.HashPassword(model.Sifre);

            // Durum varsayılan değer
            model.Durum = false;

            _context.TamirciBireyseller.Add(model);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Kayıt başarılı", Data = model });
        }
        [HttpPost("kayitfirma")]
        public async Task<IActionResult> KayitFirma([FromBody] TamirciFirma model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // E-posta kontrolü
            //if (await _context.TamirciBireyseller.AnyAsync(x => x.DukkanAdi == model.DukkanAdi))
            //    return BadRequest("Bu işletme kayıtlı.");

            // Şifreyi hashle
            model.Sifre = BCrypt.Net.BCrypt.HashPassword(model.Sifre);

            // Durum varsayılan değer
            model.Durum = false;

            _context.TamirciFirmalar.Add(model);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Kayıt başarılı", Data = model });
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

            return Ok(new
            {
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
                    return Ok(new
                    {
                        basarili = true,
                        mesaj = "E-posta başarıyla doğrulandı",
                        dogrulandi = true
                    });
                }
            }
            return BadRequest(new
            {
                basarili = false,
                mesaj = "Doğrulama kodu hatalı veya süresi dolmuş"
            });
        }
        [HttpPost("kodgonderfirma")]
        public async Task<IActionResult> KodGonderFirma([FromBody] EmailModel model)
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

            return Ok(new
            {
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
                    return Ok(new
                    {
                        basarili = true,
                        mesaj = "E-posta başarıyla doğrulandı",
                        dogrulandi = true
                    });
                }
            }
            return BadRequest(new
            {
                basarili = false,
                mesaj = "Doğrulama kodu hatalı veya süresi dolmuş"
            });
        }
        [HttpPost("girisbireysel")]
        public IActionResult GirisBireysel([FromBody] TamirciGirisRequest model)
        {
            if (string.IsNullOrEmpty(model.DukkanAdi) || string.IsNullOrEmpty(model.Sifre))
            {
                return BadRequest(new { message = "Dükkan Adı ve şifre zorunludur" });
            }

            var tamirci = _context.TamirciBireyseller
                .FirstOrDefault(x => x.DukkanAdi == model.DukkanAdi);

            if (tamirci == null)
            {
                return NotFound(new { message = "Bu Dükkan Adına kayıtlı çekici bulunamadı" });
            }

            if (!BCrypt.Net.BCrypt.Verify(model.Sifre, tamirci.Sifre))
            {
                return Unauthorized(new { message = "Şifre hatalı" });
            }

            return Ok(new
            {
                message = "Giriş başarılı",
                tamirci.Id,
                tamirci.Ad,
                tamirci.Soyad,
                tamirci.TC,
                tamirci.DukkanAdi,
                tamirci.Telefon,
                tamirci.EPosta,
                tamirci.AracTuru,
                tamirci.AracMarkasi,
                tamirci.AracModeli,
                tamirci.Konum,
                tamirci.Sifre,
                tamirci.Durum,
            });
        }
        [HttpPost("girisfirma")]
        public IActionResult GirisFirma([FromBody] TamirciGirisRequest model)
        {
            if (string.IsNullOrEmpty(model.DukkanAdi) || string.IsNullOrEmpty(model.Sifre))
            {
                return BadRequest(new { message = "Dükkan Adı ve şifre zorunludur" });
            }

            var tamirci = _context.TamirciFirmalar
                .FirstOrDefault(x => x.DukkanAdi == model.DukkanAdi);

            if (tamirci == null)
            {
                return NotFound(new { message = "Bu Dükkan Adınakayıtlı çekici bulunamadı" });
            }

            if (!BCrypt.Net.BCrypt.Verify(model.Sifre, tamirci.Sifre))
            {
                return Unauthorized(new { message = "Şifre hatalı" });
            }

            return Ok(new
            {
                message = "Giriş başarılı",
                tamirci.Id,
                tamirci.FirmaAdi,
                tamirci.VergiKimlikNo,
                tamirci.YetkiliKisi,
                tamirci.DukkanAdi,
                tamirci.Telefon,
                tamirci.EPosta,
                tamirci.AracTuru,
                tamirci.AracMarkasi,
                tamirci.AracModeli,
                tamirci.Konum,
                tamirci.Sifre,
                tamirci.Durum,
            });
        }
        [HttpPost("sifreyiYenileBireysel")]
        public async Task<IActionResult> SifreyiYenileBireysel([FromBody] SifreYenilemeTamirci model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new
                {
                    success = false,
                    errors = ModelState.Values.SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                });
            }

            try
            {
                // Dükkan Adı kontrolü (büyük/küçük harf duyarsız)
                var tamirci = await _context.TamirciBireyseller
                    .FirstOrDefaultAsync(c =>
                        c.EPosta == model.EPosta &&
                        c.DukkanAdi.ToUpper() == model.DukkanAdi.ToUpper());

                if (tamirci == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "E-posta ve DukkanAdi eşleşmiyor"
                    });
                }

                // Şifreyi direkt güncelle (hashsiz)
                tamirci.Sifre = BCrypt.Net.BCrypt.HashPassword(model.YeniSifre);
                _context.Update(tamirci);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    success = true,
                    message = "Şifre güncellendi"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Hata: " + ex.Message
                });
            }
        }
        [HttpPost("sifreyiYenileFirma")]
        public async Task<IActionResult> SifreyiYenileFirma([FromBody] SifreYenilemeTamirci model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new
                {
                    success = false,
                    errors = ModelState.Values.SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                });
            }

            try
            {
                // Dükkan Adı kontrolü (büyük/küçük harf duyarsız)
                var tamirci = await _context.TamirciFirmalar
                    .FirstOrDefaultAsync(c =>
                        c.EPosta == model.EPosta &&
                        c.DukkanAdi.ToUpper() == model.DukkanAdi.ToUpper());

                if (tamirci == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "E-posta ve Dükkan Adı eşleşmiyor"
                    });
                }

                // Şifreyi direkt güncelle (hashsiz)
                tamirci.Sifre = BCrypt.Net.BCrypt.HashPassword(model.YeniSifre); // Direkt atama
                _context.Update(tamirci);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    success = true,
                    message = "Şifre güncellendi"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Hata: " + ex.Message
                });
            }
        }
        [HttpDelete("silTamirciBireysel/{id}")]
        public async Task<IActionResult> SilTamirciBireysel(int id)
        {
            var bireysel = await _context.TamirciBireyseller.FindAsync(id);
            if (bireysel == null)
            {
                return NotFound(new { message = "Bireysel tamirci bulunamadı." });
            }

            _context.TamirciBireyseller.Remove(bireysel);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Bireysel tamirci kaydı başarıyla silindi." });
        }

        [HttpDelete("silTamirciFirma/{id}")]
        public async Task<IActionResult> SilTamirciFirma(int id)
        {
            var firma = await _context.TamirciFirmalar.FindAsync(id);
            if (firma == null)
            {
                return NotFound(new { message = "Tamirci firması bulunamadı." });
            }

            _context.TamirciFirmalar.Remove(firma);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Tamirci firması başarıyla silindi." });
        }

        [HttpPatch("guncelleDurumTamirciBireysel/{id}")]
        public async Task<IActionResult> GuncelleDurumTamirciBireysel(int id, [FromBody] DurumGuncelleRequest model)
        {
            var tamirci = await _context.TamirciBireyseller.FindAsync(id);
            if (tamirci == null)
            {
                return NotFound(new { message = "Bireysel tamirci bulunamadı." });
            }

            tamirci.Durum = model.Durum;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = $"Durum başarıyla {(model.Durum ? "aktif" : "pasif")} yapıldı",
                yeniDurum = tamirci.Durum
            });
        }

        [HttpPatch("guncelleDurumTamirciFirma/{id}")]
        public async Task<IActionResult> GuncelleDurumTamirciFirma(int id, [FromBody] DurumGuncelleRequest model)
        {
            var firma = await _context.TamirciFirmalar.FindAsync(id);
            if (firma == null)
            {
                return NotFound(new { message = "Tamirci firması bulunamadı." });
            }

            firma.Durum = model.Durum;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = $"Durum başarıyla {(model.Durum ? "aktif" : "pasif")} yapıldı",
                yeniDurum = firma.Durum
            });
        }

        [HttpGet("aktif-tamirciler")]
        public IActionResult GetAktifTamirciler([FromQuery] string? aracModeli = null)
        {
            var bireyselTamircilerQuery = _context.TamirciBireyseller
                .Where(x => x.Durum);

            var firmaTamircilerQuery = _context.TamirciFirmalar
                .Where(x => x.Durum);

            if (!string.IsNullOrEmpty(aracModeli))
            {
                bireyselTamircilerQuery = bireyselTamircilerQuery
                    .Where(x => x.AracModeli.Contains(aracModeli));

                firmaTamircilerQuery = firmaTamircilerQuery
                    .Where(x => x.AracModeli.Contains(aracModeli));
            }

            var bireyselTamirciler = bireyselTamircilerQuery
                .Select(x => new
                {
                    id = x.Id,
                    tip = "Bireysel",
                    adSoyad = x.Ad + " " + x.Soyad,
                    konum = x.Konum,
                    telefon = x.Telefon,
                    dukkanAdi = x.DukkanAdi,
                    aracModeli = x.AracModeli,
                    puanOrtalamasi = _context.TamirciRandevular
                        .Where(r => r.TamirciBireyselId == x.Id && r.Puan != null)
                        .Average(r => (double?)r.Puan) ?? 0.0
                });

            var firmaTamirciler = firmaTamircilerQuery
                .Select(x => new
                {
                    id = x.Id,
                    tip = "Firma",
                    adSoyad = x.YetkiliKisi,
                    konum = x.Konum,
                    telefon = x.Telefon,
                    dukkanAdi = x.DukkanAdi,
                    aracModeli = x.AracModeli,
                    puanOrtalamasi = _context.TamirciRandevular
                        .Where(r => r.TamirciFirmaId == x.Id && r.Puan != null)
                        .Average(r => (double?)r.Puan) ?? 0.0
                });

            var sonuc = bireyselTamirciler.Concat(firmaTamirciler).ToList();
            return Ok(sonuc);
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
        [HttpPut("guncelleBireysel/{id}")]
        public async Task<IActionResult> GuncelleBireysel(int id, [FromBody] TamirciBireysel model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var tamirci = await _context.TamirciBireyseller.FindAsync(id);
            if (tamirci == null)
                return NotFound("Tamirci bulunamadı");

            // TC ve email gibi alanlar değiştirilemez
            model.TC = tamirci.TC;
            model.EPosta = tamirci.EPosta;

            // Konum güncellemesi
            if (!string.IsNullOrEmpty(model.Konum))
            {
                tamirci.Konum = model.Konum;
            }
            else
            {
                // Konum boşsa mevcut değeri koru
                model.Konum = tamirci.Konum;
            }

            // Araç bilgileri güncellemesi
            tamirci.AracTuru = model.AracTuru;
            tamirci.AracMarkasi = model.AracMarkasi;
            tamirci.AracModeli = model.AracModeli;

            // Diğer alanlar
            tamirci.Ad = model.Ad;
            tamirci.Soyad = model.Soyad;
            tamirci.DukkanAdi = model.DukkanAdi;
            tamirci.Telefon = model.Telefon;

            // Şifre değişmişse güncelle
            if (!string.IsNullOrEmpty(model.Sifre) && model.Sifre != tamirci.Sifre)
            {
                tamirci.Sifre = BCrypt.Net.BCrypt.HashPassword(model.Sifre);
            }

            await _context.SaveChangesAsync();

            return Ok(new { Message = "Güncelleme başarılı", Data = tamirci });
        }
        [HttpPut("guncelleFirma/{id}")]
        public async Task<IActionResult> GuncelleFirma(int id, [FromBody] TamirciFirma model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var tamirci = await _context.TamirciFirmalar.FindAsync(id);
            if (tamirci == null)
                return NotFound("Tamirci bulunamadı");

            // VergiKimlikNo ve email gibi alanlar değiştirilemez
            model.VergiKimlikNo = tamirci.VergiKimlikNo;
            model.EPosta = tamirci.EPosta;

            // Konum güncellemesi
            if (!string.IsNullOrEmpty(model.Konum))
            {
                tamirci.Konum = model.Konum;
            }
            else
            {
                // Konum boşsa mevcut değeri koru
                model.Konum = tamirci.Konum;
            }

            // Araç bilgileri güncellemesi
            tamirci.AracTuru = model.AracTuru;
            tamirci.AracMarkasi = model.AracMarkasi;
            tamirci.AracModeli = model.AracModeli;

            // Diğer alanlar
            tamirci.FirmaAdi = model.FirmaAdi;
            tamirci.YetkiliKisi = model.YetkiliKisi;
            tamirci.DukkanAdi = model.DukkanAdi;
            tamirci.Telefon = model.Telefon;

            // Şifre değişmişse güncelle
            if (!string.IsNullOrEmpty(model.Sifre) && model.Sifre != tamirci.Sifre)
            {
                tamirci.Sifre = BCrypt.Net.BCrypt.HashPassword(model.Sifre);
            }

            await _context.SaveChangesAsync();

            return Ok(new { Message = "Güncelleme başarılı", Data = tamirci });
        }
        [HttpGet("randevu-durumu/{tamirciId}/{tamirciTipi}/{aracId}")]
        public async Task<IActionResult> GetRandevuDurumu(int tamirciId, string tamirciTipi, int aracId)
        {
            try
            {
                var randevu = await _context.TamirciRandevular
                    .Where(r => (tamirciTipi == "Bireysel" ? r.TamirciBireyselId == tamirciId : r.TamirciFirmaId == tamirciId) &&
                                r.AracId == aracId &&
                                (r.Durum == "OnayBekliyor" || r.Durum == "Onaylandı" || r.Durum == "TamireBaşlandı"))
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
        [HttpPost("olustur")]
        public async Task<IActionResult> RandevuOlustur([FromBody] RandevuOlusturDtoTamirci randevuDto)
        {
            var pendingAppointment = await _context.TamirciRandevular
                .FirstOrDefaultAsync(r =>
                    (randevuDto.TamirciTipi == "Bireysel" ? r.TamirciBireyselId == randevuDto.TamirciId : r.TamirciFirmaId == randevuDto.TamirciId) &&
                    r.KullaniciId == randevuDto.KullaniciId &&
                    r.AracId == randevuDto.AracId &&
                    r.Durum == "OnayBekliyor");

            if (pendingAppointment != null)
            {
                return BadRequest("Bu aracınız için bu çekiciye zaten bir çağrı isteğiniz bulunuyor.");
            }

            var randevu = new TamirciRandevu
            {
                TamirciBireyselId = randevuDto.TamirciTipi == "Bireysel" ? randevuDto.TamirciId : null,
                TamirciFirmaId = randevuDto.TamirciTipi == "Firma" ? randevuDto.TamirciId : null,
                KullaniciId = randevuDto.KullaniciId,
                AracId = randevuDto.AracId,
                KullaniciBaslangıcKonumu = randevuDto.KullaniciKonum,
                TamirciBaslangıcKonumu = randevuDto.TamirciKonum,
                Durum = "OnayBekliyor",
                Ucret = 0, // Başlangıç ücreti
                RandevuTarihi = DateTime.Now
            };

            _context.TamirciRandevular.Add(randevu);
            await _context.SaveChangesAsync();

            return Ok(randevu);
        }
        [HttpGet("tamirci-randevular")]
        public async Task<IActionResult> GetTamirciRandevular(int tamirciId, string tamirciTipi)
        {
            try
            {
                IQueryable<TamirciRandevu> query;

                if (tamirciTipi == "Bireysel")
                {
                    query = _context.TamirciRandevular
                        .Where(r => r.TamirciBireyselId == tamirciId)
                        .Include(r => r.Arac)
                        .Include(r => r.Kullanici);
                }
                else if (tamirciTipi == "Firma")
                {
                    query = _context.TamirciRandevular
                        .Where(r => r.TamirciFirmaId == tamirciId)
                        .Include(r => r.Arac)
                        .Include(r => r.Kullanici);
                }
                else
                {
                    return BadRequest("Geçersiz çekici tipi");
                }

                var randevular = await query
                    .Where(r => r.Durum == "OnayBekliyor" || r.Durum == "Onaylandı" || r.Durum == "TamireBaşlandı")
                    .OrderByDescending(r => r.RandevuTarihi)
                    .ToListAsync();

                var result = randevular.Select(r => new
                {
                    id = r.Id,
                    arac = new
                    {
                        id = r.Arac?.Id,
                        plakaNo = r.Arac?.PlakaNo
                    },
                    kullaniciBaslangıcKonumu = r.KullaniciBaslangıcKonumu,
                    tamirciBaslangıcKonumu = r.TamirciBaslangıcKonumu,
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
        public async Task<IActionResult> OnaylaRandevu(int id)
        {
            try
            {
                var randevu = await _context.TamirciRandevular.FindAsync(id);
                if (randevu == null)
                {
                    return NotFound("Randevu bulunamadı");
                }

                randevu.Durum = "Onaylandı";
                randevu.OnayTarihi = DateTime.Now;
                await _context.SaveChangesAsync();

                return Ok(new { message = "Randevu onaylandı" });
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
                var randevu = await _context.TamirciRandevular.FindAsync(id);
                if (randevu == null)
                {
                    return NotFound("Randevu bulunamadı");
                }

                _context.TamirciRandevular.Remove(randevu);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Randevu silindi" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }

        [HttpPatch("baslat/{id}")]
        public async Task<IActionResult> BaslatRandevu(int id)
        {
            try
            {
                var randevu = await _context.TamirciRandevular.FindAsync(id);
                if (randevu == null)
                {
                    return NotFound("Randevu bulunamadı");
                }

                if (randevu.Durum != "Onaylandı")
                {
                    return BadRequest("Sadece onaylanmış randevular başlatılabilir");
                }

                randevu.Durum = "TamireBaşlandı";
                randevu.BaslamaTarihi = DateTime.Now;
                await _context.SaveChangesAsync();

                return Ok(new { message = "Randevu başlatıldı" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }

        [HttpPatch("tamamla/{id}")]
        public async Task<IActionResult> TamamlaRandevu(int id)
        {
            try
            {
                var randevu = await _context.TamirciRandevular.FindAsync(id);
                if (randevu == null)
                {
                    return NotFound("Randevu bulunamadı");
                }

                if (randevu.Durum != "TamireBaşlandı")
                {
                    return BadRequest("Sadece tamire başlanan randevular tamamlanabilir");
                }

                randevu.Durum = "Tamamlandı";
                randevu.TamamlanmaTarihi = DateTime.Now;

                // Ücret hesaplama (örnek olarak sabit 100 TL)
                randevu.Ucret = 100;

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Randevu tamamlandı",
                    ucret = randevu.Ucret
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Sunucu hatası: {ex.Message}");
            }
        }
        // TamirciController.cs içinde YorumEkle metodunu kontrol edin:

        [HttpPatch("yorum-ekle/{id}")]
        public async Task<IActionResult> YorumEkle(int id, [FromBody] YorumModel model)
        {
            try
            {
                var randevu = await _context.TamirciRandevular
                    .Include(r => r.TamirciBireysel)
                    .Include(r => r.TamirciFirma)
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
                var randevular = await _context.TamirciRandevular
                    .Where(r => r.KullaniciId == kullaniciId &&
                            r.Durum == "Tamamlandı" &&
                            string.IsNullOrEmpty(r.Yorum))
                    .Include(r => r.TamirciBireysel)
                    .Include(r => r.TamirciFirma)
                    .Select(r => new
                    {
                        id = r.Id,
                        tip = r.TamirciBireyselId != null ? "TamirciBireysel" : "TamirciFirma", // Tip isimleri düzeltildi
                        ad = r.TamirciBireysel != null ?
                            $"{r.TamirciBireysel.Ad} {r.TamirciBireysel.Soyad}" :
                            r.TamirciFirma.YetkiliKisi,
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
                IQueryable<TamirciRandevu> query = _context.TamirciRandevular
                    .Where(r => r.Puan != null && r.Puan > 0);

                if (bireyselId.HasValue)
                {
                    query = query.Where(r => r.TamirciBireyselId == bireyselId);
                }
                else if (firmaId.HasValue)
                {
                    query = query.Where(r => r.TamirciFirmaId == firmaId);
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
                IQueryable<TamirciRandevu> query = _context.TamirciRandevular
                    .Where(r => r.Yorum != null && r.Puan != null);

                if (bireyselId.HasValue)
                {
                    query = query.Where(r => r.TamirciBireyselId == bireyselId)
                                .Include(r => r.Kullanici);
                }
                else if (firmaId.HasValue)
                {
                    query = query.Where(r => r.TamirciFirmaId == firmaId)
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
    public class TamirciGirisRequest
    {
        public required string DukkanAdi { get; set; }
        public required string Sifre { get; set; }
    }
    public class SifreYenilemeTamirci
    {
        public required string EPosta { get; set; }
        public required string YeniSifre { get; set; }
        public required string DukkanAdi { get; set; } 

    }
    public class RandevuOlusturDtoTamirci
    {
        public int TamirciId { get; set; }
        public string TamirciTipi { get; set; }
        public int KullaniciId { get; set; }
        public int AracId { get; set; }
        public string KullaniciKonum { get; set; }
        public string TamirciKonum { get; set; }
    }

}
