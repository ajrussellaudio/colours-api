import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';

const dynamoDb = new DynamoDB.DocumentClient();
const PALETTES_TABLE = process.env.PALETTES_TABLE || '';
const COLOURS_TABLE = process.env.COLOURS_TABLE || '';

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
      const colourIds = result.Item.colours;
      const colourParams = {
        RequestItems: {
          [COLOURS_TABLE]: {
            Keys: colourIds.map((id: string) => ({ id })),
          },
        },
      };
      const colours = await dynamoDb.batchGet(colourParams).promise();
      const palette: Palette = {
        id: result.Item.id,
        name: result.Item.name,
        colours: colours.Responses?.[COLOURS_TABLE] as Colour[],
      };
      return {
        statusCode: 200,
        body: JSON.stringify(palette),
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
