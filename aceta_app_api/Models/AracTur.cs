using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class AracTur
    {
        public int Id { get; set; }
        public string Ad { get; set; }
        public List<AracMarka> Markalar { get; set; }
    }

}