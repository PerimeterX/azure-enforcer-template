# Azure Function Enforcer Example

See the full official documentation for the Human Security Azure Enforcer [here](https://docs.perimeterx.com/docs/installation-azure).
You can use the `enforcer-setup.cmd1 file to automate the enforcer setup process, or you can do it manually by following the instructions:

1. Install dependencies with `npm install`.
2. Configure the enforcer by modifying the `EnforcerFunction/config.ts` file.
3. Compile the enforcer by running `npm run build`.
4. Publish the enforcer to your Function App by running `func azure functionapp publish <APP_NAME> --typescript`. (You must have [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local) installed to run this command.)
5. Add the following variables to your deployed Function App [Configuration Settings](https://learn.microsoft.com/en-us/azure/app-service/configure-common?tabs=portal#configure-app-settings):
    * `PX_APP_ID` - The application ID (available in the [portal](https://console.perimeterx.com/))
    * `PX_AUTH_TOKEN` - The server token (available in the [portal](https://console.perimeterx.com/))
    * `PX_COOKIE_SECRET` - The cookie secret associated with the Bot Defender security policy (available in the [portal](https://console.perimeterx.com/))
    * `FRONT_DOOR_SECRET_KEY` - A secret key that will be added as a request header and used in Front Door to verify incoming requests
