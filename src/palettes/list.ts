import { Handler, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';

const dynamoDb = new DynamoDB.DocumentClient();
const PALETTES_TABLE = process.env.PALETTES_TABLE || '';

export const handler: Handler = async (): Promise<APIGatewayProxyResult> => {
  const params = {
    TableName: PALETTES_TABLE,
  };

  try {
    const result = await dynamoDb.scan(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(result.Items),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not retrieve palettes', error }),
    };
  }
};
