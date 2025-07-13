import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';
import { v4 as uuidv4 } from 'uuid';

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
  switch (event.httpMethod) {
    case 'POST':
      return createPalette(event);
    case 'GET':
      if (event.pathParameters && event.pathParameters.id) {
        return getPalette(event);
      }
      return listPalettes();
    case 'PUT':
      return updatePalette(event);
    case 'DELETE':
      return deletePalette(event);
    default:
      return {
        statusCode: 405,
        body: JSON.stringify({ message: 'Method Not Allowed' }),
      };
  }
};

const createPalette = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const { name, colours } = JSON.parse(event.body || '{}');
  if (!name || !colours || !Array.isArray(colours)) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing required fields' }),
    };
  }

  const newPalette: Palette = {
    id: uuidv4(),
    name,
    colours,
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

const getPalette = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
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

const listPalettes = async (): Promise<APIGatewayProxyResult> => {
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

const updatePalette = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  const id = event.pathParameters && event.pathParameters.id;
  if (!id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing id' }),
    };
  }

  const { name, colours } = JSON.parse(event.body || '{}');
  if (!name || !colours || !Array.isArray(colours)) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Missing required fields' }),
    };
  }

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

const deletePalette = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
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
    await dynamoDb.delete(params).promise();
    return {
      statusCode: 204,
      body: '',
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not delete palette', error }),
    };
  }
};
