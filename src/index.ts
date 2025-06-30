import { createDefaultHttpTrigger, ConfigurationParams } from 'perimeterx-azure-js-sdk';
import config from './enforcerConfig.json';

const httpTrigger = createDefaultHttpTrigger(config as ConfigurationParams, process.env.FRONT_DOOR_SECRET_KEY || '');

export default httpTrigger;
