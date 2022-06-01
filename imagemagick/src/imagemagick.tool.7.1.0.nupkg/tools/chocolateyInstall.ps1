$packageArgs = @{
  packageName    = 'imagemagick.tool'
  url            = 'https://github.com/swift-nav/swift-toolchains/releases/download/imagemagick-7.1.0/ImageMagick-7.1.0-portable-Q16-x86.zip'
  url64          = 'https://github.com/swift-nav/swift-toolchains/releases/download/imagemagick-7.1.0/ImageMagick-7.1.0-portable-Q16-x64.zip'
  fallbackUrl    = 'https://download.imagemagick.org/ImageMagick/download/binaries/ImageMagick-7.1.0-portable-Q16-x86.zip'
  fallbackUrl64  = 'https://download.imagemagick.org/ImageMagick/download/binaries/ImageMagick-7.1.0-portable-Q16-x64.zip'
  checksum       = 'E41595EBCB17267F0E9F52AEDB2B2DA37B0EBDEAB6722D15DF28949910E82E8E'
  checksum64     = '2CCCD00CD8E904FA749F13B40F5D22121C82395053DC07CC6327C9B408F8D513'
  unzipLocation  = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
  checksumType   = 'sha256'
  checksumType64 = 'sha256'
}

try {
    Get-WebHeaders $packageArgs.url
}
catch {
    $packageArgs.url = $packageArgs.fallbackUrl
    $packageArgs.url64 = $packageArgs.fallbackUrl64
}

Install-ChocolateyZipPackage @packageArgs
