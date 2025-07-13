import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';

export const handler: Handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from colours!' }),
  };
};
