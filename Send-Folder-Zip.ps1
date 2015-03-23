$sw = [Diagnostics.Stopwatch]::StartNew()

. .\Send-File.ps1

$files = Get-ChildItem C:\Development\lightyear\chef-repo -File -Recurse
$remote = "tfsbuild2"
$session = new-pssession $remote

Remove-Item "C:\tmp\send-file.zip" -force

Add-Type -Assembly "System.IO.Compression.FileSystem" ;
[System.IO.Compression.ZipFile]::CreateFromDirectory("C:\Development\lightyear\chef-repo", "C:\tmp\send-file.zip");

sendfile -Source "C:\tmp\send-file.zip" -Destination "C:\tmp\send-file.zip" -Session $session

Invoke-Command -Session $session -ScriptBlock {
    Remove-Item -Recurse "C:\chef-repo"
    Add-Type -Assembly "System.IO.Compression.FileSystem" ;
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:\tmp\send-file.zip", "c:\chef-repo");
    Remove-Item "C:\tmp\send-file.zip" -force
}

Remove-Item "C:\tmp\send-file.zip" -force
Disconnect-PSSession $session

$sw.Stop()
$sw.Elapsed