<script>
rem Set timezone 
rem You can see available timezones by runnig tzutil /l
tzutil /s "UTC"

rem Create a NICE DCV permission file
rem https://docs.aws.amazon.com/dcv/latest/adminguide/security-authorization-file-create.html
set CONFIG_PATH="C:\Program Files\NICE\DCV\Server\conf\custom.perm"
echo [permissions]> %CONFIG_PATH%
echo %%any%% allow builtin>> %CONFIG_PATH%

rem Example for NICE DCV configuration using Windows registry
rem https://docs.aws.amazon.com/dcv/latest/adminguide/config-param-ref.html
reg.exe ADD "HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\session-management\automatic-console-session" /v max-concurrent-clients /t REG_DWORD /d 1 /f
reg.exe ADD "HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\session-management\automatic-console-session" /v permissions-file /t REG_SZ /d %CONFIG_PATH% /f

rem Apply NICE DCV server configuration by restarting it
net stop "DCV Server"
net start "DCV Server"
</script>

<powershell>
# Initialize instance storage if any
C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeDisks.ps1
</powershell>
<persist>true</persist>
