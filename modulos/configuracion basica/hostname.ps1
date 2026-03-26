Write-Host "=========HOSTNAME========="

# A continuación se muestra el nombre actual del equipo

$Nombre_actual= $env:COMPUTERNAME

Write-Host "El nombre actual de su equipo es $Nombre_actual"

#Peticion renombre del equipo, con bucle por si no cumple los parametros

while($true){

$Nombre_nuevo= Read-Host "Introduzca el nuevo nombre de su equipo,tenga en cuenta que no debe de contener espacios u dejarse en blanco"
 
#Comprobacion de nombre correcto 

    #Nombre en blanco

if ([string]::IsNullOrWhiteSpace($Nombre_nuevo))
    {Write-Host "ERROR: Recuerde,no puede dejar el campo en blanco"
    continue
}

    #Nuevo nombre no es igual al anterior

if ($Nombre_nuevo -eq $Nombre_actual) {
    Write-Host "El nuevo nombre, no puede ser igual al anterior"
    continue
}

    #Comprobacion de los caracteres utilizados

if ($Nombre_nuevo -notmatch '^[a-zA-Z0-9_-]+$') {
    Write-host "ERROR: El nuevo nombre solo puede contener letras, números, y guiones"
    continue
}

if ($Nombre_nuevo.Length -gt 10) {
    Write-Host "ADVERTENCIA: El nombre del equipo supera los 10 caracteres, esto puede suponer un problema en el futuro en el trabajo diario,"

    do{
        $Confirmacion = Read-Host "¿Quiere continuar? (s/n)"

        if ($Confirmacion -notmatch "^[sn]$"){
        Write-Host "Debe introducir los caracteres 's' o 'n'"
     }
        } while ($Confirmacion -notmatch "^[sn]$")

    if ($Confirmacion -ne "s") {
            Write-Host "Vale, introduce otro hostname."
            continue
    }
}

#Una vez pasa aquí, significa que el nombre es valido, por lo que comienza el cambio

Write-Host "Cambiando nombre del equipo a $Nombre_nuevo"

Rename-Computer -NewName $Nombre_nuevo -Force

#Se pregunta al usuario si quiere reiniciar el ordenador

do{

$reinicio = Read-Host "Para efectuar el cambio, se requiere reiniciar, ¿quiere reiniciar ahora? (s/n)" 

if ($reinicio -notmatch "^[sn]$"){
     Write-Host "Debe introducir los caracteres 's' o 'n'"
    }
    
}while ($reinicio -notmatch "^[sn]$")

if ($reinicio -eq "s") {
    Restart-Computer
} else {
    Write-Host "El cambio se aplicará cuando el ordenador se reinicie"
}



break


