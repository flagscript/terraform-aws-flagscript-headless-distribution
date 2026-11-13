/**
 * Cognito Pre Sign-up trigger that only lets allow-listed emails register.
 *
 * The allow list is a DynamoDB table whose partition key is `email` (string).
 * Emails are stored and compared in lowercase. Anything that is not an exact
 * match -- including a lookup error -- blocks the sign-up (fail closed).
 *
 * Runs for every pre sign-up source: self sign-up (PreSignUp_SignUp),
 * admin-created users (PreSignUp_AdminCreateUser), and first sign-in through
 * a federated identity provider (PreSignUp_ExternalProvider).
 */
import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";
import type { PreSignUpTriggerEvent } from "aws-lambda";

/** Used when the DENY_MESSAGE environment variable is unset or empty. */
export const DEFAULT_DENY_MESSAGE = "This email is not authorized to sign up.";

/** Thrown to make Cognito reject the sign-up. Cognito shows the user:
 * "PreSignUp failed with error <message>" -- the prefix is added by Cognito. */
export class NotAllowedError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "NotAllowedError";
  }
}

/** The subset of DynamoDBClient the handler needs, so tests can fake it. */
export interface GetItemClient {
  send(command: GetItemCommand): Promise<{ Item?: Record<string, unknown> }>;
}

export function normalizeEmail(email: unknown): string {
  return typeof email === "string" ? email.trim().toLowerCase() : "";
}

export function createHandler(
  client: GetItemClient,
  tableName: string,
  denyMessage: string = DEFAULT_DENY_MESSAGE,
) {
  async function isAllowed(email: string): Promise<boolean> {
    if (!email) return false;
    const result = await client.send(
      new GetItemCommand({
        TableName: tableName,
        Key: { email: { S: email } },
        ConsistentRead: true,
      }),
    );
    return result.Item !== undefined;
  }

  return async (event: PreSignUpTriggerEvent): Promise<PreSignUpTriggerEvent> => {
    const email = normalizeEmail(event.request?.userAttributes?.email);
    const user = event.userName;
    const source = event.triggerSource;

    let allowed: boolean;
    try {
      allowed = await isAllowed(email);
    } catch (err) {
      console.error(`Allow-list lookup failed for user ${user} (${source}); denying`, err);
      throw new NotAllowedError(denyMessage);
    }

    if (!allowed) {
      console.info(`Denied sign-up for user ${user} (${source}): email not on allow list`);
      throw new NotAllowedError(denyMessage);
    }

    console.info(`Allowed sign-up for user ${user} (${source})`);
    return event;
  };
}

const tableName = process.env.ALLOW_LIST_TABLE ?? "";
const denyMessage = process.env.DENY_MESSAGE?.trim() || DEFAULT_DENY_MESSAGE;

// Created once per execution environment and reused across warm invocations.
export const handler = createHandler(new DynamoDBClient({}), tableName, denyMessage);
