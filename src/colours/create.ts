import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';
import { v4 as uuidv4 } from 'uuid';
import { colourSchema } from '../schemas';

const dynamoDb = new DynamoDB.DocumentClient();
const COLOURS_TABLE = process.env.COLOURS_TABLE || '';

type Colour = {
  id?: string;
  name: string;
  c: number;
  m: number;
  y: number;
  k: number;
};

export const handler: Handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const body = JSON.parse(event.body || '{}');
  const validation = colourSchema.safeParse(body);

  if (!validation.success) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Invalid input', errors: validation.error.issues }),
    };
  }

  const newColour: Colour = {
    ...validation.data,
    id: uuidv4(),
  };

  const params = {
    TableName: COLOURS_TABLE,
    Item: newColour,
  };

  try {
    await dynamoDb.put(params).promise();
    return {
      statusCode: 201,
      body: JSON.stringify(newColour),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not create colour', error }),
    };
  }
};
