import { handler } from "./index.js";
import { createServer } from 'node:http';

const server = createServer(async (req, res) => {
  // Call the Lambda handler function
  const response = await handler({}, {});

  // Return an HTTP response based on the handler function's response
  res.writeHead(response.statusCode, response.headers);
  res.end(response.body);
});

const port = process.env.PORT || 8080;
server.listen(port, '127.0.0.1', () => {
  console.log(`Listening on port ${port}`);
});