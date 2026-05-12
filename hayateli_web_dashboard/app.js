import { ENV } from './env.js';

// 1. Firebase Başlatma (Şifreler env.js'den çekilir)
const app = window.initializeApp(ENV.FIREBASE);
const db = window.getFirestore(app);

// 2. Google Maps API'yi Dinamik Olarak (HTML'de görünmeden) Yükleme
const mapScript = document.createElement('script');
mapScript.src = `https://maps.googleapis.com/maps/api/js?key=${ENV.GOOGLE_MAPS_API_KEY}&callback=initMap`;
mapScript.async = true;
mapScript.defer = true;
document.head.appendChild(mapScript);

let map;
let marker;
const googleMapsDarkTheme = [ { elementType: "geometry", stylers: [{ color: "#242f3e" }] }, { elementType: "labels.text.stroke", stylers: [{ color: "#242f3e" }] }, { elementType: "labels.text.fill", stylers: [{ color: "#746855" }] }, { featureType: "water", elementType: "geometry", stylers: [{ color: "#17263c" }] } ];

window.initMap = function() {
    map = new google.maps.Map(document.getElementById("map"), {
        zoom: 16,
        center: { lat: 39.92, lng: 32.85 },
        disableDefaultUI: true,
        styles: googleMapsDarkTheme
    });
};

const pathParts = window.location.pathname.split('/');
const sessionId = pathParts[pathParts.length - 1] || "TEST_SESSION";

const hashParams = new URLSearchParams(window.location.hash.substring(1));
const rawKey = hashParams.get('key');
const rawIv = hashParams.get('iv');

function decryptData(encryptedBase64) {
    try {
        const key = CryptoJS.enc.Base64.parse(rawKey);
        const iv = CryptoJS.enc.Base64.parse(rawIv);
        const cipherParams = CryptoJS.lib.CipherParams.create({ ciphertext: CryptoJS.enc.Base64.parse(encryptedBase64) });
        const decrypted = CryptoJS.AES.decrypt(cipherParams, key, { iv: iv, mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7 });
        return JSON.parse(decrypted.toString(CryptoJS.enc.Utf8));
    } catch (e) {
        return null;
    }
}

if (rawKey && rawIv) {
    window.onSnapshot(window.doc(db, "active_sos", sessionId), (docSnap) => {
        if (docSnap.exists()) {
            const data = docSnap.data();
            
            if(data.status === "CANCELLED") {
                document.getElementById('statusText').innerText = "TAKİP SONLANDIRILDI - KİŞİ GÜVENDE";
                document.getElementById('statusBanner').style.background = "#34C759";
                document.getElementById('loadingIcon').style.display = "none";
                return;
            } else {
                document.getElementById('statusText').innerText = "Acil Durum Sinyali Alınıyor";
                document.getElementById('loadingIcon').style.display = "none";
            }

            const realData = decryptData(data.payload);
            
            if (realData) {
                document.getElementById('victimName').innerText = realData.name || "Bilinmiyor";
                document.getElementById('victimPhone').innerText = realData.phone || "Telefon Yok";
                document.getElementById('victimBattery').innerText = realData.battery || "%--";
                document.getElementById('victimSpeed').innerText = realData.speed || "0";
                
                // Yeni Veriler (Eğer test aşamasında yoksa varsayılan değer gösterir)
                document.getElementById('victimBloodType').innerText = realData.bloodType || "Bilinmiyor";
                
                const date = new Date(data.timestamp || Date.now());
                const timeString = date.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
                document.getElementById('lastUpdated').innerText = `Son Güncelleme: ${timeString}`;
                document.getElementById('victimTime').innerText = timeString;

                const position = { lat: parseFloat(realData.lat), lng: parseFloat(realData.lng) };
                
                if (!marker) {
                    marker = new google.maps.Marker({
                        position: position,
                        map: map,
                        icon: {
                            path: google.maps.SymbolPath.CIRCLE,
                            scale: 12,
                            fillColor: "#B71C1C", // Blood Red Marker
                            fillOpacity: 1,
                            strokeWeight: 3,
                            strokeColor: "#ffffff"
                        }
                    });
                } else {
                    marker.setPosition(position);
                }
                
                map.panTo(position);

                // Takibe Başla butonu
                document.getElementById('startTrackingBtn').onclick = () => {
                    window.open(`https://www.google.com/maps/dir/?api=1&destination=${position.lat},${position.lng}`, '_blank');
                };
            }
        }
    });
}
