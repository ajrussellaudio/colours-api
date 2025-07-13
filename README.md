# Colours API

A serverless API for managing colours and palettes.

## API Endpoints

The base URL for the API is `https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/`

You will need to provide an API key in the `x-api-key` header for all requests.

### Colours API

#### Create a new colour

```bash
curl -X POST https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/colours \
-H "Content-Type: application/json" \
-H "x-api-key: YOUR_API_KEY" \
-d '{
  "name": "Prussian Blue",
  "c": 100,
  "m": 72,
  "y": 0,
  "k": 6
}'
```

#### List all colours

```bash
curl -H "x-api-key: YOUR_API_KEY" https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/colours
```

#### Get a specific colour

```bash
curl -H "x-api-key: YOUR_API_KEY" https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/colours/{colour_id}
```

#### Update a specific colour

```bash
curl -X PUT https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/colours/{colour_id} \
-H "Content-Type: application/json" \
-H "x-api-key: YOUR_API_KEY" \
-d '{
  "name": "A new name",
  "c": 100,
  "m": 72,
  "y": 0,
  "k": 6
}'
```

#### Delete a specific colour

```bash
curl -X DELETE -H "x-api-key: YOUR_API_KEY" https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/colours/{colour_id}
```

### Palettes API

#### Create a new palette

```bash
curl -X POST https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/palettes \
-H "Content-Type: application/json" \
-H "x-api-key: YOUR_API_KEY" \
-d '{
  "name": "My new palette",
  "colours": [
    "{colour_id}"
  ]
}'
```

#### List all palettes

```bash
curl -H "x-api-key: YOUR_API_KEY" https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/palettes
```

#### Get a specific palette

```bash
curl -H "x-api-key: YOUR_API_KEY" https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/palettes/{palette_id}
```

#### Update a specific palette

```bash
curl -X PUT https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/palettes/{palette_id} \
-H "Content-Type: application/json" \
-H "x-api-key: YOUR_API_KEY" \
-d '{
  "name": "My updated palette",
  "colours": []
}'
```

#### Delete a specific palette

```bash
curl -X DELETE -H "x-api-key: YOUR_API_KEY" https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/palettes/{palette_id}
```

### Upload API

#### Upload a CSV of colours

Create a `colours.csv` file with the following content:

```csv
Name,C,M,Y,K
Prussian Blue,100,72,0,6
```

Then run the following command:

```bash
curl -X POST https://xejggz5t2a.execute-api.eu-west-1.amazonaws.com/v1/upload \
-H "Content-Type: text/csv" \
-H "x-api-key: YOUR_API_KEY" \
--data-binary @colours.csv
```