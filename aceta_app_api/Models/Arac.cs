using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class Arac
    {
        public int Id { get; set; }
        public string TC { get; set; }
        public string PlakaNo { get; set; }
        public string AracTuru { get; set; }
        public string AracMarkasi { get; set; }
        public string AracModeli { get; set; }
        public string AracYili { get; set; }
        public ICollection<CekiciRandevu>? CekiciRandevular { get; set; }
        public ICollection<TamirciRandevu>? TamirciRandevular { get; set; }
    }
}
