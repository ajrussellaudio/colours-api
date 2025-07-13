import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';
import { v4 as uuidv4 } from 'uuid';
import csv from 'csv-parser';
import { Readable } from 'stream';

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

type CsvData = {
  Name: string;
  C: string;
  M: string;
  Y: string;
  K: string;
};

export const handler: Handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  if (event.httpMethod === 'POST') {
    const csvData = event.body || '';
    const colours: Colour[] = [];

    return new Promise((resolve, reject) => {
      const stream = Readable.from(csvData);
      stream
        .pipe(csv())
        .on('data', (data: CsvData) => {
          colours.push({
            id: uuidv4(),
            name: data.Name,
            c: parseInt(data.C, 10),
            m: parseInt(data.M, 10),
            y: parseInt(data.Y, 10),
            k: parseInt(data.K, 10),
          });
        })
        .on('end', async () => {
          const writeRequests = colours.map((colour) => ({
            PutRequest: {
              Item: colour,
            },
          }));

          const params = {
            RequestItems: {
              [COLOURS_TABLE]: writeRequests,
            },
          };

          try {
            await dynamoDb.batchWrite(params).promise();
            resolve({
              statusCode: 200,
              body: JSON.stringify({ message: 'Upload successful' }),
            });
          } catch (error) {
            reject({
              statusCode: 500,
              body: JSON.stringify({ message: 'Could not upload colours', error }),
            });
          }
        });
    });
  }

  return {
    statusCode: 405,
    body: JSON.stringify({ message: 'Method Not Allowed' }),
  };
};
