import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';
import { colourSchema } from '../schemas';

const dynamoDb = new DynamoDB.DocumentClient();
const COLOURS_TABLE = process.env.COLOURS_TABLE || '';

export const handler: Handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing id' }),
    };
  }

  const body = JSON.parse(event.body || '{}');
  const validation = colourSchema.safeParse(body);

  if (!validation.success) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Invalid input', errors: validation.error.issues }),
    };
  }

  const { name, c, m, y, k } = validation.data;

  const params = {
    TableName: COLOURS_TABLE,
    Key: { id },
    UpdateExpression: 'set #name = :name, c = :c, m = :m, y = :y, k = :k',
    ExpressionAttributeNames: {
      '#name': 'name',
    },
    ExpressionAttributeValues: {
      ':name': name,
      ':c': c,
      ':m': m,
      ':y': y,
      ':k': k,
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
      body: JSON.stringify({ message: 'Could not update colour', error }),
    };
  }
};
