import { createDefaultHttpTrigger } from 'perimeterx-azure-js-sdk';
import { config } from './config';

const httpTrigger = createDefaultHttpTrigger(config, process.env.FRONT_DOOR_SECRET_KEY);

export default httpTrigger;
