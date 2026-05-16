import { ENV } from './env.js';

const app = window.initializeApp(ENV.FIREBASE);
const db = window.getFirestore(app);

const mapScript = document.createElement('script');
mapScript.src = `https://maps.googleapis.com/maps/api/js?key=${ENV.GOOGLE_MAPS_API_KEY}&libraries=geometry&callback=initMap`;
mapScript.async = true;
mapScript.defer = true;
document.head.appendChild(mapScript);

let map;
let marker; 
let accuracyCircle;
let directionsService;
let directionsRenderer;
let lastSeen = Date.now();
let trafficLayer;
let victimPos = null;
let rescuerPos = null;
let lastCalculatedRescuerPos = null;
let isAutoFollowActive = false;
let userHasInteracted = false;
let isSessionEnded = false;
let isTrackingActive = false;
let lastRouteCalcTime = 0;
let offRoadLine;
let rescuerMarker;

let isFirstLoad = true;
let currentVoiceId = "tr-TR-Wavenet-C";
let isTtsEnabled = true;

async function speak(text) {
    if (!isTtsEnabled || !text || !userHasInteracted) return;
    try {
        const response = await fetch(`https://texttospeech.googleapis.com/v1/text:synthesize?key=${ENV.GOOGLE_MAPS_API_KEY}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                input: { text: text },
                voice: { languageCode: 'tr-TR', name: currentVoiceId },
                audioConfig: { audioEncoding: 'MP3', speakingRate: 1.05 }
            })
        });
        if (response.ok) {
            const data = await response.json();
            const audio = new Audio("data:audio/mp3;base64," + data.audioContent);
            audio.play();
        }
    } catch(e) {}
}

let PulseMarker;
const googleMapsDarkTheme = [ { elementType: "geometry", stylers: [{ color: "#242f3e" }] }, { elementType: "labels.text.stroke", stylers: [{ color: "#242f3e" }] }, { elementType: "labels.text.fill", stylers: [{ color: "#746855" }] }, { featureType: "water", elementType: "geometry", stylers: [{ color: "#17263c" }] } ];

window.initMap = function() {
    PulseMarker = class extends google.maps.OverlayView {
        constructor(position, map, photoUrl) {
            super();
            this.position = position;
            this.photoUrl = photoUrl;
            this.div = null;
            this.setMap(map);
        }
        onAdd() {
            this.div = document.createElement('div');
            this.div.className = 'pulse-marker';
            this.div.style.position = 'absolute';
            this.updateContent();
            const panes = this.getPanes();
            panes.overlayImage.appendChild(this.div);
        }
        updateContent() {
            if (this.photoUrl) {
                this.div.innerHTML = `<img src="${this.photoUrl}" onerror="this.style.display='none'">`;
            } else {
                this.div.innerHTML = '';
            }
        }
        draw() {
            if (!this.div) return;
            const projection = this.getProjection();
            const point = projection.fromLatLngToDivPixel(this.position);
            if (point) {
                this.div.style.left = (point.x - 13) + 'px';
                this.div.style.top = (point.y - 13) + 'px';
            }
        }
        onRemove() {
            if (this.div) { this.div.parentNode.removeChild(this.div); this.div = null; }
        }
        setPosition(position) {
            this.position = position;
            this.draw();
        }
        setPhoto(url) {
            this.photoUrl = url;
            if (this.div) this.updateContent();
        }
    };

    class RescuerMarkerOverlay extends google.maps.OverlayView {
        constructor(position, map, mode) {
            super();
            this.position = position;
            this.mode = mode;
            this.div = null;
            this.setMap(map);
        }
        onAdd() {
            this.div = document.createElement('div');
            this.div.className = 'rescuer-marker';
            this.div.style.position = 'absolute';
            this.updateContent();
            this.getPanes().overlayImage.appendChild(this.div);
        }
        updateContent() {
            const iconClass = this.mode === 'DRIVING' ? 'fa-car-side' : 'fa-walking';
            this.div.innerHTML = `<i class="fas ${iconClass}"></i>`;
        }
        draw() {
            if (!this.div) return;
            const projection = this.getProjection();
            if (!projection) return;
            const point = projection.fromLatLngToDivPixel(this.position);
            if (point) {
                this.div.style.left = (point.x - 15) + 'px';
                this.div.style.top = (point.y - 15) + 'px';
            }
        }
        update(pos, mode) {
            this.position = pos;
            this.mode = mode;
            if (this.div) this.updateContent();
            this.draw();
        }
    }
    map = new google.maps.Map(document.getElementById("map"), {
        zoom: 16,
        center: { lat: 39.92, lng: 32.85 },
        disableDefaultUI: true,
        mapTypeId: 'roadmap',
        styles: googleMapsDarkTheme
    });

    directionsService = new google.maps.DirectionsService();
    directionsRenderer = new google.maps.DirectionsRenderer({ 
        map: map, 
        suppressMarkers: true,
        preserveViewport: true,
        polylineOptions: { strokeColor: "#dc2626", strokeWeight: 6 }
    });
    trafficLayer = new google.maps.TrafficLayer();

    if (navigator.geolocation) {
        navigator.geolocation.watchPosition((pos) => {
            rescuerPos = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
            if (isTrackingActive) {
                if (!rescuerMarker) {
                    if (typeof RescuerMarkerOverlay !== 'undefined') {
                        rescuerMarker = new RescuerMarkerOverlay(rescuerPos, map, currentTravelMode);
                    }
                } else {
                    rescuerMarker.update(rescuerPos, currentTravelMode);
                }
                autoUpdateRoute();
            } else if (rescuerMarker) {
                rescuerMarker.setMap(null);
                rescuerMarker = null;
            }
        }, (err) => {
            console.error(err);
        }, { enableHighAccuracy: true, maximumAge: 0, timeout: 10000 });
    }

    document.getElementById('fabMapType').onclick = () => {
        const current = map.getMapTypeId();
        map.setMapTypeId(current === 'roadmap' ? 'satellite' : 'roadmap');
    };
    document.getElementById('fabTraffic').onclick = () => {
        if (trafficLayer.getMap()) trafficLayer.setMap(null);
        else trafficLayer.setMap(map);
    };
    document.getElementById('fabCenter').onclick = () => {
        if (victimPos) map.panTo(victimPos);
    };
    document.getElementById('fabVoice').onclick = () => {
        document.getElementById('voiceModal').classList.add('active');
    };
    document.getElementById('closeVoiceModal').onclick = () => {
        userHasInteracted = true;
        document.getElementById('voiceModal').classList.remove('active');
        const selected = document.querySelector('input[name="voiceSelect"]:checked').value;
        if (selected === 'off') {
            isTtsEnabled = false;
        } else {
            isTtsEnabled = true;
            currentVoiceId = selected;
            speak("Ses asistanı değiştirildi.");
        }
    };
};

let currentTravelMode = 'DRIVING';

async function autoUpdateRoute(force = false) {
    const now = Date.now();
    if (!victimPos || !rescuerPos) return;

    if (!force) {
        if (lastCalculatedRescuerPos && window.google && google.maps.geometry) {
            const dist = google.maps.geometry.spherical.computeDistanceBetween(rescuerPos, lastCalculatedRescuerPos);
            if (dist < 20 && (now - lastRouteCalcTime < 30000)) return;
        }
        if (now - lastRouteCalcTime < 10000) return;
    }

    directionsService.route({
        origin: rescuerPos,
        destination: victimPos,
        travelMode: google.maps.TravelMode[currentTravelMode]
    }, (response, status) => {
        if (status === 'OK') {
            directionsRenderer.setDirections(response);
            lastRouteCalcTime = now;
            lastCalculatedRescuerPos = rescuerPos;

            const leg = response.routes[0].legs[0];
            document.getElementById('metricValue').innerText = leg.duration.text;
            document.getElementById('metricDistance').innerText = leg.distance.text;

            const route = response.routes[0].legs[0];
            const lastPoint = route.steps[route.steps.length - 1].end_location;
            if (offRoadLine) offRoadLine.setMap(null);
            offRoadLine = new google.maps.Polyline({
                path: [lastPoint, victimPos],
                strokeColor: "#dc2626",
                strokeOpacity: 0,
                icons: [{
                    icon: { path: 'M 0,-1 0,1', strokeOpacity: 1, scale: 3, strokeWeight: 4 },
                    offset: '0',
                    repeat: '15px'
                }],
                map: map
            });
        }
    });
}

function setTravelMode(mode) {
    currentTravelMode = mode;
    document.getElementById('btnDriving').classList.toggle('active', mode === 'DRIVING');
    document.getElementById('btnWalking').classList.toggle('active', mode === 'WALKING');
    if (rescuerMarker && rescuerPos) rescuerMarker.update(rescuerPos, mode);
    autoUpdateRoute(true); 
}

document.getElementById('btnDriving').onclick = () => setTravelMode('DRIVING');
document.getElementById('btnWalking').onclick = () => setTravelMode('WALKING');

const params = new URLSearchParams(window.location.search || window.location.hash.substring(1));
const sessionId = params.get('id') || "TEST_SESSION";
const rawKey = (params.get('key') || "").replace(/ /g, '+');
const rawIv = (params.get('iv') || "").replace(/ /g, '+');

function decryptData(encryptedBase64, dbIv) {
    try {
        const key = CryptoJS.enc.Base64.parse(rawKey);
        const iv = CryptoJS.enc.Base64.parse(dbIv || rawIv); 
        const cipherParams = CryptoJS.lib.CipherParams.create({ ciphertext: CryptoJS.enc.Base64.parse(encryptedBase64) });
        const decrypted = CryptoJS.AES.decrypt(cipherParams, key, { iv: iv, mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7 });
        const decryptedStr = decrypted.toString(CryptoJS.enc.Utf8);
        return JSON.parse(decryptedStr);
    } catch (e) { return null; }
}

if (rawKey) {
    window.onSnapshot(window.doc(db, "active_sos", sessionId), (docSnap) => {
        if (docSnap.exists()) {
            const data = docSnap.data();
            if(data.status === "KULLANICI_SONLANDIRDI" || data.status === "CANCELLED") {
                isSessionEnded = true;
                const banner = document.getElementById('statusBanner');
                banner.style.background = "#2d3436";
                document.getElementById('statusText').innerHTML = '<i class="fas fa-check-circle"></i> BAĞLANTI KULLANICI TARAFINDAN GÜVENLİ ŞEKİLDE SONLANDIRILDI';
                document.getElementById('loadingIcon').style.display = "none";
                
                document.querySelector('.bottom-container').style.display = 'none';
                document.querySelector('.fab-container').style.display = 'none';
                if (directionsRenderer) directionsRenderer.setMap(null);
                if (accuracyCircle) accuracyCircle.setMap(null);
                
                showFinalOverlay();
                isTrackingActive = false;
                return;
            }
            const realData = decryptData(data.payload, data.iv);
            if (realData) {
                lastSeen = Date.now();
                const isLowSignal = realData.status === 'LOW_SIGNAL';
                document.getElementById('statusBanner').style.background = isLowSignal ? "orange" : "var(--blood-gradient)";
                document.getElementById('statusText').innerText = isLowSignal ? "Zayıf Sinyal - Konum Tahminidir" : "Kullanıcının konumu anlık olarak izleniyor";
                document.getElementById('loadingIcon').style.display = "none";
                document.getElementById('victimName').innerText = realData.userName || realData.name || "Bilinmiyor";
                document.getElementById('victimPhone').innerText = (realData.userPhone || realData.phone || "Telefon Yok").replace('+90', '+90 ');
                document.getElementById('victimBattery').innerText = realData.battery || "%--";
                
                let timeString = "--:--";
                if (data.timestamp) {
                    const date = data.timestamp.toDate ? data.timestamp.toDate() : (data.timestamp.seconds ? new Date(data.timestamp.seconds * 1000) : new Date(data.timestamp));
                    timeString = date.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
                }
                document.getElementById('lastUpdated').innerText = `Son Güncelleme: ${timeString}`;
                document.getElementById('victimTime').innerText = timeString;

                const position = new google.maps.LatLng(parseFloat(realData.lat), parseFloat(realData.lng));
                document.getElementById('victimCoordinates').innerText = `${position.lat().toFixed(5)}, ${position.lng().toFixed(5)}`;

                if (!accuracyCircle) {
                    accuracyCircle = new google.maps.Circle({
                        strokeColor: "#FF0000",
                        strokeOpacity: 0.3,
                        strokeWeight: 1,
                        fillColor: "#FF0000",
                        fillOpacity: 0.1,
                        map: map,
                        center: position,
                        radius: parseFloat(realData.accuracy) || 0
                    });
                } else {
                    accuracyCircle.setCenter(position);
                    accuracyCircle.setRadius(parseFloat(realData.accuracy) || 0);
                    accuracyCircle.setMap(map);
                }
                
                victimPos = position;
                if (!marker) {
                    marker = new PulseMarker(position, map, realData.userPhoto || realData.photoUrl);
                    map.setCenter(position);
                    map.setZoom(18);
                    isFirstLoad = false;
                    speak("Acil durum sinyali alındı.");
                } else {
                    marker.setPosition(position);
                    marker.setPhoto(realData.userPhoto || realData.photoUrl);
                    if (isFirstLoad) { map.panTo(position); isFirstLoad = false; }
                }
                if (isTrackingActive) {
                    autoUpdateRoute();
                    if (isAutoFollowActive) map.panTo(victimPos);
                }
            }
        }
    });
}

document.getElementById('startTrackingBtn').onclick = function() {
    userHasInteracted = true;
    isTrackingActive = true;
    isAutoFollowActive = true;
    document.querySelector('.info-card').classList.add('tracking-active');
    if (rescuerPos && !rescuerMarker && typeof RescuerMarkerOverlay !== 'undefined') {
        rescuerMarker = new RescuerMarkerOverlay(rescuerPos, map, currentTravelMode);
    }
    if (victimPos) { 
        map.setZoom(18); 
        map.panTo(victimPos); 
        if (window.innerWidth < 768) {
            map.panBy(0, 180);
        } else {
            map.panBy(-150, 0);
        }
    }
    autoUpdateRoute();
    speak("Canlı takip ve navigasyon başlatıldı.");
    this.innerHTML = 'Takip Ediliyor <i class="fas fa-crosshairs fa-spin"></i>';
};

setInterval(() => {
    if (isSessionEnded) return;
    if (Date.now() - lastSeen > 125000) {
        document.getElementById('statusText').innerText = "Bağlantı Koptu - Sinyal Bekleniyor";
        document.getElementById('statusBanner').style.background = "orange";
    }
}, 10000);

function showFinalOverlay() {
    if (document.querySelector('.final-overlay')) return;
    const overlay = document.createElement('div');
    overlay.className = 'final-overlay';
    overlay.innerHTML = `
        <div class="final-box">
            <div class="icon-circle">
                <i class="fas fa-shield-alt" style="font-size: 50px; color: #2ecc71;"></i>
            </div>
            <h2 style="margin: 20px 0 10px; color: #2d3436; font-weight: 800;">Operasyon Tamamlandı</h2>
            <p style="color: #636e72; line-height: 1.6; font-weight: 500;">Kullanıcı durumu kontrol altına aldı ve canlı takibi güvenli şekilde sonlandırdı.</p>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; display: flex; align-items: center; justify-content: center; gap: 10px;">
                <span style="font-weight: 900; color: #b71c1c; font-size: 14px; letter-spacing: -0.5px;">HAYATELİ</span>
                <span style="color: #999; font-size: 12px; font-weight: 600;">Güvenlik Protokolü</span>
            </div>
        </div>
    `;
    document.body.appendChild(overlay);
}

document.getElementById('hideInfoBtn').addEventListener('click', () => {
    document.getElementById('victimInfoSection').classList.add('hidden');
    document.querySelector('.info-card').classList.add('minimized');
    document.getElementById('fabShowInfo').style.display = 'flex';
});

document.getElementById('fabShowInfo').addEventListener('click', () => {
    document.getElementById('victimInfoSection').classList.remove('hidden');
    document.querySelector('.info-card').classList.remove('minimized');
    document.getElementById('fabShowInfo').style.display = 'none';
});
