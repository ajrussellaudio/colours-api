import { Handler, APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';
import { v4 as uuidv4 } from 'uuid';
import csv from 'csv-parser';
import { Readable } from 'stream';

// Add a global error handler to catch initialization errors
process.on('unhandledRejection', (reason, promise) => {
  console.error('!!! UNHANDLED REJECTION !!!');
  console.error('Unhandled Rejection at:', promise);
  console.error('Reason:', reason);
});


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

const processCsv = (csvData: string): Promise<Colour[]> => {
  console.log('Processing CSV data...');
  return new Promise((resolve, reject) => {
    const colours: Colour[] = [];
    const stream = Readable.from(csvData);
    stream
      .pipe(csv())
      .on('data', (data: CsvData) => {
        try {
          if (!data.Name || !data.C || !data.M || !data.Y || !data.K) {
            console.warn('Skipping malformed row:', data);
            return;
          }
          colours.push({
            id: uuidv4(),
            name: data.Name,
            c: parseInt(data.C, 10),
            m: parseInt(data.M, 10),
            y: parseInt(data.Y, 10),
            k: parseInt(data.K, 10),
          });
        } catch (e: any) {
          console.error('Error processing row:', data, e);
          reject(new Error(`Error processing row: ${JSON.stringify(data)}. Details: ${e.message}`));
        }
      })
      .on('end', () => {
        console.log(`Finished processing CSV. ${colours.length} colours parsed.`);
        resolve(colours);
      })
      .on('error', (error) => {
        console.error('Error in CSV stream:', error);
        reject(error);
      });
  });
};

export const handler: Handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ message: 'Method Not Allowed' }),
    };
  }

  try {
    let csvData = event.body || '';
    console.log('isBase64Encoded:', event.isBase64Encoded);
    if (event.isBase64Encoded) {
      csvData = Buffer.from(csvData, 'base64').toString('utf-8');
      console.log('Decoded CSV data:', csvData.substring(0, 500) + '...');
    } else {
      console.log('Raw CSV data:', csvData.substring(0, 500) + '...');
    }

    const colours = await processCsv(csvData);

    if (colours.length === 0) {
      console.log('No colours found in CSV.');
      return {
        statusCode: 400,
        body: JSON.stringify({ message: 'CSV is empty or invalid' }),
      };
    }

    const writeRequests = colours.map((colour) => ({
      PutRequest: {
        Item: colour,
      },
    }));

    console.log(`Creating ${Math.ceil(writeRequests.length / 25)} batches.`);
    const batches = [];
    for (let i = 0; i < writeRequests.length; i += 25) {
      batches.push(writeRequests.slice(i, i + 25));
    }

    for (const [index, batch] of batches.entries()) {
      const params = {
        RequestItems: {
          [COLOURS_TABLE]: batch,
        },
      };
      console.log(`Writing batch ${index + 1} of ${batches.length} to DynamoDB.`);
      await dynamoDb.batchWrite(params).promise();
    }

    console.log('Upload successful.');
    return {
      statusCode: 200,
      body: JSON.stringify({ message: `Upload successful. ${colours.length} colours added.` }),
    };
  } catch (error: any) {
    console.error('Unhandled error in handler:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Could not upload colours',
        error: {
          message: error.message,
          stack: error.stack,
        },
      }),
    };
  }
};
