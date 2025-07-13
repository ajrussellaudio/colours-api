import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';
import { paletteSchema } from '../schemas';
import { v4 as uuidv4 } from 'uuid';

const dynamoDb = new DynamoDB.DocumentClient();
const PALETTES_TABLE = process.env.PALETTES_TABLE || '';

export const handler: Handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing id' }),
    };
  }

  const body = JSON.parse(event.body || '{}');
  const validation = paletteSchema.safeParse(body);

  if (!validation.success) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Invalid input', errors: validation.error.issues }),
    };
  }

  const { name, colours } = validation.data;

  const params = {
    TableName: PALETTES_TABLE,
    Key: { id },
    UpdateExpression: 'set #name = :name, colours = :colours',
    ExpressionAttributeNames: {
      '#name': 'name',
    },
    ExpressionAttributeValues: {
      ':name': name,
      ':colours': colours,
    },
    ReturnValues: 'ALL_NEW',
  };

  try {
    const result = await dynamoDb.update(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(result.Attributes),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not update palette', error }),
    };
  }
};
