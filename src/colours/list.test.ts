import { handler } from './list';

const mockScan = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      scan: (params: any) => ({ promise: () => mockScan(params) }),
    })),
  },
}));

describe('listColours', () => {
  it('should list all colours', async () => {
    mockScan.mockResolvedValue({ Items: [{ id: '123', name: 'Test Blue' }] });

    const result = await handler({} as any, {} as any, {} as any);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body)[0].name).toBe('Test Blue');
    expect(mockScan).toHaveBeenCalledWith({
      TableName: '',
    });
  });
});
