using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class AracModel
    {
        public int Id { get; set; }
        public string Ad { get; set; }

        public int AracMarkaId { get; set; }
        public AracMarka AracMarka { get; set; }
    }

}
