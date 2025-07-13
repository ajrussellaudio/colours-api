# Task

Use Sequential Thinking to break down the task into smaller steps. When each step is complete, commit the code to git and move on to the next step.

You are to build a serverless API.

The API should be able to handle the following operations:

- CRUD operations on colours, stored as CMYK values.
- CRUD operations on palettes, which contain many colours (usually between 2 and 6).
- We should be able to bulk upload a CSV of colour data.

## Data Model

Colours with be of type:

```typescript
type Colour = {
  id: string; // UUID
  name: string; // Name of the colour
  c: number; // Cyan value (0-100)
  m: number; // Magenta value (0-100)
  y: number; // Yellow value (0-100)
  k: number; // Black value (0-100)
};
```

Palettes will be of type:

```typescript
type Palette = {
  id: string; // UUID
  name: string; // Name of the palette
  colours: Colour[]; // Array of Colour objects
};
```

The CSV format for colours should be:

```csv
Name,C,M,Y,K
Prussian Blue,100,72,0,6
```

## Tech stack

The API should be hosted on AWS using Lambda and API Gateway. Configuration should be done using Terraform.

Code should be written in TypeScript using the AWS SDK and a suitable database (e.g., DynamoDB). All code must be unit tested, and libraries should be used where appropriate. Libraries should be installed using npm. Linting should be configured using ESLint with the recommended rules for TypeScript, and formatting with Prettier.
