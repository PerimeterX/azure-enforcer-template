import { ConfigurationParams } from 'perimeterx-azure-js-sdk';

export const config: ConfigurationParams = {
    px_app_id: process.env.PX_APP_ID,
    px_auth_token: process.env.PX_AUTH_TOKEN,
    px_cookie_secret: process.env.PX_COOKIE_SECRET,
};
