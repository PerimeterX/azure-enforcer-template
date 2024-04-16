# Azure Function Enforcer Example

See the full official documentation for the Human Security Azure Enforcer [here](https://docs.perimeterx.com/docs/installation-azure).

## Automatic enforcer setup

1. Run the `enforcer-setup.cmd` file to automate the enforcer setup process.
2. CMD files are designed to run on Window.
3. This script will setup enforcer with the basic functionlaity. To costumize it further, you can modify the `EnforcerFunction/config.ts` file using the [ official documentation](https://edocs.humansecurity.com/v1/docs/en/configuration-azure?highlight=azure).

## Manual enforcer setup:

1. Install dependencies with `npm install`.
2. Configure the enforcer by modifying the `EnforcerFunction/config.ts` file.
3. Compile the enforcer by running `npm run build`.
4. Publish the enforcer to your Function App by running `func azure functionapp publish <APP_NAME> --typescript`. (You must have [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local) installed to run this command.)
5. Add the following variables to your deployed Function App [Configuration Settings](https://learn.microsoft.com/en-us/azure/app-service/configure-common?tabs=portal#configure-app-settings):
    * `PX_APP_ID` - The application ID (available in the [portal](https://console.perimeterx.com/))
    * `PX_AUTH_TOKEN` - The server token (available in the [portal](https://console.perimeterx.com/))
    * `PX_COOKIE_SECRET` - The cookie secret associated with the Bot Defender security policy (available in the [portal](https://console.perimeterx.com/))
    * `FRONT_DOOR_SECRET_KEY` - A secret key that will be added as a request header and used in Front Door to verify incoming requests
