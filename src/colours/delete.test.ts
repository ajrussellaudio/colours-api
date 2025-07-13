import { handler } from './delete';
import { APIGatewayEvent } from 'aws-lambda';

const mockDelete = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      delete: (params: any) => ({ promise: () => mockDelete(params) }),
    })),
  },
}));

describe('deleteColour', () => {
  it('should delete a colour', async () => {
    const event: Partial<APIGatewayEvent> = {
      httpMethod: 'DELETE',
      pathParameters: {
        id: '123',
      },
    };

    mockDelete.mockResolvedValue({});

    const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

    expect(result.statusCode).toBe(204);
    expect(mockDelete).toHaveBeenCalledWith({
      TableName: '',
      Key: { id: '123' },
    });
  });
});
