// Checks the committed bundle (dist/index.mjs) -- the file Terraform actually
// deploys -- loads as an ES module and exports the handler Lambda calls.
import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const bundleUrl = new URL("../dist/index.mjs", import.meta.url);

// Read by the bundle when it is first imported, as on a Lambda cold start.
process.env.ALLOW_LIST_TABLE = "test";
process.env.DENY_MESSAGE = "Bundle test deny message";
console.info = () => {};

type Handler = (event: unknown) => Promise<unknown>;

describe("committed bundle", () => {
  it("is an ES module exporting an async handler", async () => {
    const mod = (await import(bundleUrl.href)) as { handler?: unknown };
    assert.equal(typeof mod.handler, "function");
    assert.equal((mod.handler as Function).constructor.name, "AsyncFunction");
  });

  it("rejects with the message from the DENY_MESSAGE environment variable", async () => {
    const { handler } = (await import(bundleUrl.href)) as { handler: Handler };
    // No email means no DynamoDB call, so this runs without AWS access.
    const event = { userName: "u", triggerSource: "PreSignUp_SignUp", request: { userAttributes: {} } };
    await assert.rejects(handler(event), { message: "Bundle test deny message" });
  });

  it("does not bundle the AWS SDK (the nodejs24.x runtime provides it)", () => {
    const source = readFileSync(bundleUrl, "utf8");
    assert.match(source, /from"@aws-sdk\/client-dynamodb"/);
    assert.ok(source.length < 10_000, `bundle is ${source.length} bytes`);
  });
});
