import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';
import { v4 as uuidv4 } from 'uuid';

const dynamoDb = new DynamoDB.DocumentClient();
const COLOURS_TABLE = process.env.COLOURS_TABLE || '';

type Colour = {
  id: string;
  name: string;
  c: number;
  m: number;
  y: number;
  k: number;
};

export const handler: Handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  switch (event.httpMethod) {
    case 'POST':
      return createColour(event);
    case 'GET':
      if (event.pathParameters && event.pathParameters.id) {
        return getColour(event);
      }
      return listColours();
    case 'PUT':
      return updateColour(event);
    case 'DELETE':
      return deleteColour(event);
    default:
      return {
        statusCode: 405,
        body: JSON.stringify({ message: 'Method Not Allowed' }),
      };
  }
};

const createColour = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const { name, c, m, y, k } = JSON.parse(event.body || '{}');
  if (!name || c === undefined || m === undefined || y === undefined || k === undefined) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing required fields' }),
    };
  }

  const newColour: Colour = {
    id: uuidv4(),
    name,
    c,
    m,
    y,
    k,
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

const getColour = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing id' }),
    };
  }

  const params = {
    TableName: COLOURS_TABLE,
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
        body: JSON.stringify({ message: 'Colour not found' }),
      };
    }
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not retrieve colour', error }),
    };
  }
};

const listColours = async (): Promise<APIGatewayProxyResult> => {
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

const updateColour = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing id' }),
    };
  }

  const { name, c, m, y, k } = JSON.parse(event.body || '{}');
  if (!name || c === undefined || m === undefined || y === undefined || k === undefined) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing required fields' }),
    };
  }

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

const deleteColour = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing id' }),
    };
  }

  const params = {
    TableName: COLOURS_TABLE,
    Key: { id },
  };

  try {
    await dynamoDb.delete(params).promise();
    return {
      statusCode: 204,
      body: '',
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not delete colour', error }),
    };
  }
};
