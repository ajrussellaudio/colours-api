import { handler } from './update';
import { APIGatewayEvent } from 'aws-lambda';

const mockUpdate = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      update: (params: any) => ({ promise: () => mockUpdate(params) }),
    })),
  },
}));

describe('updateColour', () => {
  it('should update a colour', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'PUT',
      pathParameters: {
        id: '123',
      },
      body: JSON.stringify({
        name: 'Updated Blue',
        c: 100,
        m: 50,
        y: 0,
        k: 0,
      }),
    };

    mockUpdate.mockResolvedValue({ Attributes: { id: '123', name: 'Updated Blue' } });

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body).name).toBe('Updated Blue');
    expect(mockUpdate).toHaveBeenCalledWith(expect.objectContaining({
      TableName: '',
      Key: { id: '123' },
    }));
  });

  it('should return 400 if the input is invalid', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'PUT',
      pathParameters: {
        id: '123',
      },
      body: JSON.stringify({
        name: 'Updated Blue',
        c: 101,
        m: 50,
        y: 0,
        k: 0,
      }),
    };

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(400);
  });
});
