@echo off
setlocal enabledelayedexpansion

rem Get current date and time to create a unique log file name
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%"
set "Min=%dt:~10,2%"
set "Sec=%dt:~12,2%"
set "LOG_FILE=log_%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%.txt"

echo Logging to: %LOG_FILE%

:input_resource_group
set /p RESOURCE_GROUP=Enter the desired Resource Group (i.e. DefaultResourceGroup-EUS):
if "%RESOURCE_GROUP%"=="" (
    powershell Write-Output "Resource Group cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_resource_group
)

:input_front_door_profile
set /p FRONT_DOOR_PROFILE=Enter a desired Front Door Name (i.e. myfrontdoor):
if "%FRONT_DOOR_PROFILE%"=="" (
    powershell Write-Output "Front Door Profile cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_front_door_profile
)

:input_frontdoor_sku
set /p FRONTDOOR_SKU=Enter Front Door SKU (default is Standard_AzureFrontDoor):
if "%FRONTDOOR_SKU%"=="" (
    set "FRONTDOOR_SKU=Standard_AzureFrontDoor"
    powershell Write-Output "Using default Front Door SKU: Standard_AzureFrontDoor." | Tee-Object -Append -FilePath "%LOG_FILE%"
) else (
    REM powershell Write-Output "Front Door SKU set to: %FRONTDOOR_SKU%"
    powershell Write-Output "Front Door SKU set to: $FRONTDOOR_SKU." | Tee-Object -Append -FilePath "%LOG_FILE%"
)

:input_backend_fqdn
set /p BACKEND_FQDN=Enter the associated app backend fqdn (i.e. backendapp.functionapp.net):
if "%BACKEND_FQDN%"=="" (
    powershell Write-Output "The Backend FQDN cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_backend_fqdn
)

:input_ruleset_name
set /p RULESET_NAME=Enter Ruleset Name (default is HumanRuleSet):
if "%RULESET_NAME%"=="" (
    set "RULESET_NAME=HumanRuleSet"
    powershell Write-Output "Using default Ruleset Name: HumanRuleSet." | Tee-Object -Append -FilePath "%LOG_FILE%"
) else (
    echo Ruleset Name set to: %RULESET_NAME%
)

:input_endpoint
set /p ENDPOINT=Enter a desired Front Door fqdn subdomain. Only enter the value you'd see ahead of the apex domain without a period. ([mybhfrontdoorendpoint].azurefd.net):
if "%ENDPOINT%"=="" (
    powershell Write-Output "Endpoint cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_endpoint
)

:input_function_app_name
set /p FUNCTION_APP_NAME=Enter a desired Function App Name:
if "%FUNCTION_APP_NAME%"=="" (
    powershell Write-Output "Function App Name cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_function_app_name
)

:input_location
set /p LOCATION=Provide a selected Location (e.g., centralus) (default is eastus):
if "%LOCATION%"=="" (
    set "LOCATION=eastus"
    powershell Write-Output "Using default Location: eastus." | Tee-Object -Append -FilePath "%LOG_FILE%"
) else (
    REM echo Location set to: %LOCATION%
    powershell Write-Output "Location set to: $LOCATION." | Tee-Object -Append -FilePath "%LOG_FILE%"
)

:input_storage_account
set /p STORAGE_ACCOUNT=Enter a desired Storage Account (unique, lowercase, and numbers):
if "%STORAGE_ACCOUNT%"=="" (
    powershell Write-Output "Storage Account cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_storage_account
)

:input_storage_sku
set /p STORAGE_SKU=Provide a selected Storage SKU (default is Standard_LRS):
if "%STORAGE_SKU%"=="" (
    set "STORAGE_SKU=Standard_LRS"
    powershell Write-Output "Using default Storage SKU: Standard_LRS." | Tee-Object -Append -FilePath "%LOG_FILE%"
) else (
    REM powershell Write-Output "Storage SKU set to: %STORAGE_SKU%
    powershell Write-Output "Storage SKU set to: $STORAGE_SKU." | Tee-Object -Append -FilePath "%LOG_FILE%"
)

:input_app_id
set /p APPID=Enter the HUMAN App ID (PXxxxxxx):
if "%APPID%"=="" (
    powershell Write-Output "HUMAN App ID cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_app_id
)
set "APPID_SHORTENED=%APPID:~2%"

:input_px_auth_token
set /p PX_AUTH_TOKEN=Enter the HUMAN Authentication Token:
if "%PX_AUTH_TOKEN%"=="" (
    powershell Write-Output "HUMAN Authentication Token cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_px_auth_token
)

