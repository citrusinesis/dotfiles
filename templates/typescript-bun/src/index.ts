type Healthcheck = {
  service: string;
  status: 'ok';
};

type RuntimeGlobals = typeof globalThis & {
  process?: { env?: Record<string, string | undefined> };
};

const runtime = globalThis as RuntimeGlobals;
const healthcheck: Healthcheck = {
  service: runtime.process?.env?.SERVICE_NAME ?? 'bun-app',
  status: 'ok',
};

console.log(JSON.stringify(healthcheck, null, 2));
