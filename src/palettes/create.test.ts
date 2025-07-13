import { handler } from './create';
import { APIGatewayEvent } from 'aws-lambda';
import { v4 as uuidv4 } from 'uuid';

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
    const colourId = uuidv4();
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Test Palette',
        colours: [colourId],
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
        colours: [colourId],
      }),
    });
  });

  it('should return 400 if the input is invalid', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Test Palette',
        colours: ['not-a-uuid'],
      }),
    };

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(400);
  });
});
