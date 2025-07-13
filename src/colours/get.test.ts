import { handler } from './get';
import { APIGatewayEvent } from 'aws-lambda';

const mockGet = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      get: (params: any) => ({ promise: () => mockGet(params) }),
    })),
  },
}));

describe('getColour', () => {
  it('should get a colour by id', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'GET',
      pathParameters: {
        id: '123',
      },
    };

    mockGet.mockResolvedValue({ Item: { id: '123', name: 'Test Blue' } });

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body).name).toBe('Test Blue');
    expect(mockGet).toHaveBeenCalledWith({
      TableName: '',
      Key: { id: '123' },
    });
  });
});
