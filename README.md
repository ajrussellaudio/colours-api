# Colours API

A serverless API for managing colours and palettes.

## API Endpoints

The base URL for the API is `https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/`

You will need to provide an API key in the `x-api-key` header for all requests.

### Colours API

#### Create a new colour

```bash
curl -X POST https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/colours \
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
curl -H "x-api-key: YOUR_API_KEY" https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/colours
```

#### Get a specific colour

```bash
curl -H "x-api-key: YOUR_API_KEY" https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/colours/{colour_id}
```

#### Update a specific colour

```bash
curl -X PUT https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/colours/{colour_id} \
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
curl -X DELETE -H "x-api-key: YOUR_API_KEY" https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/colours/{colour_id}
```

### Palettes API

#### Create a new palette

```bash
curl -X POST https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/palettes \
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
curl -H "x-api-key: YOUR_API_KEY" https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/palettes
```

#### Get a specific palette

```bash
curl -H "x-api-key: YOUR_API_KEY" https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/palettes/{palette_id}
```

#### Update a specific palette

```bash
curl -X PUT https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/palettes/{palette_id} \
-H "Content-Type: application/json" \
-H "x-api-key: YOUR_API_KEY" \
-d '{
  "name": "My updated palette",
  "colours": []
}'
```

#### Delete a specific palette

```bash
curl -X DELETE -H "x-api-key: YOUR_API_KEY" https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/palettes/{palette_id}
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
curl -X POST https://brb6li0t65.execute-api.eu-west-1.amazonaws.com/upload \
-H "Content-Type: text/csv" \
-H "x-api-key: YOUR_API_KEY" \
--data-binary @colours.csv
```