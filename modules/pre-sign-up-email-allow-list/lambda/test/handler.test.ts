import { describe, it } from "node:test";
import assert from "node:assert/strict";
import type { GetItemCommand, GetItemCommandInput } from "@aws-sdk/client-dynamodb";
import type { PreSignUpTriggerEvent } from "aws-lambda";
import {
  createHandler,
  DEFAULT_DENY_MESSAGE,
  NotAllowedError,
  type GetItemClient,
} from "../src/handler.ts";

class FakeClient implements GetItemClient {
  calls: GetItemCommandInput[] = [];
  private emails: Set<string>;
  private error: Error | undefined;

  constructor(emails: string[] = [], error?: Error) {
    this.emails = new Set(emails);
    this.error = error;
  }

  async send(command: GetItemCommand) {
    this.calls.push(command.input);
    if (this.error) throw this.error;
    const email = command.input.Key?.email?.S ?? "";
    return this.emails.has(email) ? { Item: { email: { S: email } } } : {};
  }
}

function makeEvent(
  email?: string,
  triggerSource: PreSignUpTriggerEvent["triggerSource"] = "PreSignUp_SignUp",
): PreSignUpTriggerEvent {
  return {
    version: "1",
    region: "us-east-1",
    userPoolId: "us-east-1_test",
    triggerSource,
    userName: "user-123",
    callerContext: { awsSdkVersion: "1", clientId: "client" },
    request: { userAttributes: email === undefined ? {} : { email } },
    response: { autoConfirmUser: false, autoVerifyEmail: false, autoVerifyPhone: false },
  } as PreSignUpTriggerEvent;
}

// Keep test output clean.
console.info = () => {};
console.error = () => {};

describe("pre sign-up allow list", () => {
  it("returns the event unchanged for an allowed email", async () => {
    const handler = createHandler(new FakeClient(["alice@example.com"]), "t");
    const event = makeEvent("alice@example.com");
    const result = await handler(event);
    assert.equal(result, event);
    assert.equal(result.response.autoConfirmUser, false);
  });

  it("trims and lowercases the email before lookup", async () => {
    const client = new FakeClient(["alice@example.com"]);
    await createHandler(client, "allow-list")(makeEvent("  Alice@Example.COM "));
    assert.deepEqual(client.calls, [
      {
        TableName: "allow-list",
        Key: { email: { S: "alice@example.com" } },
        ConsistentRead: true,
      },
    ]);
  });

  it("denies an email not on the list", async () => {
    const handler = createHandler(new FakeClient(["alice@example.com"]), "t");
    await assert.rejects(handler(makeEvent("mallory@example.com")), NotAllowedError);
  });

  it("denies a missing email without a lookup", async () => {
    const client = new FakeClient(["alice@example.com"]);
    await assert.rejects(createHandler(client, "t")(makeEvent()), NotAllowedError);
    assert.equal(client.calls.length, 0);
  });

  it("fails closed when DynamoDB errors", async () => {
    const client = new FakeClient([], new Error("throttled"));
    await assert.rejects(
      createHandler(client, "t")(makeEvent("alice@example.com")),
      NotAllowedError,
    );
  });

  it("uses the default message when none is given", async () => {
    const handler = createHandler(new FakeClient(), "t");
    await assert.rejects(handler(makeEvent("mallory@example.com")), {
      name: "NotAllowedError",
      message: DEFAULT_DENY_MESSAGE,
    });
  });

  it("uses a custom message for both denials and lookup errors", async () => {
    const message = "Sign-up is invite-only.";
    await assert.rejects(
      createHandler(new FakeClient(), "t", message)(makeEvent("mallory@example.com")),
      { message },
    );
    await assert.rejects(
      createHandler(new FakeClient([], new Error("boom")), "t", message)(
        makeEvent("alice@example.com"),
      ),
      { message },
    );
  });

  for (const source of ["PreSignUp_AdminCreateUser", "PreSignUp_ExternalProvider"] as const) {
    it(`applies the allow list to ${source}`, async () => {
      const handler = createHandler(new FakeClient(["alice@example.com"]), "t");
      await handler(makeEvent("alice@example.com", source));
      await assert.rejects(handler(makeEvent("mallory@example.com", source)), NotAllowedError);
    });
  }
});
