using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class TamirciRandevu
    {
        public int Id { get; set; }
        public int? TamirciBireyselId { get; set; }
        public int? TamirciFirmaId { get; set; }
        public int KullaniciId { get; set; }
        public int AracId { get; set; }
        public string KullaniciBaslangıcKonumu { get; set; }
        public string TamirciBaslangıcKonumu { get; set; }
        public string Durum { get; set; }
        public decimal Ucret { get; set; }   
        public DateTime RandevuTarihi { get; set; } 
        public DateTime? OnayTarihi { get; set; }
        public DateTime? BaslamaTarihi { get; set; }
        public DateTime? TamamlanmaTarihi { get; set; }
        public List<string>? OncesiFotograflar { get; set; } = new List<string>();
        public List<string>? SonrasiFotograflar { get; set; } = new List<string>();  
        public string? Yorum { get; set; }
        public int? Puan { get; set; }
        public TamirciBireysel TamirciBireysel { get; set; }
        public TamirciFirma TamirciFirma { get; set; }
        public Kullanici Kullanici { get; set; }
        public Arac Arac { get; set; }    
        }
}