Add-Type -AssemblyName System.Drawing

$root   = Join-Path $PSScriptRoot "..\images" | Resolve-Path
$thumbs = Join-Path $root "thumbs"
if (-not (Test-Path $thumbs)) { New-Item -ItemType Directory -Path $thumbs | Out-Null }

$rotateList = @{ 'cert-sih-2023.jpeg' = $true }

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
             Where-Object { $_.MimeType -eq 'image/jpeg' }

function Save-Jpeg($bmp, $path, $quality) {
    $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [int64]$quality)
    $bmp.Save($path, $jpegCodec, $ep)
    $ep.Dispose()
}

function Resize-Image($srcPath, $dstPath, $maxW, $quality, $rotate) {
    $src = [System.Drawing.Image]::FromFile($srcPath)
    if ($rotate) { $src.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }

    $scale = [Math]::Min(1.0, $maxW / $src.Width)
    $w = [int]($src.Width  * $scale)
    $h = [int]($src.Height * $scale)

    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.DrawImage($src, 0, 0, $w, $h)

    Save-Jpeg $bmp $dstPath $quality

    $g.Dispose(); $bmp.Dispose(); $src.Dispose()
    return @{ W = $w; H = $h }
}

Write-Output "file,orig_KB,thumb_KB,thumb_dims"

Get-ChildItem $root -File | Where-Object { $_.Name -like 'cert-*' } | ForEach-Object {
    $needsRotate = $rotateList.ContainsKey($_.Name)
    $outName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + ".jpg"

    $fullOut = Join-Path $root ("full-" + $outName)
    Resize-Image $_.FullName $fullOut 1600 82 $needsRotate | Out-Null

    $thumbOut = Join-Path $thumbs $outName
    $d = Resize-Image $_.FullName $thumbOut 720 76 $needsRotate

    $tKB = [math]::Round((Get-Item $thumbOut).Length / 1KB)
    $oKB = [math]::Round($_.Length / 1KB)
    Write-Output "$($_.Name),$oKB,$tKB,$($d.W)x$($d.H)"
}

$faviconSrc = Join-Path $root "favicon.png"
if (Test-Path $faviconSrc) {
    $src = [System.Drawing.Image]::FromFile($faviconSrc)
    $bmp = New-Object System.Drawing.Bitmap(64, 64)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, 0, 0, 64, 64)
    $bmp.Save((Join-Path $root "favicon-64.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose(); $src.Dispose()
    Write-Output "favicon.png,-,$([math]::Round((Get-Item (Join-Path $root 'favicon-64.png')).Length/1KB)),64x64"
}

$profileSrc = Join-Path $root "profile.jpg"
if (Test-Path $profileSrc) {
    $p = Resize-Image $profileSrc (Join-Path $thumbs "profile.jpg") 640 82 $false
    Write-Output "profile.jpg,-,$([math]::Round((Get-Item (Join-Path $thumbs 'profile.jpg')).Length/1KB)),$($p.W)x$($p.H)"
}
