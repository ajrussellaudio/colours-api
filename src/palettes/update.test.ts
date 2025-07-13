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

describe('updatePalette', () => {
  it('should update a palette', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'PUT',
      pathParameters: {
        id: '123',
      },
      body: JSON.stringify({
        name: 'Updated Palette',
        colours: [],
      }),
    };

    mockUpdate.mockResolvedValue({ Attributes: { id: '123', name: 'Updated Palette' } });

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body).name).toBe('Updated Palette');
    expect(mockUpdate).toHaveBeenCalledWith(expect.objectContaining({
      TableName: '',
      Key: { id: '123' },
    }));
  });
});
