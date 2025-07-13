import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';
import { v4 as uuidv4 } from 'uuid';
import { paletteSchema } from '../schemas';

const dynamoDb = new DynamoDB.DocumentClient();
const PALETTES_TABLE = process.env.PALETTES_TABLE || '';

type Colour = {
  id: string;
  name: string;
  c: number;
  m: number;
  y: number;
  k: number;
};

type Palette = {
  id: string;
  name: string;
  colours: Colour[];
};

export const handler: Handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const body = JSON.parse(event.body || '{}');
  const validation = paletteSchema.safeParse(body);

  if (!validation.success) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Invalid input', errors: validation.error.issues }),
    };
  }

  const newPalette: Palette = {
    id: uuidv4(),
    name: validation.data.name,
    colours: validation.data.colours.map(c => ({...c, id: c.id || uuidv4()}))
  };

  const params = {
    TableName: PALETTES_TABLE,
    Item: newPalette,
  };

  try {
    await dynamoDb.put(params).promise();
    return {
      statusCode: 201,
      body: JSON.stringify(newPalette),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not create palette', error }),
    };
  }
};
