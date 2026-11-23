# ==========================================================
#  小豆豆的游戏广场 · 游戏封面自动截图
#  用本机 Chrome / Edge 的无头模式，逐个打开游戏页面并截图，
#  输出到 assets\covers\ ，游戏广场页面会自动使用这些封面。
#
#  用法：双击 tools\make-covers.cmd
#  或者在 PowerShell 里：
#    .\tools\make-covers.ps1
#    .\tools\make-covers.ps1 -Width 1280 -Height 720 -WaitMs 7000
#
#  新增游戏：把游戏 html 放进项目根目录，然后在下面 $Games
#  名单里加一行（File 写文件名，Slug 写封面图名，Crop 可留 $null）。
# ==========================================================
param(
  [int]$Width  = 1280,
  [int]$Height = 720,
  [int]$WaitMs = 6000,
  [string]$OutDir = "assets\covers"
)

$Root    = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$OutPath = Join-Path $Root $OutDir

# ---- 游戏名单：File=游戏文件，Slug=封面文件名（不含后缀），Crop=可选裁剪 @(X,Y,W,H) ----
$Games = @(
  [pscustomobject]@{ File = "小豆闯关记.html";       Slug = "xiaodou";  Crop = $null },
  [pscustomobject]@{ File = "火柴人勇闯恶魔岛.html"; Slug = "stickman"; Crop = $null },
  [pscustomobject]@{ File = "植物大战僵尸.html";     Slug = "pvz";      Crop = @(81, 0, 1118, 720) }
)

function Find-Browser {
  $cands = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
  )
  foreach ($c in $cands) { if (Test-Path -LiteralPath $c) { return $c } }
  return $null
}

Write-Host ""
Write-Host " 小豆豆的游戏广场 · 封面自动截图" -ForegroundColor Green
Write-Host (" 输出目录: " + $OutPath)
Write-Host (" 画布尺寸: {0}x{1}" -f $Width, $Height)
Write-Host ""

$browser = Find-Browser
if (-not $browser) {
  Write-Host " 没有找到 Chrome 或 Edge，请先安装其中一个浏览器。" -ForegroundColor Red
  Read-Host " 按回车退出"
  exit 1
}
Write-Host (" 使用浏览器: " + $browser)
Write-Host ""

New-Item -ItemType Directory -Force -Path $OutPath | Out-Null
Add-Type -AssemblyName System.Drawing

$done = 0
$fail = 0

foreach ($g in $Games) {
  $srcFile = Join-Path $Root $g.File
  if (-not (Test-Path -LiteralPath $srcFile)) {
    Write-Host (" [跳过] 找不到游戏文件: " + $g.File) -ForegroundColor Yellow
    continue
  }

  Write-Host (" [截图] " + $g.File) -ForegroundColor Cyan

  $tmpPng  = Join-Path $env:TEMP ("cover_" + $g.Slug + "_" + [Guid]::NewGuid().ToString("N").Substring(0, 8) + ".png")
  $profile = Join-Path $env:TEMP ("cover_profile_" + [Guid]::NewGuid().ToString("N").Substring(0, 8))
  $dest    = Join-Path $OutPath ($g.Slug + ".png")

  try {
    $uri = ([System.Uri]$srcFile).AbsoluteUri
    $argList = @(
      "--headless=new",
      "--disable-gpu",
      "--hide-scrollbars",
      "--force-device-scale-factor=1",
      "--window-size=$Width,$Height",
      "--virtual-time-budget=$WaitMs",
      "--user-data-dir=$profile",
      "--no-first-run",
      "--no-default-browser-check",
      "--screenshot=$tmpPng",
      $uri
    )
    Start-Process -FilePath $browser -ArgumentList $argList -WindowStyle Hidden | Out-Null

    # 浏览器是 GUI 程序，启动后不会阻塞；轮询等待截图文件落地（最多 30 秒）
    $deadline = (Get-Date).AddSeconds(30)
    $ready = $false
    while ((Get-Date) -lt $deadline) {
      if (Test-Path -LiteralPath $tmpPng) { $ready = $true; break }
      Start-Sleep -Milliseconds 300
    }
    if ($ready) { Start-Sleep -Milliseconds 500 }

    if (-not (Test-Path -LiteralPath $tmpPng)) { throw "浏览器没有输出截图文件（可能被其他窗口占用或启动超时）" }

    # 按需裁剪（去掉游戏页面自带的黑边）
    $img = [System.Drawing.Image]::FromFile($tmpPng)
    $full = New-Object System.Drawing.Rectangle 0, 0, $img.Width, $img.Height
    if ($null -ne $g.Crop) {
      $x = [int]$g.Crop[0]; $y = [int]$g.Crop[1]
      $w = [int]$g.Crop[2]; $h = [int]$g.Crop[3]
      if ($w -gt 0 -and $h -gt 0 -and ($x + $w) -le $img.Width -and ($y + $h) -le $img.Height) {
        $cropRect = New-Object System.Drawing.Rectangle $x, $y, $w, $h
      } else {
        $cropRect = $full
        Write-Host "   [提示] Crop 超出画面范围，改用整张图" -ForegroundColor Yellow
      }
    } else {
      $cropRect = $full
    }

    $bmp  = New-Object System.Drawing.Bitmap $cropRect.Width, $cropRect.Height
    $gfx  = [System.Drawing.Graphics]::FromImage($bmp)
    $dstR = New-Object System.Drawing.Rectangle 0, 0, $cropRect.Width, $cropRect.Height
    $gfx.DrawImage($img, $dstR, $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
    $gfx.Dispose()
    $img.Dispose()

    if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Force }
    $bmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
    $size = [math]::Round((Get-Item -LiteralPath $dest).Length / 1KB, 1)
    $bmp.Dispose()

    Write-Host ("   -> " + $g.Slug + ".png  " + $cropRect.Width + "x" + $cropRect.Height + "  " + $size + " KB") -ForegroundColor Green
    $done++
  }
  catch {
    Write-Host ("   [失败] " + $_.Exception.Message) -ForegroundColor Red
    $fail++
  }
  finally {
    if (Test-Path -LiteralPath $tmpPng) { Remove-Item -LiteralPath $tmpPng -Force -ErrorAction SilentlyContinue }
    if (Test-Path -LiteralPath $profile) { Remove-Item -LiteralPath $profile -Recurse -Force -ErrorAction SilentlyContinue }
  }
}

Write-Host ""
Write-Host (" 完成：成功 {0} 张，失败 {1} 张。刷新游戏广场页面即可看到新封面。" -f $done, $fail) -ForegroundColor Green
Write-Host ""
