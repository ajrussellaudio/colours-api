import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';

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

  const params = {
    TableName: PALETTES_TABLE,
    Key: { id },
  };

  try {
    const result = await dynamoDb.get(params).promise();
    if (result.Item) {
      return {
        statusCode: 200,
        body: JSON.stringify(result.Item),
      };
    } else {
      return {
        statusCode: 404,
        body: JSON.stringify({ message: 'Palette not found' }),
      };
    }
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not retrieve palette', error }),
    };
  }
};
