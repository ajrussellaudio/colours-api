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

describe('createPalette', () => {
  it('should create a new palette', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Test Palette',
        colours: [],
      }),
    };

    mockPut.mockResolvedValue({});

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(201);
    expect(JSON.parse(result.body).name).toBe('Test Palette');
    expect(mockPut).toHaveBeenCalledWith({
      TableName: '',
      Item: expect.objectContaining({
        name: 'Test Palette',
      }),
    });
  });

  it('should return 400 if the input is invalid', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Test Palette',
        colours: [
          {
            name: 'Test Blue',
            c: 101,
            m: 50,
            y: 0,
            k: 0,
          },
        ],
      }),
    };

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(400);
  });
});
