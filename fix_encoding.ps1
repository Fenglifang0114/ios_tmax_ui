$path = 'd:\AndroidPhone\TMaxPcServiceUI\lib\dialog\language_setting.dart'
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(936))
[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::UTF8)
