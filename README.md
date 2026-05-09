# Linux Web Infrastructure

2025 Güz Döneminde Sunucu İşletim Sistemleri dersi kapsamında geliştirdiğim VirtualBox üzerinde Debian tabanlı bir sunucu ortamı kurarak Apache web sunucusu ve BIND9 DNS sunucusunun birlikte çalıştığı bir altyapı projesidir.

## Neler Yaptım

Sanallaştırma ortamında gerçek bir sunucu senaryosu kurguladım. Bir domain (`erenbezek.com`) ve bu domaine bağlı bir subdomain (`yazilim.erenbezek.com`) için hem DNS çözümlemesi hem de HTTP erişimi sağladım. Her şey birbirine bağlı çalışıyor DNS sunucusu domaini çözümlüyor, Apachede doğru sayfayı sunuyor.

## Kullandığım Teknolojiler

- **İşletim Sistemi:** Debian GNU/Linux (VirtualBox üzerinde)
- **Web Sunucusu:** Apache2
- **DNS Sunucusu:** BIND9
- **Ağ:** NAT yapılandırması
- **Test Araçları:** `dig`, `curl`, `ping`, `named-checkzone`, `systemctl`

## Mimari

```
VirtualBox (NAT)
└── Debian GNU/Linux
    ├── Apache2
    │   ├── erenbezek.com           → /var/www/html/
    │   └── yazilim.erenbezek.com   → /var/www/yazilim/
    └── BIND9
        └── db.erenbezek.com (zone dosyası)
            ├── erenbezek.com       → 10.0.2.15
            ├── www.erenbezek.com   → 10.0.2.15
            └── yazilim             → 10.0.2.15
```

## Kurulum Adımları

### 1. Sistem Hazırlığı

```bash
sudo apt update && sudo apt upgrade -y
sudo whoami                             # root erişimi doğrulama
ip a                                    # IP adresi kontrolü (10.0.2.15)
```

### 2. Apache Kurulumu

```bash
sudo apt install apache2 -y
sudo systemctl status apache2           # active (running) olduğunu doğrula
sudo systemctl enable apache2           # sistem açılışında otomatik başlat
```
![Apache Status](screenshots/apache-status.png)

Ana domain sayfası oluşturma:

```bash
sudo mv /var/www/html/index.html /var/www/html/index.html.bak
sudo nano /var/www/html/index.html
```

Subdomain için ayrı dizin oluşturma:

```bash
sudo mkdir /var/www/yazilim
sudo nano /var/www/yazilim/index.html
```

### 3. DNS Çözümlemesi İçin Hosts Dosyası

```bash
sudo nano /etc/hosts
```

Eklenen satırlar:

```
10.0.2.15    erenbezek.com
10.0.2.15    yazilim.erenbezek.com
```

Doğrulama:

```bash
ping -c 3 erenbezek.com
curl http://erenbezek.com
```

### 4. BIND9 Kurulumu

```bash
sudo apt install bind9 bind9utils bind9-dnsutils -y
sudo systemctl status bind9                              # active (running) olduğunu doğrulama
```

Zone dosyası yapılandırması:

```bash
sudo nano /etc/bind/db.erenbezek.com
```

Zone'u `named.conf.local` dosyasına tanımlama:

```bash
sudo nano /etc/bind/named.conf.local
```

Zone doğrulama ve servis yenileme:

```bash
sudo named-checkzone erenbezek.com /etc/bind/db.erenbezek.com
# OK çıktısı beklenir burada

sudo systemctl reload bind9
```

## Test Komutları

```bash
# DNS çözümlemesi (local DNS sunucusundan)
dig @127.0.0.1 erenbezek.com
dig @127.0.0.1 yazilim.erenbezek.com

# HTTP erişim testi
curl http://erenbezek.com
curl http://yazilim.erenbezek.com

# Servis durumu
sudo systemctl status apache2
sudo systemctl status bind9
```
## Sonuçlar

![Ana Domain](screenshots/main-domain.png)

![Subdomain](screenshots/subdomain.png)

![DNS Sorgusu](screenshots/dns-query.png)


## Edindiklerim..

Bir domain in tarayıcıya yazılmasından sayfanın görüntülenmesine kadar geçen süreçte DNS çözümlemesinin nasıl işlediğini, Apache'nin virtual host mantığını ve `systemctl` ile servis yönetimini bu proje üzerinden pratikte gördüm. Zone dosyası yapılandırması ve `dig` çıktısını okumak başta karmaşık gelmişti ama `named-checkzone` ile hata ayıklama süreci oldukça öğreticiydi.
