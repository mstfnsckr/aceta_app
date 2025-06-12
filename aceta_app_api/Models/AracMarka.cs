using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class AracMarka
    {
        public int Id { get; set; }
        public string Ad { get; set; }

        public int AracTurId { get; set; }
        public AracTur AracTur { get; set; }

        public List<AracModel> Modeller { get; set; }
    }

}