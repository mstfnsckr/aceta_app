﻿using System.ComponentModel.DataAnnotations;

namespace aceta_app_api.Models
{
    public class Kullanici
    {
        public int Id { get; set; }
        public string Ad { get; set; }
        public string Soyad { get; set; }
        public string Telefon { get; set; }
        public string EPosta { get; set; }
        public string Sifre { get; set; }
        public DateTime DogumTarihi { get; set; }
        public string TC { get; set; }
        public DateTime KayitTarihi { get; set; } = DateTime.Now;
        public ICollection<CekiciRandevu>? CekiciRandevular { get; set; }
        public ICollection<TamirciRandevu>? TamirciRandevular { get; set; }
    }
}
