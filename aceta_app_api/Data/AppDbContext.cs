using aceta_app_api.Models;
using Microsoft.EntityFrameworkCore;

namespace aceta_app_api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Kullanici> Kullanicilar { get; set; }
        public DbSet<CekiciBireysel> CekiciBireyseller { get; set; }
        public DbSet<CekiciFirma> CekiciFirmalar { get; set; }
        public DbSet<Arac> Araclar { get; set; }
        public DbSet<TamirciBireysel> TamirciBireyseller { get; set; }
        public DbSet<TamirciFirma> TamirciFirmalar { get; set; }
        public DbSet<AracTur> AracTurler { get; set; }
        public DbSet<AracMarka> AracMarkalar { get; set; }
        public DbSet<AracModel> AracModeller { get; set; }
        public DbSet<DonanimDestekEkipman> DonanimDestekEkipmanlar { get; set; }
        public DbSet<DonanimTasimaSistem> DonanimTasimaSistemler { get; set; }
        public DbSet<DonanimTeknikEkipman> DonanimTeknikEkipmanlar { get; set; }
        public DbSet<CekiciRandevu> CekiciRandevular { get; set; }
        public DbSet<TamirciRandevu> TamirciRandevular { get; set; }


        
        public object EmailKodlar { get; internal set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Kullanici>()
                .HasIndex(u => u.EPosta)
                .IsUnique();
        }
        
    }
}