import { Handler, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';

const dynamoDb = new DynamoDB.DocumentClient();
const COLOURS_TABLE = process.env.COLOURS_TABLE || '';

export const handler: Handler = async (): Promise<APIGatewayProxyResult> => {
  const params = {
    TableName: COLOURS_TABLE,
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
      body: JSON.stringify({ message: 'Could not retrieve colours', error }),
    };
  }
};
