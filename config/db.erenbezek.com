; Zone dosyası: erenbezek.com
; BIND9 ile yapılandırılmış yerel DNS zone'u

$TTL    604800
@       IN      SOA     erenbezek.com. root.erenbezek.com. (
                        2026011101 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      erenbezek.com.
erenbezek.com.  IN      A       10.0.2.15

@       IN      A       10.0.2.15
www     IN      A       10.0.2.15
yazilim IN      A       10.0.2.15