:input_px_cookie_secret
set /p PX_COOKIE_SECRET=Enter the HUMAN Cookie Secret:
if "%PX_COOKIE_SECRET%"=="" (
    powershell Write-Output "HUMAN Cookie Secret cannot be empty." | Tee-Object -Append -FilePath "%LOG_FILE%"
    goto input_px_cookie_secret
)

call :generate_random_string 64
echo Random string: !result!
set SECRET_KEY=!result!

powershell Write-Output "Values entered:
echo FRONT_DOOR_PROFILE=%FRONT_DOOR_PROFILE%
echo BACKEND_FQDN=%BACKEND_FQDN%
echo RESOURCE_GROUP=%RESOURCE_GROUP%
echo RULESET_NAME=%RULESET_NAME%
echo ENDPOINT=%ENDPOINT%
echo FUNCTION_APP_NAME=%FUNCTION_APP_NAME%
echo LOCATION=%LOCATION%
echo STORAGE_ACCOUNT=%STORAGE_ACCOUNT%
echo STORAGE_SKU=%STORAGE_SKU%
echo FRONTDOOR_SKU=%FRONTDOOR_SKU%
echo PX_APPID=%APPID%
echo PX_APPID_SHORTENED=%APPID_SHORTENED%
echo PX_AUTH_TOKEN=%PX_AUTH_TOKEN%
echo PX_COOKIE_SECRET=%PX_COOKIE_SECRET%
echo SECRET_KEY=%SECRET_KEY%

choice /M "Do the values look good? [Y/N]"
if errorlevel 2 (
    powershell Write-Output "Values are not confirmed, Exiting." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)

SET FNAME_REGEX="^\.?(css)|(bmp)|(tif)|(ttf)|(docx)|(woff2)|(pict)|(tiff)|(eot)|(xlsx)|(jpg)|(csv)|(eps)|(woff)|(xls)|(jpeg)|(doc)|(ejs)|(otf)|(pttx)|(gif)|(pdf)|(swf)|(svg)|(ps)|(ico)|(pls)|(midi)|(svgz)|(class)|(png)|(ppt)|(mid)|(webp)|(jar)|(json)$"

