# 加载子配置文件
$ConfDir = Split-Path $PROFILE
. "$ConfDir/conf.d/init.ps1"
. "$ConfDir/conf.d/envars.ps1"
. "$ConfDir/conf.d/functions.ps1"
. "$ConfDir/conf.d/aliases.ps1"