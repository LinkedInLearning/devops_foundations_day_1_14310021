import ejs from "ejs";
import path from "node:path";

export async function handler() {
  const template = path.join(import.meta.dirname, "views", "hello.ejs");
  const data = {metrics: {synergy: "95.4%", powerpoint: "3 min", maturity: "Bronze+"}};
  const html = await ejs.renderFile(template, data);

  return {
    statusCode: 200,
    headers: {"Content-Type": "text/html; charset=utf-8"},
    body: html
  };
}
