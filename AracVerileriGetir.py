from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import time

# Başlat: Chrome ayarları
options = Options()
options.add_argument("--headless")
options.add_argument("--disable-gpu")
options.add_argument("--window-size=1920,1080")

driver = webdriver.Chrome(options=options)

# Belirtilen araç türleri
vehicle_urls = [
    "https://www.arabam.com/ikinci-el/otomobil",
    "https://www.arabam.com/ikinci-el/arazi-suv-pick-up",
    "https://www.arabam.com/ikinci-el/elektrik_li-araclar",
    "https://www.arabam.com/ikinci-el/motosiklet",
    "https://www.arabam.com/ikinci-el/minivan-van_panelvan",
    "https://www.arabam.com/ikinci-el/ticari-arac",
    "https://www.arabam.com/ikinci-el/karavan_",
    "https://www.arabam.com/ikinci-el/atv-utv"
]

# Her araç türü için işlem yap
for vehicle_url in vehicle_urls:
    print(f"\n🚗 Araç Türü: {vehicle_url}")

    # Araç türüne ait sayfayı aç
    driver.get(vehicle_url)
    time.sleep(3)
    soup = BeautifulSoup(driver.page_source, "html.parser")

    # Marka verilerini çek
    brand_section = soup.find("div", class_="category-list-wrapper")
    if not brand_section:
        continue

    brand_links = brand_section.find_all("a", class_="list-item")

    for brand in brand_links:
        brand_name = brand.find("span", class_="list-name mr4").get_text(strip=True)
        brand_href = brand["href"]
        brand_url = f"https://www.arabam.com{brand_href}"
        print(f"  🔹 Marka: {brand_name} ({brand_url})")

        # Model verilerini çekmek için markanın linkine git
        driver.get(brand_url)
        time.sleep(3)
        soup = BeautifulSoup(driver.page_source, "html.parser")

        model_section = soup.find("div", class_="category-list-wrapper")
        if not model_section:
            continue

        model_links = model_section.find_all("a", class_="list-item")
        for model in model_links:
            model_name = model.find("span", class_="list-name mr4").get_text(strip=True)
            model_count = model.find("span", class_="count").get_text(strip=True)
            print(f"    📌 Model: {model_name} - {model_count} ilan")

# Tarayıcıyı kapat
driver.quit()
