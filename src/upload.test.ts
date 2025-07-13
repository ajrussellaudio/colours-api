import { handler } from './upload';
import { APIGatewayEvent } from 'aws-lambda';

const mockBatchWrite = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      batchWrite: (params: any) => ({ promise: () => mockBatchWrite(params) }),
    })),
  },
}));

describe('Upload API', () => {
  beforeEach(() => {
    mockBatchWrite.mockClear();
  });

  it('should upload a CSV of colours', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'POST',
      body: 'Name,C,M,Y,K\nPrussian Blue,100,72,0,6',
    };

    mockBatchWrite.mockResolvedValue({});

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body).message).toBe('Upload successful');
    expect(mockBatchWrite).toHaveBeenCalledWith({
      RequestItems: {
        '': [
          {
            PutRequest: {
              Item: {
                id: expect.any(String),
                name: 'Prussian Blue',
                c: 100,
                m: 72,
                y: 0,
                k: 6,
              },
            },
          },
        ],
      },
    });
  });
});
