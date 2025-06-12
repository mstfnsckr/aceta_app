using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class TamirciBireysel
    {
        public int Id { get; set; }
        public string Ad { get; set; }
        public string Soyad { get; set; }
        public string TC { get; set; }
        public string DukkanAdi { get; set; }
        public string Telefon { get; set; }
        public string EPosta { get; set; }
        public string AracTuru { get; set; }
        public string AracMarkasi { get; set; }
        public string AracModeli { get; set; }
        public string Konum { get; set; }
        public string Sifre { get; set; }
        public bool Durum { get; set; }
        public ICollection<TamirciRandevu>? TamirciRandevular { get; set; }

    }
}