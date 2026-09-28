import {handler} from "./index.js";
import http from 'node:http';

// To support local testing, create a dirt-simple harness that calls the Lambda handler function, and returns an
// HTTP response with the results. For more robust harnesses, see the Serverless Framework, SAM, and SST.
http.createServer(async (req, res) => {
  const result = await handler();
  res.writeHead(result.statusCode, result.headers);
  res.end(result.body);
}).listen(8080);