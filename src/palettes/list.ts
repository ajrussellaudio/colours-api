import { Handler, APIGatewayProxyResult } from 'aws-lambda';
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

export const handler: Handler = async (): Promise<APIGatewayProxyResult> => {
  const params = {
    TableName: PALETTES_TABLE,
  };

  try {
    const result = await dynamoDb.scan(params).promise();
    if (result.Items) {
      const palettes = await Promise.all(
        result.Items.map(async (item) => {
          const colourIds = item.colours;
          const colourParams = {
            RequestItems: {
              [COLOURS_TABLE]: {
                Keys: colourIds.map((id: string) => ({ id })),
              },
            },
          };
          const colours = await dynamoDb.batchGet(colourParams).promise();
          return {
            id: item.id,
            name: item.name,
            colours: colours.Responses?.[COLOURS_TABLE] as Colour[],
          };
        }),
      );
      return {
        statusCode: 200,
        body: JSON.stringify(palettes),
      };
    }
    return {
      statusCode: 200,
      body: JSON.stringify([]),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not retrieve palettes', error }),
    };
  }
};
