# URLS.md
## URLs de Descarga - CERBERUS OPS

---

## INSTALACION RECOMENDADA

```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install.lua install.lua
install
```

Esto copia todo el sistema a un floppy disk.

---

## URLS DE ARCHIVOS INDIVIDUALES

### Boot

| Archivo | URL |
|---------|-----|
| init.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/init.lua` |
| autorun.lua | `https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/autorun.lua` |

### Core

| Archivo | URL |
|---------|-----|
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

## CONFIGURAR PROPIO REPOSITORIO

Para usar tu propio repositorio, cambia `AncientDarkFire` por tu usuario en las URLs.

En install.lua, cambia:
```lua
BASE_URL = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/cerberus"
```

---

*Ultima actualizacion: 2026-04-06*
