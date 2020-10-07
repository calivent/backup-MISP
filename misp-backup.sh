#@calivent BashAddShebang
#/!bin/sh
## $Id: misp-backup.sh 07.10.2020 $
##
## script para hacer una copia de seguridad de MISP en debian/ubuntu 16.04.1
##
## Coautor  calivent@gmail.com
## https://github.com/calivent
##

##
## Este script se puede utilizar para hacer una copia de seguridad de un MISP completo
## DB y config para restaurar en un MISP reciente
## sistema construido. Esto no pretende ser un script de actualización.
## para moverse entre las versiones de MISP - Pero podría funcionar;).
##
## Probado contra MISP v2.4.132
##
## Ejecute el script como usuario estándar con el siguiente comando
##
## cp misp-backup.conf.ejemplo misp-backup.conf
## vi misp-backup.conf # ajustar valores
## sudo sh -x misp-backup.sh 2> & 1 | tee misp-backup.log
##
## Es hora de establecer algunas variables
##


FILE=./misp-backup.conf

# Source configuration file
if [ -f $FILE ];
then
   echo "archivo de conf $FILE existe."
   . $FILE
else
        echo "Config File $FILE does not exist. Please enter values manually"
        ## MySQL 
        echo 'Ingrese el nombre de usuario de su cuenta raíz de MySQL'
        read MySQLRUser
        echo 'Ingrese la contraseña de su cuenta raíz de MySQL'
        read MySQLRPass
        echo '¿Cómo le gustaría llamar al archivo de respaldo??'
        echo 'Eg. MISPBackup'
        read OutputFileName
        echo '¿Dónde le gustaría guardar el archivo??'
        echo 'Eg. /tmp'
        read OutputDirName
fi


# 

# Rutas MISP
MISPPath=$(locate MISP/app/webroot/index.php|sed 's/\/app\/webroot\/index\.php//')
# database.php
MySQLUUser=$(grep -o -P "(?<='login' => ').*(?=')" $MISPPath/app/Config/database.php)
MySQLUPass=$(grep -o -P "(?<='password' => ').*(?=')" $MISPPath/app/Config/database.php)
MISPDB=$(grep -o -P "(?<='database' => ').*(?=')" $MISPPath/app/Config/database.php)
DB_Port=$(grep -o -P "(?<='port' => ).*(?=,)" $MISPPath/app/Config/database.php)
MISPDBHost=$(grep -o -P "(?<='host' => ').*(?=')" $MISPPath/app/Config/database.php)
# config.php
Salt=$(grep -o -P "(?<='salt' => ').*(?=')" $MISPPath/app/Config/config.php)
BaseURL=$(grep -o -P "(?<='baseurl' => ').*(?=')" $MISPPath/app/Config/config.php)
OrgName=$(grep -o -P "(?<='org' => ').*(?=')" $MISPPath/app/Config/config.php)
LogEmail=$(grep -o -P "(?<='email' => ').*(?=')" $MISPPath/app/Config/config.php|head -1)
AdminEmail=$(grep -o -P "(?<='contact' => ').*(?=')" $MISPPath/app/Config/config.php)
GnuPGEmail=$(sed -n -e '/GnuPG/,$p' $MISPPath/app/Config/config.php|grep -o -P "(?<='email' => ').*(?=')")
GnuPGHomeDir=$(grep -o -P "(?<='homedir' => ').*(?=')" $MISPPath/app/Config/config.php)
GnuPGPass=$(grep -o -P "(?<='password' => ').*(?=')" $MISPPath/app/Config/config.php)
# creando backup
TmpDir="$(mktemp -d)"


echo "copia de imágenes y otras personalizadas"
cp -r $MISPPath/app/webroot/img/orgs $TmpDir/
cp -r $MISPPath/app/webroot/img/custom $TmpDir/
cp -r $MISPPath/app/files $TmpDir

cp -r $MISPPath/app/Config $TmpDir
cp -r $MISPPath/.gnupg $TmpDir


mkdir $TmpDir/ServConf
mkdir $TmpDir/ServConf/sites
mkdir $TmpDir/Apache2
cp -r $GnuPGHomeDir/* $TmpDir/ServConf/
cp -r /etc/apache2/sites-available/* $TmpDir/ServConf/sites/
cp -r /etc/php/7.0/apache2/* $TmpDir/Apache2/
cp -r /etc/ssl/private/* $TmpDir/ServConf/

echo "MySQL Dump"
mysqldump --opt -u $MySQLRUser -p$MySQLRPass $MISPDB > $TmpDir/MISPbackupfile.sql
# comprimir archivo temp -zcvf
tar -zcf $OutputDirName/$OutputFileName-$(date "+%b_%d_%Y_%H_%M_%S").tar.gz $TmpDir

rm -rf $TmpDir
echo $GnuPGHomeDir
echo 'Bakcup MISP completado!!!'
