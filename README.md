Script shell para hacer una copia de seguridad de MISP (ACTUALIZADO)

Necesita instalar localizar en su sistema:
```
sudo apt-get install locate
```



Instalación
============

Modificar archivo de configuración:
```
cp misp-backup.conf.ejemplo misp-backup.conf
sudo cat /var/www/MISP/app/Config/database.php | grep password
#ajustar valores
vi misp-backup.conf
```

Ejecutar
=======

ejecutar el script:
```
sh misp-backup.sh
```

copia de seguridad
====

```
- archivos de muestra
* certificados de servidor para conexiones de sincronización
* cerificados ssl
* Base de datos
* configuración de apache y php
* logotipos de organizaciones (aunque esto no es tan importante, pero sigue siendo molesto perderlos)
```

@github/calivent
