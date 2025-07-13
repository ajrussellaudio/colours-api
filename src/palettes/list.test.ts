import { handler } from './list';

const mockScan = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      scan: (params: any) => ({ promise: () => mockScan(params) }),
    })),
  },
}));

describe('listPalettes', () => {
  it('should list all palettes', async () => {
    mockScan.mockResolvedValue({ Items: [{ id: '123', name: 'Test Palette' }] });

    const result = await handler({} as any, {} as any, {} as any);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body)[0].name).toBe('Test Palette');
    expect(mockScan).toHaveBeenCalledWith({
      TableName: '',
    });
  });
});
