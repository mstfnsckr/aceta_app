using aceta_app_api.Models;
using aceta_app_api.Data;
using Microsoft.EntityFrameworkCore;

namespace aceta_app_api.Data
{
    public static class CekiciDonanimOzellikleri
    {
        public static readonly List<string> DonanimTasimaSistemleri = new()
        {
            "Hidrolik Vinç", "Hareketli Platform", "Sabit Kasa", "Sepetli Platform"
        };

        public static readonly List<string> DonanimDestekEkipmanlari = new()
        {
            "Halat/Kanca Sistemi", "Motosiklet Taşıma Aparatı", "ATV/UTV Taşıyıcı"
        };

        public static readonly List<string> DonanimTeknikEkipmanlari = new()
        {
            "Çekme Halatı/Kancası", "Emniyet Kemeri/Sabitleme Sistemi", "Acil Üçgen ve Reflektörler",
            "İlk Yardım Çantası", "Hava Kompresörü", "Motor Soğutma Ünitesi",
            "Elektrikli Araç Şarj Kablosu", "OBD2 Arıza Tespit Cihazı", "Akü Takviye Kabloları",
            "Yangın Söndürücü", "Kriko ve Takoz Seti"
        };
    }
}