using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class CekiciFirma
    {
        public int Id { get; set; }
        public string FirmaAdi { get; set; }
        public string VergiKimlikNo { get; set; }
        public string YetkiliKisi { get; set; }
        public string Telefon { get; set; }
        public string EPosta { get; set; }
        public string PlakaNo { get; set; }
        public List<string> CekebilecegiAraclar { get; set; } 
        public string TasimaSistemleri { get; set; }
        public List<string> DestekEkipmanlari { get; set; }
        public List<string> TeknikEkipmanlari { get; set; }
        public decimal KmBasiUcret { get; set; }   
        public string Sifre { get; set; }
        public bool Durum { get; set; }
        public double? Enlem { get; set; }
        public double? Boylam { get; set; }
        public ICollection<CekiciRandevu>? CekiciRandevular { get; set; }
    }
}