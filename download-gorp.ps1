param(
    [Uri] $DownloadUrl = 'https://raw.githubusercontent.com/Chikcenss/Chickenlittle/gorp-v6.2.1-download/gorp_discord_core_v6_2_1_custom_roster.zip',
    [string] $Destination = (Join-Path $env:USERPROFILE 'Downloads\GORP-Bot-v6.2.1')
)

$ErrorActionPreference = 'Stop'
$ExpectedSha256 = '9d341a22961bc438647ca31d1bf2b827eded3d1c2fc0fbcc048a89724e313c65'

if ($DownloadUrl.Scheme -ne 'https') {
    throw 'Use an HTTPS download URL.'
}
if (Test-Path -LiteralPath $Destination) {
    throw "Destination already exists: $Destination. Choose a new folder to preserve existing files."
}

$TemporaryZip = Join-Path ([IO.Path]::GetTempPath()) (([Guid]::NewGuid().ToString()) + '.zip')
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadUrl.AbsoluteUri -OutFile $TemporaryZip
    $ActualSha256 = (Get-FileHash -LiteralPath $TemporaryZip -Algorithm SHA256).Hash
    if ($ActualSha256 -ne $ExpectedSha256) {
        throw 'The download did not match the verified bot ZIP. No files were installed.'
    }
    Expand-Archive -LiteralPath $TemporaryZip -DestinationPath $Destination
    Write-Host "Bot extracted to: $Destination\gorp_discord_core"
    Write-Host 'Keep your existing private credential files. Read ROSTER_VERIFICATION.md before starting the bot.'
    Invoke-Item -LiteralPath $Destination
}
finally {
    if (Test-Path -LiteralPath $TemporaryZip) {
        Remove-Item -LiteralPath $TemporaryZip
    }
}
