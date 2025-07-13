import { handler } from './get';
import { APIGatewayEvent } from 'aws-lambda';
import { v4 as uuidv4 } from 'uuid';

const mockGet = jest.fn();
const mockBatchGet = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      get: (params: any) => ({ promise: () => mockGet(params) }),
      batchGet: (params: any) => ({ promise: () => mockBatchGet(params) }),
    })),
  },
}));

describe('getPalette', () => {
  it('should get a palette by id', async () => {
    const colourId = uuidv4();
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'GET',
      pathParameters: {
        id: '123',
      },
    };

    mockGet.mockResolvedValue({ Item: { id: '123', name: 'Test Palette', colours: [colourId] } });
    mockBatchGet.mockResolvedValue({ Responses: { '': [{ id: colourId, name: 'Test Blue' }] } });

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body).name).toBe('Test Palette');
    expect(JSON.parse(result.body).colours[0].name).toBe('Test Blue');
    expect(mockGet).toHaveBeenCalledWith({
      TableName: '',
      Key: { id: '123' },
    });
    expect(mockBatchGet).toHaveBeenCalledWith({
      RequestItems: {
        '': {
          Keys: [{ id: colourId }],
        },
      },
    });
  });
});
