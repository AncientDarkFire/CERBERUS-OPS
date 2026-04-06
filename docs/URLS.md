# URLS.md
## URLs de Descarga - CERBERUS OPS

---

## 📦 INSTALACIÓN

```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install.lua install.lua
install
```

---

## 🔗 ARCHIVOS INDIVIDUALES

### Boot y Core

| Archivo | URL |
|---------|-----|
| init.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/init.lua` |
| logger.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/core/logger.lua` |
| crypto.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/core/crypto.lua` |
| network.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/core/network.lua` |

### Presidential

| Archivo | URL |
|---------|-----|
| sentinel_hud.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/presidential/sentinel_hud.lua` |
| nuclear_control.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/presidential/nuclear_control.lua` |
| secure_msg.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/presidential/secure_msg.lua` |
| secure_docs.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/presidential/secure_docs.lua` |

### Templates

| Archivo | URL |
|---------|-----|
| ui.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/lib/ui.lua` |
| system.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/config/system.lua` |

---

## 📋 INSTALACIÓN MANUAL

```bash
# Crear estructura
mkdir /cerberus/core
mkdir /cerberus/lib
mkdir /cerberus/presidential
mkdir /cerberus/config

# Descargar archivos
wget <URL> <DESTINO>
```

### Ejemplo:
```bash
mkdir /cerberus/core
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/core/logger.lua /cerberus/core/logger.lua
```

---

## ⚠️ CONFIGURAR REPOSITORIO

Para usar tu propio repositorio, cambia `AncientDarkFire` por tu usuario en las URLs.

---

*Última actualización: 2026-04-06*
