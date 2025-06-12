using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class CekiciRandevu
    {
        public int Id { get; set; }
        public int? CekiciBireyselId { get; set; }
        public int? CekiciFirmaId { get; set; }
        public int KullaniciId { get; set; }
        public int AracId { get; set; }
        public string KullaniciBaslangıcKonumu { get; set; }
        public string CekiciBaslangıcKonumu { get; set; }
        public string Durum { get; set; }
        public decimal Ucret { get; set; }   
        public DateTime RandevuTarihi { get; set; } 
        public DateTime? OnayTarihi { get; set; }
        public DateTime? BaslamaTarihi { get; set; }
        public DateTime? GeldimTarihi { get; set; }
        public DateTime? TamamlanmaTarihi { get; set; }
        public string? Yorum { get; set; }
        public int? Puan { get; set; }
        public CekiciBireysel CekiciBireysel { get; set; }
        public CekiciFirma CekiciFirma { get; set; }
        public Kullanici Kullanici { get; set; }
        public Arac Arac { get; set; }
    }
}