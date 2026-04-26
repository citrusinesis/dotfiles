type Healthcheck = {
  service: string;
  status: "ok";
};

const healthcheck: Healthcheck = {
  service: "node-app",
  status: "ok",
};

console.log(JSON.stringify(healthcheck, null, 2));
