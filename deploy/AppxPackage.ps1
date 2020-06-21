$env:Path += ";${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.17763.0\x64"

$mapping = "RoslynPad.mapping"
Remove-Item $mapping -ErrorAction Ignore
Remove-Item RoslynPad.appx -ErrorAction Ignore
Remove-Item *.pri

$location = Get-Location

. .\GetFiles.ps1

"[Files]" >> $mapping
('"' + $location + '\PackageRoot\AppxManifest.xml" "AppxManifest.xml"') >> $mapping
foreach ($asset in Get-ChildItem PackageRoot\Assets)
{
	('"' + $asset.FullName + '" "Assets\' + $asset.Name + '"') >> $mapping
}

foreach ($file in $files)
{
	('"' + $file + '" "' + $file.Substring($rootPath.Length) + '"') >> $mapping
	$file
}

& makepri.exe new /pr PackageRoot /cf priconfig.xml

foreach ($file in Get-ChildItem *.pri)
{
	('"' + $file + '" "' + $file.BaseName + '.pri"') >> $mapping
	$file
}

MakeAppx.exe pack /f $mapping /l /p RoslynPad.appx

./SignAppx.ps1
