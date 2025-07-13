import { handler } from './list';
import { v4 as uuidv4 } from 'uuid';

const mockScan = jest.fn();
const mockBatchGet = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      scan: (params: any) => ({ promise: () => mockScan(params) }),
      batchGet: (params: any) => ({ promise: () => mockBatchGet(params) }),
    })),
  },
}));

describe('listPalettes', () => {
  it('should list all palettes', async () => {
    const colourId = uuidv4();
    mockScan.mockResolvedValue({ Items: [{ id: '123', name: 'Test Palette', colours: [colourId] }] });
    mockBatchGet.mockResolvedValue({ Responses: { '': [{ id: colourId, name: 'Test Blue' }] } });

    const result = await handler({} as any, {} as any, {} as any);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body)[0].name).toBe('Test Palette');
    expect(JSON.parse(result.body)[0].colours[0].name).toBe('Test Blue');
    expect(mockScan).toHaveBeenCalledWith({
      TableName: '',
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
