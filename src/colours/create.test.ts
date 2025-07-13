import { handler } from './create';
import { APIGatewayEvent } from 'aws-lambda';

const mockPut = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      put: (params: any) => ({ promise: () => mockPut(params) }),
    })),
  },
}));

describe('createColour', () => {
  it('should create a new colour', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Test Blue',
        c: 100,
        m: 50,
        y: 0,
        k: 0,
      }),
    };

    mockPut.mockResolvedValue({});

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(201);
    expect(JSON.parse(result.body).name).toBe('Test Blue');
    expect(mockPut).toHaveBeenCalledWith({
      TableName: '',
      Item: expect.objectContaining({
        name: 'Test Blue',
      }),
    });
  });
});
