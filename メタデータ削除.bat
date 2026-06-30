@echo off
setlocal
set "FOL=%~dp0"
set "FOL=%FOL:~0,-1%"
set "TMPPS=%TEMP%\metaclean%RANDOM%.ps1"

(
echo param^($folder^)
echo $folder = $folder.TrimEnd('\'^)
echo $pngs = Get-ChildItem -Path $folder -Filter '*.png' ^| Where-Object { $_.Name -notlike '__tmp_*' } ^| Sort-Object Name
echo if ^($pngs.Count -eq 0^) { Write-Host 'PNG not found.' -ForegroundColor Yellow; exit }
echo Write-Host "folder: $folder"
echo Add-Type -AssemblyName System.Drawing
echo $i = 1
echo foreach ^($file in $pngs^) {
echo     $tmp = Join-Path $folder ^('__tmp_' + $i + '.png'^)
echo     $src = [System.Drawing.Bitmap]::FromFile^($file.FullName^)
echo     $dst = New-Object System.Drawing.Bitmap^($src.Width, $src.Height, $src.PixelFormat^)
echo     $g = [System.Drawing.Graphics]::FromImage^($dst^)
echo     $g.DrawImage^($src, 0, 0, $src.Width, $src.Height^)
echo     $g.Dispose^(^); $src.Dispose^(^)
echo     $dst.Save^($tmp, [System.Drawing.Imaging.ImageFormat]::Png^)
echo     $dst.Dispose^(^)
echo     Write-Host ^('done: ' + $file.Name^)
echo     $i++
echo }
echo foreach ^($file in $pngs^) { Remove-Item $file.FullName -Force }
echo $tmps = Get-ChildItem -Path $folder -Filter '__tmp_*.png' ^| Sort-Object { [int]^($_.BaseName -replace '__tmp_', ''^) }
echo $i = 1
echo foreach ^($t in $tmps^) {
echo     $newName = Join-Path $folder ^($i.ToString^(^) + '.png'^)
echo     Rename-Item $t.FullName $newName
echo     Write-Host ^('rename: ' + $i + '.png'^) -ForegroundColor Cyan
echo     $i++
echo }
echo Write-Host ^('complete: ' + ^($i-1^) + ' files'^) -ForegroundColor Green
) > "%TMPPS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -folder "%FOL%"
del "%TMPPS%" 2>nul
pause
