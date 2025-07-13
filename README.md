# Colours API

A serverless API for managing colours and palettes.

## API Endpoints

You will need to provide an API key in the `x-api-key` header for all requests.

### Colours API

#### Create a new colour

`POST /colours`

#### List all colours

`GET /colours`

#### Get a specific colour

`GET /colours/{colour_id}`

#### Update a specific colour

`PUT /colours/{colour_id}`

#### Delete a specific colour

`DELETE /colours/{colour_id}`

### Palettes API

#### Create a new palette

`POST /palettes`

#### List all palettes

`GET /palettes`

#### Get a specific palette

`GET /palettes/{palette_id}`

#### Update a specific palette

`PUT /palettes/{palette_id}`

#### Delete a specific palette

`DELETE /palettes/{palette_id}`

### Upload API

#### Upload a CSV of colours

`POST /upload`

Create a `colours.csv` file with the following content:

```csv
Name,C,M,Y,K
Prussian Blue,100,72,0,6
```

Then run the following command, replacing `YOUR_API_KEY` and `YOUR_CLOUDFRONT_URL` with your values:

```bash
curl -X POST https://YOUR_CLOUDFRONT_URL/upload \
-H "Content-Type: text/csv" \
-H "x-api-key: YOUR_API_KEY" \
--data-binary @colours.csv
```