powershell Write-Output "Creating a Storage Account." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az storage account create --name "%STORAGE_ACCOUNT%" --resource-group "%RESOURCE_GROUP%" --location "%LOCATION%" --sku "%STORAGE_SKU%" --output none
if errorlevel 1 (
    powershell Write-Output "Error creating storage account." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created a Storage Account." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating a Function App." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az functionapp create --consumption-plan-location "%LOCATION%" --name %FUNCTION_APP_NAME% --os-type Linux --resource-group %RESOURCE_GROUP% --runtime node --runtime-version 18 --storage-account "%STORAGE_ACCOUNT%" --output none
if errorlevel 1 (
    powershell Write-Output "Error creating function app." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created a Function App." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Set environment variables for PX_COOKIE_SECRET, PX_APP_ID, PX_AUTH_TOKEN, FRONT_DOOR_SECRET_KEY, PX_MODULE_MODE
call az functionapp config appsettings set --name %FUNCTION_APP_NAME% --resource-group %RESOURCE_GROUP% --settings PX_COOKIE_SECRET=%PX_COOKIE_SECRET% --output none
if errorlevel 1 (
    powershell Write-Output "Error setting app settings PX_COOKIE_SECRET." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Set environment variable PX_COOKIE_SECRET." | Tee-Object -Append -FilePath "%LOG_FILE%"

call az functionapp config appsettings set --name %FUNCTION_APP_NAME% --resource-group %RESOURCE_GROUP% --settings PX_APP_ID="%APPID%" --output none
if errorlevel 1 (
    powershell Write-Output "Error setting app settings PX_APP_ID." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Set environment variable PX_APP_ID." | Tee-Object -Append -FilePath "%LOG_FILE%"

call az functionapp config appsettings set --name %FUNCTION_APP_NAME% --resource-group %RESOURCE_GROUP% --settings PX_AUTH_TOKEN="%PX_AUTH_TOKEN%" --output none
if errorlevel 1 (
    powershell Write-Output "Error setting app settings PX_AUTH_TOKEN." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Set environment variable PX_AUTH_TOKEN." | Tee-Object -Append -FilePath "%LOG_FILE%"

call az functionapp config appsettings set --name %FUNCTION_APP_NAME% --resource-group %RESOURCE_GROUP% --settings FRONT_DOOR_SECRET_KEY="%SECRET_KEY%" --output none
if errorlevel 1 (
    powershell Write-Output "Error setting app settings FRONT_DOOR_SECRET_KEY." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Set environment variable FRONT_DOOR_SECRET_KEY." | Tee-Object -Append -FilePath "%LOG_FILE%"

call az functionapp config appsettings set --name %FUNCTION_APP_NAME% --resource-group %RESOURCE_GROUP% --settings PX_MODULE_MODE=monitor --output none
if errorlevel 1 (
    powershell Write-Output "Error setting app settings PX_MODULE_MODE." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Set environment variable PX_MODULE_MODE." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Cloning GIT Repository." | Tee-Object -Append -FilePath "%LOG_FILE%"
git clone https://github.com/PerimeterX/azure-enforcer-template.git
cd azure-enforcer-template

powershell Write-Output "Add these lines to the end of the config.ts and close notepad to continue." | Tee-Object -Append -FilePath "%LOG_FILE%"
echo // @ts-ignore
echo px_module_mode: process.env.PX_MODULE_MODE,
notepad EnforcerFunction\config.ts
pause

call npm install
call npm run build

powershell Write-Output "Publishing Function App." | Tee-Object -Append -FilePath "%LOG_FILE%"
func azure functionapp publish %FUNCTION_APP_NAME% --typescript
if errorlevel 1 (
    powershell Write-Output "Error publishing functionapp." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Published the Function App." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Getting Function App Function Key." | Tee-Object -Append -FilePath "%LOG_FILE%"
for /f "delims=" %%a in (' powershell -command "(az functionapp function keys list -g %RESOURCE_GROUP% -n %FUNCTION_APP_NAME% --function-name EnforcerFunction | ConvertFrom-json).default" ') do set "FUNCTION_KEY=%%a"
echo Function Key: %FUNCTION_KEY%

powershell Write-Output "Creating a Front Door Profile." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd profile create --profile-name "%FRONT_DOOR_PROFILE%" -g "%RESOURCE_GROUP%" --sku Standard_AzureFrontDoor --output none
if errorlevel 1 (
    powershell Write-Output "Error creating a front door." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the Front Door Profile." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating an Endpoint associated with Front Door." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd endpoint create --profile-name "%FRONT_DOOR_PROFILE%" --resource-group "%RESOURCE_GROUP%" --name "%ENDPOINT%" --endpoint-name "%ENDPOINT%" --output none
if errorlevel 1 (
    powershell Write-Output "Error creating an endpoint associated with Front Door." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the Front Door Endpoint." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating the 5 origin groups HSClient, HSEnforcer, HSCollector, HSCaptcha, and BackendOrigin
powershell Write-Output "Creating Origin Group HSClient
call az afd origin-group create -g "%RESOURCE_GROUP%" --origin-group-name HSClient --profile-name "%FRONT_DOOR_PROFILE%" --probe-request-type GET --probe-protocol Http --probe-interval-in-seconds 120 --sample-size 4 --successful-samples-required 3 --additional-latency-in-milliseconds 50 --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin group HSClient." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin group HSClient." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin group HSEnforcer." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin-group create -g "%RESOURCE_GROUP%" --origin-group-name HSEnforcer --profile-name "%FRONT_DOOR_PROFILE%" --probe-request-type GET --probe-protocol Http --probe-interval-in-seconds 120 --sample-size 4 --successful-samples-required 3 --additional-latency-in-milliseconds 50 --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin group HSEnforcer." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin group HSEnforcer." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin group HSCollector." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin-group create -g "%RESOURCE_GROUP%" --origin-group-name HSCollector --profile-name "%FRONT_DOOR_PROFILE%" --probe-request-type GET --probe-protocol Http --probe-interval-in-seconds 120 --sample-size 4 --successful-samples-required 3 --additional-latency-in-milliseconds 50 --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin group HSCollector." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin group HSCollector." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin group HSCaptcha." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin-group create -g "%RESOURCE_GROUP%" --origin-group-name HSCaptcha --profile-name "%FRONT_DOOR_PROFILE%" --probe-request-type GET --probe-protocol Http --probe-interval-in-seconds 120 --sample-size 4 --successful-samples-required 3 --additional-latency-in-milliseconds 50 --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin group HSCaptcha." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin group HSCaptcha." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin group BackendOrigin." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin-group create -g "%RESOURCE_GROUP%" --origin-group-name BackendOrigin --profile-name "%FRONT_DOOR_PROFILE%" --probe-request-type GET --probe-protocol Http --probe-interval-in-seconds 120 --sample-size 4 --successful-samples-required 3 --additional-latency-in-milliseconds 50 --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin group BackendOrigin." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin group BackendOrigin." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin HSClient." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin create --resource-group "%RESOURCE_GROUP%" --origin-group-name HSClient --profile-name "%FRONT_DOOR_PROFILE%" --host-name client.perimeterx.net --http-port 80 --https-port 443 --origin-name HSClient --name HSClient --weight 1000 --priority 1 --origin-host-header client.perimeterx.net --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin HSClient." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin HSClient." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin HSEnforcer." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin create --resource-group "%RESOURCE_GROUP%" --origin-group-name HSEnforcer --profile-name "%FRONT_DOOR_PROFILE%" --host-name %FUNCTION_APP_NAME%.azurewebsites.net --http-port 80 --https-port 443 --origin-name HSEnforcer --name HSEnforcer --weight 1000 --priority 1 --origin-host-header %FUNCTION_APP_NAME%.azurewebsites.net --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin HSEnforcer." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin HSEnforcer." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin HSCollector." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin create --resource-group "%RESOURCE_GROUP%" --origin-group-name HSCollector --profile-name "%FRONT_DOOR_PROFILE%" --host-name collector-%APPID%.perimeterx.net --http-port 80 --https-port 443 --origin-name HSCollector --name HSCollector --weight 1000 --priority 1 --origin-host-header collector-%APPID%.perimeterx.net --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin HSCollector." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin HSCollector." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin HSCaptcha." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin create --resource-group "%RESOURCE_GROUP%" --origin-group-name HSCaptcha --profile-name "%FRONT_DOOR_PROFILE%" --host-name captcha.px-cdn.net --http-port 80 --https-port 443 --origin-name HSCaptcha --name HSCaptcha --weight 1000 --priority 1 --origin-host-header captcha.px-cdn.net --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin HSCaptcha." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin HSCaptcha." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating origin BackendOrigin." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd origin create --resource-group "%RESOURCE_GROUP%" --origin-group-name BackendOrigin --profile-name "%FRONT_DOOR_PROFILE%" --host-name "%BACKEND_FQDN%" --http-port 80 --https-port 443 --origin-name BackendOrigin --name BackendOrigin --weight 1000 --priority 1 --origin-host-header "%BACKEND_FQDN%" --output none
if errorlevel 1 (
    powershell Write-Output "Error creating origin BackendOrigin." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the origin BackendOrigin." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating the Front Door Ruleset." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd rule-set create --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" --output none
if errorlevel 1 (
    powershell Write-Output "Error creating the ruleset." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the Front Door Ruleset." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating Rule 1." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd rule create ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --order 1 ^
    --match-variable UrlPath ^
    --operator BeginsWith ^
    --match-values /%APPID_SHORTENED%/ ^
    --rule-name HSFirstPartyHeaders ^
    --action-name ModifyRequestHeader ^
    --header-action Append ^
    --header-name "x-px-first-party" ^
    --header-value "1" ^
    --match-processing-behavior Continue ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error creating Rule 1." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)

call az afd rule action add ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --rule-name HSFirstPartyHeaders ^
    --action-name ModifyRequestHeader ^
    --header-action Append ^
    --header-name "x-px-enforcer-true-ip" ^
    --header-value "{client_ip}" ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error adding an action to Rule 1." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created Rule 1." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating Rule 2." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd rule create ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --order 2 ^
    --match-variable UrlPath ^
    --operator Equal ^
    --match-values /%APPID_SHORTENED%/init.js ^
    --rule-name HSFirstPartyClient ^
    --action-name UrlRewrite ^
    --source-pattern /%APPID_SHORTENED%/init.js ^
    --destination /%APPID%/main.min.js ^
    --preserve-unmatched-path No ^
    --match-processing-behavior Stop ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error creating Rule 2." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)

call az afd rule action add ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --rule-name HSFirstPartyClient ^
    --action-name RouteConfigurationOverride ^
    --origin-group HSClient ^
    --forwarding-protocol MatchRequest ^
    --enable-caching false ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error adding an action to Rule 2." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created Rule 2." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating Rule 3." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd rule create ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --order 3 ^
    --match-variable UrlPath ^
    --operator BeginsWith ^
    --match-values /%APPID_SHORTENED%/captcha ^
    --rule-name HSFirstPartyCaptcha ^
    --action-name UrlRewrite ^
    --source-pattern /%APPID_SHORTENED%/captcha ^
    --destination /%APPID% ^
    --preserve-unmatched-path Yes ^
    --match-processing-behavior Stop ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error creating Rule 3." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)

call az afd rule action add ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --rule-name HSFirstPartyCaptcha ^
    --action-name RouteConfigurationOverride ^
    --origin-group HSCaptcha ^
    --forwarding-protocol MatchRequest ^
    --enable-caching false ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error adding an action to Rule 3." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created Rule 3." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating Rule 4." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd rule create ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --order 4 ^
    --match-variable UrlPath ^
    --operator BeginsWith ^
    --match-values /%APPID_SHORTENED%/xhr ^
    --rule-name HSFirstPartyXHR ^
    --action-name UrlRewrite ^
    --source-pattern /%APPID_SHORTENED%/xhr ^
    --destination "/" ^
    --preserve-unmatched-path Yes ^
    --match-processing-behavior Stop ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error creating Rule 4." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)

call az afd rule action add ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --rule-name HSFirstPartyXHR ^
    --action-name RouteConfigurationOverride ^
    --origin-group HSCollector ^
    --forwarding-protocol MatchRequest ^
    --enable-caching false ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error adding an action to Rule 4." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created Rule 4." | Tee-Object -Append -FilePath "%LOG_FILE%"

REM powershell Write-Output "Creating Rule 5." | Tee-Object -Append -FilePath "%LOG_FILE%"
REM call az afd rule create ^
REM     --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
REM     --order 5 ^
REM     --match-variable RequestMethod ^
REM     --operator Equal ^
REM     --match-values GET ^
REM     --rule-name HSFilteredExtensions ^
REM     --action-name RouteConfigurationOverride ^
REM     --enable-caching true ^
REM     --query-string-caching-behavior IgnoreQueryString ^
REM     --enable-compression true ^
REM     --cache-behavior HonorOrigin ^
REM     --match-processing-behavior Stop ^
REM     --output none
REM if errorlevel 1 (
REM     powershell Write-Output "Error creating Rule 5." | Tee-Object -Append -FilePath "%LOG_FILE%"
REM     exit /b 1
REM )

REM call az afd rule condition add ^
REM     --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
REM     --rule-name HSFilteredExtensions ^
REM     --match-variable UrlFileExtension ^
REM     --operator RegEx ^
REM     --match-value %FNAME_REGEX% ^
REM     --output none
REM if errorlevel 1 (
REM     powershell Write-Output "Error adding a condition to Rule 5." | Tee-Object -Append -FilePath "%LOG_FILE%"
REM     exit /b 1
REM )
REM powershell Write-Output "Created Rule 5." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating Rule 5." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd rule create ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --order 6 ^
    --match-variable RequestHeader ^
    --rule-name HSUnenforcedRequest ^
    --selector "x-enforcer-auth" ^
    --operator Equal ^
    --negate-condition true ^
    --match-values "%SECRET_KEY%" ^
    --transforms Trim ^
    --action-name ModifyRequestHeader ^
    --header-action Overwrite ^
    --header-name "x-functions-key" ^
    --header-value "%FUNCTION_KEY%" ^
    --match-processing-behavior Stop ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error creating Rule 5." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)

call az afd rule action add ^
    --resource-group "%RESOURCE_GROUP%" --rule-set-name "%RULESET_NAME%" --profile-name "%FRONT_DOOR_PROFILE%" ^
    --rule-name HSUnenforcedRequest ^
    --action-name RouteConfigurationOverride ^
    --origin-group HSEnforcer ^
    --forwarding-protocol MatchRequest ^
    --enable-caching false ^
    --output none
if errorlevel 1 (
    powershell Write-Output "Error adding an action to Rule 5." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created Rule 5." | Tee-Object -Append -FilePath "%LOG_FILE%"

powershell Write-Output "Creating a route and associate the ruleset and Backend with it." | Tee-Object -Append -FilePath "%LOG_FILE%"
call az afd route create -g "%RESOURCE_GROUP%" --endpoint-name "%ENDPOINT%" --profile-name "%FRONT_DOOR_PROFILE%" --route-name HumanSecurityRoute --rule-sets "%RULESET_NAME%" --origin-group BackendOrigin --supported-protocols Http Https --link-to-default-domain Enabled --forwarding-protocol MatchRequest --https-redirect Disabled --output none
if errorlevel 1 (
    powershell Write-Output "Error creating a route." | Tee-Object -Append -FilePath "%LOG_FILE%"
    exit /b 1
)
powershell Write-Output "Created the route, ruleset and Backend association." | Tee-Object -Append -FilePath "%LOG_FILE%"

REM Function to generate a random string
:generate_random_string
set "string=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
set "result="
for /L %%i in (1,1,%1) do call :add
exit /b

REM Helper function for generate_random_string
:add
set /a x=%random% %% 62
set result=!result!!string:~%x%,1!
exit /b
