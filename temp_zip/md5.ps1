$bin = [System.IO.File]::ReadAllBytes('D:\AndroidTmax\TMaxPcServiceUI\temp_zip\TMAX.bin')
$seed = [System.Text.Encoding]::ASCII.GetBytes('*T-Scale*')
$combined = new-object byte[] ($bin.Length + $seed.Length)
$bin.CopyTo($combined, 0)
$seed.CopyTo($combined, $bin.Length)
$md5 = [System.Security.Cryptography.MD5]::Create()
$hash = $md5.ComputeHash($combined)
$hex = [System.BitConverter]::ToString($hash).Replace('-', '').ToLower()
Write-Host 'BIN MD5:' $hex

$srec = [System.IO.File]::ReadAllBytes('D:\AndroidTmax\TMaxPcServiceUI\temp_zip\TMAX.srec')
$combined2 = new-object byte[] ($srec.Length + $seed.Length)
$srec.CopyTo($combined2, 0)
$seed.CopyTo($combined2, $srec.Length)
$hash2 = $md5.ComputeHash($combined2)
$hex2 = [System.BitConverter]::ToString($hash2).Replace('-', '').ToLower()
Write-Host 'SREC MD5:' $hex2
