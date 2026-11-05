# IoMBian

![IoMBian builder](https://github.com/Tknika/iombian/workflows/IoMBian%20builder/badge.svg)

[Irakurri ingelesez](README_ENG.md)

> **[Tknika/iombian](https://github.com/Tknika/iombian) proiektuaren fork-a.** Jatorrizko proiektuaren,
> upstream argitalpenen eta IoMBian zerbitzuen estekak dokumentu honetan mantendu dira.
> Fork honek Raspberry Pi OS **Bookworm arm64** irudia eraikitzen du, Node-RED-eko
> menpekotasun eguneratuekin, Wi-Fi abio automatikoarekin eta lehenetsitako segurtasuna sendotuta.

## Sarrera

IoMBian (edo IoMBian OS) IoMBian proiektuaren sistema eragile nagusia da. Batez ere irakasleentzat eta hezkuntza-inguruneentzat garatu da, gailu txertatuetan (Raspberry Pi) IoM (Internet of Machines) eta IIoT (Industrial Internet of Things) sistemak errazago ezartzeko.

Sistema eragilearen hasierako konfigurazioa ahalik eta gehien sinplifikatu da Linux ez dakiten erabiltzaileentzat: lan egiteko hasieran ez da beharrezkoa plakara monitore bat konektatzea edo SSH bidez sartzea.

## Instalazioa

Banaketa Raspberry Pi OS-aren beste edozein bertsio bezala instalatzen da. Jarraitu urrats hauek:

- Deskargatu Etcher bere [webgunetik](https://www.balena.io/etcher/).
- Deskargatu IoMBian-en azken bertsioa (`.zip`) jatorrizko proiektuaren [Releases](https://github.com/Tknika/iombian/releases) ataletik.
- Sartu microSD txartela ordenagailuan.
- **Deskonprimatu ZIP fitxategia Balena Etcher erabili aurretik.**
- Abiarazi Etcher, hautatu deskonprimatutako `.img` irudia, ziurtatu microSD txartel zuzena aukeratu duzula eta sakatu **Flash**.
- Itxaron prozesua amaitu arte (< 5 minutu).

![Etcher - Flash](docs/etcher-flash.png)

Ondoren, konfigurazio-auker hauek dituzu:

- [**Gomendatua**] IoMBian Configurator — Bluetooth
  - Atera microSD txartela ordenagailutik eta sartu Raspberry Pi-n.
  - Piztu Raspberry Pi elikadura egoki batekin (5 V eta 2,5 A) eta itxaron 2 minutu (edo pantaila txikian QR kode bat agertu arte).
  - Eskaneatu QR kodea edo sartu [IoMBian Configurator](https://iombian-configurator.web.app/) webgunean Chrome erabiliz. Sortu kontu bat, gehitu gailu berri bat eta konfiguratu zure beharren arabera.
  - Sakatu **Sync** (Bluetooth) botoia, hautatu IoMBian gailua eta amaituta dago! :tada: Gailua berrabiaraziko da eta minutu batean prest egongo da.
- [**Gomendatua**] IoMBian Configurator — USB-C
  - Atera microSD txartela ordenagailutik eta sartu Raspberry Pi-n.
  - Konektatu Raspberry Pi ordenagailura USB-C kable batekin eta itxaron 2 minutu (edo pantaila txikian QR kode bat agertu arte).
  - Eskaneatu QR kodea edo sartu [IoMBian Configurator](https://iombian-configurator.web.app/) webgunean Chrome erabiliz. Sortu kontu bat, gehitu gailu berri bat eta konfiguratu zure beharren arabera.
  - Sakatu **Sync** (USB) botoia, hautatu IoMBian gailua eta amaituta dago! :tada: Gailua berrabiaraziko da eta minutu batean prest egongo da.
- **Eskuzko konfigurazioa**
  - Atera microSD txartela eta sartu berriro ordenagailuko txartel-irakurlean.
  - Ireki `boot` partizioa, sartu `config` karpetan eta editatu `parameters.yml` testu-editore batekin. Windows-en [Notepad++](https://notepad-plus-plus.org/) erabiltzea gomendatzen da.
  - Aldatu parametro hauek (informazio gehiago [iombian-confinit](https://github.com/Tknika/iombian-confinit) dokumentazioan):
    - `system/hostname`: ~~iombian~~ → `iombian-aiturrioz`
    - `user/password`: ~~iompi~~ → `zure_pasahitza`
    - `networking/wlan0/ssid`: `wifi_sarearen_izena`
    - `networking/wlan0/psk`: `wifi_sarearen_pasahitza`
    - `config_date`: gaurko data eta ordua `YYYY-MM-DDTHH:MM:SS` formatuan; adibidez, `2021-06-09T11:23:34`.
  - Atera microSD txartela eta sartu Raspberry Pi-n.
  - Piztu Raspberry Pi elikadura egoki batekin (5 V eta 2,5 A).
  - Itxaron 5 minutu eta gailua prest egongo da.

> **Oharra:** Raspberry Pi-n instalatutako zerbitzuak aurkitzeko, ikusi [IoMBian Discover](#iombian-discover) atala.

> **Kontuz:** IoMBian-eko zerbitzu guztiak pasahitz bidez babestuta daude lehenespenez. Erabiltzaile-izena `iompi` da, eta pasahitza `parameters.yml` fitxategian definitzen dena (`iompi` lehenespenez).

## Uneko irudiaren konfigurazioa

Fork honek **Raspberry Pi OS Lite Bookworm arm64** irudia eraikitzen du [pi-gen](https://github.com/RPi-Distro/pi-gen)-en Bookworm adarra erabiliz. Uneko lehenetsitako konfigurazioa hau da:

- Ostalari-izena: `iombian`; erabiltzailea: `iompi`; hasierako pasahitza: `iompi`.
- SSH lehen abiotik gaituta dago. Lehenetsitako pasahitza aldatu behar da SSH bidez edo kontsola lokaletik saioa hastean.
- Ordu-zona: `Europe/Madrid`; hizkuntza: `es_ES.UTF-8`; Wi-Fi herrialdea: `ES`.
- Ethernet-ek `192.168.0.10/24` helbide estatikoa erabiltzen du lehenespenez, ate lehenetsirik eta DNSik gabe. Wi-Fi-k DHCP erabiltzen du kredentzialak konfiguratu ondoren.
- Abio-konfigurazioa firmware partizioko `/boot/firmware/config` karpetan gordetzen da; `/boot/config` bateragarritasun-esteka gisa mantentzen da.
- `wpa_supplicant` eta `dhcpcd` zerbitzuek kudeatzen dute haririk gabeko sarea, NetworkManager-en ordez.
- WeTTY `127.0.0.1:3000` helbidean entzuten du, eta ez dago sareko interfaze guztietatik zuzenean eskuragarri.

> **Kontuz:** aldatu lehenetsitako `iompi` pasahitza gailua fidagarria ez den sare batean konektatu aurretik. Pasahitz berria `parameters.yml` fitxategian edo IoMBian Configurator bidez ezartzea gomendatzen da. Wi-Fi pasahitzak PSK hash bihurtzen dira konfigurazioan, eta sortutako Wi-Fi konfigurazioak baimen murriztuak ditu.

## Softwarea

IoMBian [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/) Bookworm arm64-n oinarrituta dago eta programa hauek ditu:

- [Node-RED](https://nodered.org/) **5.0.9**, Node.js **22.21.1** gainean: IBM-k jatorriz sortutako garapen bisualeko tresna, hardware-gailuen, API-en eta lineako zerbitzuen informazioa Internet of Things aplikazioetarako biltzeko.
- [Mosquitto](https://mosquitto.org/): Eclipse Foundation-ek garatutako MQTT zerbitzari zabalduna (broker-a).
- [MQTT Web Client](https://github.com/hivemq/hivemq-mqtt-web-client): erabiltzaileak (ikasleak) bere ordenagailuan ezer instalatu gabe lehen MQTT mezuak bidaltzeko web bezeroa. Aurretik instalatutako Mosquitto broker-arekin batera, protokoloarekin minutu gutxitan hasteko aukera ematen du.
- [Monit](https://mmonit.com/monit/): sistemaren egoera monitorizatzen duen eta zerbait espero bezala ez dabilenean erabiltzaileari posta elektroniko bidez jakinarazten dion programa.
- LED kontrolagailua: GPIO14 pinean konektatutako LED baten bidez Raspberry Pi piztuta dagoen jakiteko konfigurazioa.
- [Samba](https://www.samba.org/cifs/docs/what-is-smb.html): Raspberry Pi eta sare lokaleko ordenagailuen artean fitxategiak trukatzea errazten duen protokoloa. Lehenespenez `/data` karpeta bakarrik partekatzen da (karpetaren izena maiuskula/minuskula sentibera da).
- IoMBian zerbitzuak: [iombian-config-file-handler](https://github.com/Tknika/iombian-config-file-handler), [iombian-shutdown-handler](https://github.com/Tknika/iombian-shutdown-handler), [iombian-button-handler](https://github.com/Tknika/iombian-button-handler), [iombian-system-info-provider](https://github.com/Tknika/iombian-system-info-provider), [iombian-display-handler](https://github.com/Tknika/iombian-display-handler), [iombian-bluetooth-configurator](https://github.com/Tknika/iombian-bluetooth-configurator), [iombian-remote-configurator](https://github.com/Tknika/iombian-remote-configurator).
- [Confinit](https://github.com/jriguera/confinit): José Riguera-k (@jriguera) garatutako tresna, Raspberry Pi microSD txartelaren boot partizioan dagoen testu-fitxategi bakar batetik konfiguratzeko. IoMBian-erako [iombian-confinit](https://github.com/Tknika/iombian-confinit) konfigurazio berezia sortu da, eta zerbitzu hauek kudeatzen ditu:
  - `iompi` erabiltzailearen pasahitza (erabiltzaile-izena ezin da aldatu).
  - Ostalari-izena.
  - Hizkuntza eta lokala.
  - Ordu-zona.
  - Sarea (haririk gabeko sarearen parametroak eta interfaze bakoitzaren konfigurazioa: IPa, maskara, atea...).
  - Node-RED.
  - Mosquitto.
  - Monit.
  - Gehiago jakin nahi baduzu, ikusi [iombian-confinit](https://github.com/Tknika/iombian-confinit) dokumentazioa.

## IoMBian Discover

Banaketa hezkuntza-sektoreari zuzenduta dagoenez eta sare lokalean hamar gailu baino gehiago aldi berean konektatzea aurreikusten denez, gailu horiek aurkitzen laguntzeko mahaigaineko programa bat garatu da: [IoMBian Discover](https://github.com/Tknika/iombian-discover).

Tresna honen bidez, erabiltzaileak Raspberry Pi-n instalatutako zerbitzuak (Node-RED, adibidez) ireki ditzake IP helbidea edo zerbitzuaren ataka jakin beharrik gabe. Instalazio eta konfigurazio-prozesuari buruzko informazio gehiago eskuratzeko, bisitatu [programaren orria](https://github.com/Tknika/iombian-discover).

## Garapena

Sistema eragilea [pi-gen](https://github.com/RPi-Distro/pi-gen#config)-en oinarrituta dago eta lokalean edo GitHub Actions bidez eraiki daiteke:

- `master` adarrera egindako push batek `IoMBian builder` workflow-a abiarazten du, irudia balioztatzen du eta commit SHAren arabera izendatutako ZIP artifact bat igotzen du. Artifact-a **14 egunez** mantentzen da.
- Release bat argitaratzean `IoMBian publisher` workflow-a abiarazten da eta `iombian-<etiketa>.zip` fitxategia release-ari eransten dio. Jatorrizko proiektuaren argitalpenak [Tknika/iombian](https://github.com/Tknika/iombian/releases) estekan daude eskuragarri.

### Lokaleko eraikuntza

Instalatu Git, Docker eta `qemu-user-static`. Klonatu errepositorioa eta hasieratu submodule guztiak eraiki aurretik:

```bash
git clone https://github.com/Tknika/iombian.git
cd iombian
git submodule update --init --recursive
./build-iombian.sh
```

Fork hau erabiltzeko, ordezkatu klonatzeko URLa fork honen URLarekin. `build-iombian.sh` script-ak submodule-ak hasieratzen ditu, eraikuntzaren iraupenean `stage2`-ko tarteko irudiaren esportazioa desgaitzen du eta errepositorioko [config](config) fitxategiarekin Docker abiarazten du. Docker-ek edukiontzi pribilegiatuak exekutatu ahal izan behar ditu.

Emaitzeko ZIP fitxategia eta eraikuntza-logak `deploy/` karpetan geratzen dira. Eraikuntzak normalean **30–60 minutu** behar ditu, ostalariaren eta sarearen arabera.

CIren irudiaren offline egiaztapen berberak exekutatzeko (root baimenak, `unzip` eta loop gailuen euskarria behar dira):

```bash
sudo ./test-image.sh deploy/*.zip
```

## Egilea

(c) 2021 [Tknika](https://tknika.eus/) ([Aitor Iturrioz](https://github.com/bodiroga))

Apache License, Version 2.0 lizentziapean banatua ("License");
fitxategi hau lizentziaren baldintzak betez soilik erabil dezakezu.
Lizentziaren kopia eskuratu dezakezu hemen:

    http://www.apache.org/licenses/LICENSE-2.0

Legeak eskatzen duen kasuan edo idatziz adostutako kasuetan izan ezik,
softwarea "AS IS" moduan banatzen da, inolako bermerik edo baldintzarik gabe,
adierazita zein isilean. Lizentziaren baimen eta mugak zehatzak jakiteko,
ikusi lizentziaren testu osoa.
