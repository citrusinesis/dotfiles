type Healthcheck = {
  service: string;
  status: "ok";
};

const healthcheck: Healthcheck = {
  service: "bun-app",
  status: "ok",
};

console.log(JSON.stringify(healthcheck, null, 2));
