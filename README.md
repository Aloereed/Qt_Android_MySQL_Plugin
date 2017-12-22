# Plugin MySQL per Qt Android

## Configurazione ambiente di sviluppo Qt Android su Linux (64bit)
**N.B:** tutti i seguenti comandi da terminale devono essere preceduti da `sudo` per ottenere i permessi da amministratore.

* Installazione pacchetti essenziali:
```
apt-get update
apt-get upgrade
apt-get install build-essential libgl1-mesa-dev cmake perl openssh-server git
```

* Fix UMake per installazione rapida di Android Studio:
```
add-apt-repository ppa:lyzardking/ubuntu-make
apt-get update
apt-get install ubuntu-make
```

* Installazione Android Studio: `umake android`
* Avvio Android Studio e installo l'SDK **r21** (Importante: si installa questa perchè è l'ultima a cui l'NDK r10e arriva)
* Download dell'NDK **r10e** dal sito di Android, necessario a Qt, e lo scompatto in cartella SDK

* Download Qt-Online-Installer dal sito di Qt e lo installo (per dargli i permessi di esecuzione `chmod +x`)

```
Pacchetti necessari:
* 5.9.3 Android ARMv7
* 5.9.3 Sources
* 5.9.3 Desktop gcc 64-bit
```

* Configurare Qt Creator inserendo nella sezione Android i path per l'SDK e l'NDK r10e



## Building Plugin QtSQL MySQL per Android

Repository originale per script plugin MySQL per Android: https://bitbucket.org/aykutozdemir/mysql_driver_qt/

Repository di backup di Ruscelli Fabio: https://github.com/fabiorush92/Qt_Android_MySQL_Plugin

* Modificare nel file bash `build_qt_mysql_driver.sh` i riferimenti alle cartelle di Qt e all'NDK

* Clonare la repository:

`git clone <plugin_repo>`

`cd <plugin_repo>`

* Dare i permessi di esecuzione allo script e avviarlo:

`sudo chmod +x build_qt_mysql_driver.sh`

`./build_qt_mysql_driver.sh`

Se il building terminerà con successo il driver QSqlMySQL verrà già copiato nei binari di Qt (Android ARMv7).

**N.B:** Ricorda di aggiungere alle dipendenze del progetto Qt Android la libreria libmariadb.so, appena buildata e contenuta in:
`<NDK_r10e>/platforms/android-21/arch-arm/usr/lib/mariadb`
