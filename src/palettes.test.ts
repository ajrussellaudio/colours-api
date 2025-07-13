import { handler } from './palettes';
import { APIGatewayEvent } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';

const mockPut = jest.fn();
const mockGet = jest.fn();
const mockScan = jest.fn();
const mockUpdate = jest.fn();
const mockDelete = jest.fn();

jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      put: (params: any) => ({ promise: () => mockPut(params) }),
      get: (params: any) => ({ promise: () => mockGet(params) }),
      scan: (params: any) => ({ promise: () => mockScan(params) }),
      update: (params: any) => ({ promise: () => mockUpdate(params) }),
      delete: (params: any) => ({ promise: () => mockDelete(params) }),
    })),
  },
}));

describe('Palettes API', () => {
  beforeEach(() => {
    mockPut.mockClear();
    mockGet.mockClear();
    mockScan.mockClear();
    mockUpdate.mockClear();
    mockDelete.mockClear();
  });

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

    it('should return 400 if required fields are missing', async () => {
      const event: Partial<APIGatewayEvent> = {
        httpMethod: 'POST',
        body: JSON.stringify({
          name: 'Test Palette',
        }),
      };

      const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

      expect(result.statusCode).toBe(400);
    });
  });

  describe('getPalette', () => {
    it('should get a palette by id', async () => {
      const event: Partial<APIGatewayEvent> = {
        httpMethod: 'GET',
        pathParameters: {
          id: '123',
        },
      };

      mockGet.mockResolvedValue({ Item: { id: '123', name: 'Test Palette' } });

      const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

      expect(result.statusCode).toBe(200);
      expect(JSON.parse(result.body).name).toBe('Test Palette');
      expect(mockGet).toHaveBeenCalledWith({
        TableName: '',
        Key: { id: '123' },
      });
    });

    it('should return 404 if palette not found', async () => {
      const event: Partial<APIGatewayEvent> = {
        httpMethod: 'GET',
        pathParameters: {
          id: '123',
        },
      };

      mockGet.mockResolvedValue({});

      const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

      expect(result.statusCode).toBe(404);
    });
  });

  describe('listPalettes', () => {
    it('should list all palettes', async () => {
      const event: Partial<APIGatewayEvent> = {
        httpMethod: 'GET',
      };

      mockScan.mockResolvedValue({ Items: [{ id: '123', name: 'Test Palette' }] });

      const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

      expect(result.statusCode).toBe(200);
      expect(JSON.parse(result.body)[0].name).toBe('Test Palette');
      expect(mockScan).toHaveBeenCalledWith({
        TableName: '',
      });
    });
  });

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

  describe('deletePalette', () => {
    it('should delete a palette', async () => {
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
});
