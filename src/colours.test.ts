import { handler } from './colours';
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

describe('Colours API', () => {
  beforeEach(() => {
    mockPut.mockClear();
    mockGet.mockClear();
    mockScan.mockClear();
    mockUpdate.mockClear();
    mockDelete.mockClear();
  });

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

    it('should return 400 if required fields are missing', async () => {
      const event: Partial<APIGatewayEvent> = {
        httpMethod: 'POST',
        body: JSON.stringify({
          name: 'Test Blue',
        }),
      };

      const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

      expect(result.statusCode).toBe(400);
    });
  });

  describe('getColour', () => {
    it('should get a colour by id', async () => {
      const event: Partial<APIGatewayEvent> = {
        httpMethod: 'GET',
        pathParameters: {
          id: '123',
        },
      };

      mockGet.mockResolvedValue({ Item: { id: '123', name: 'Test Blue' } });

      const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

      expect(result.statusCode).toBe(200);
      expect(JSON.parse(result.body).name).toBe('Test Blue');
      expect(mockGet).toHaveBeenCalledWith({
        TableName: '',
        Key: { id: '123' },
      });
    });

    it('should return 404 if colour not found', async () => {
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

  describe('listColours', () => {
    it('should list all colours', async () => {
      const event: Partial<APIGatewayEvent> = {
        httpMethod: 'GET',
      };

      mockScan.mockResolvedValue({ Items: [{ id: '123', name: 'Test Blue' }] });

      const result = await handler(event as APIGatewayEvent, {} as any, {} as any);

      expect(result.statusCode).toBe(200);
      expect(JSON.parse(result.body)[0].name).toBe('Test Blue');
      expect(mockScan).toHaveBeenCalledWith({
        TableName: '',
      });
    });
  });

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
  });

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
});
